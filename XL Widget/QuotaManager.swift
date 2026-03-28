import Foundation
import SwiftUI
import Combine
import UserNotifications

@MainActor
class QuotaManager: ObservableObject {
    @AppStorage("phoneNumber") var phoneNumber: String = ""

    
    // Notification Settings
    @AppStorage("notificationEnabled") var notificationEnabled: Bool = true
    @AppStorage("notificationThresholdGB") var notificationThresholdGB: Double = 2.0
    // Track the last MB level we alerted at to calculate 500MB drops
    @AppStorage("lastAlertedMB") private var lastAlertedMB: Double = 0
    
    // UI state
    @Published var currentQuota: String = "..."
    @Published var daysRemaining: String = "/0d"
    @Published var lastUpdated: Date?
    @Published var packages: [Package] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    
    init() {
        requestNotificationPermission()
        fetchQuota()
        startTimer()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.fetchQuota()
            }
        }
    }
    
    func fetchQuota() {
        guard !phoneNumber.isEmpty else {
            currentQuota = "Set No."
            daysRemaining = ""
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            let urlString = "https://bendith.my.id/end.php?check=package&number=\(phoneNumber)&version=2"
            guard let url = URL(string: urlString) else {
                isLoading = false
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(QuotaResponse.self, from: data)
                
                if response.success {
                    processResponse(response.data)
                } else {
                    errorMessage = response.message.isEmpty ? "API Error" : response.message
                    currentQuota = "Err"
                    daysRemaining = ""
                }
            } catch {
                print("Fetch error: \(error)")
                errorMessage = "Network Error"
                currentQuota = "Err"
                daysRemaining = ""
            }
            
            isLoading = false
        }
    }
    
    private func processResponse(_ data: QuotaData) {
        // Use optimized model logic
        let quota = data.primaryQuota
        currentQuota = quota?.remaining ?? "0"
        
        if let expiry = data.earliestExpiryDate {
            let calendar = Calendar.current
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfExpiry = calendar.startOfDay(for: expiry)
            let days = calendar.dateComponents([.day], from: startOfNow, to: startOfExpiry).day ?? 0
            daysRemaining = "/\(max(0, days))d"
        } else {
            daysRemaining = "/0d"
        }
        
        packages = data.package_info.packages
        lastUpdated = Date()
        
        // Check for alerts
        if let quota = quota {
            checkAndSendAlert(remainingMB: quota.remainingValueMB)
        }
    }
    
    private func checkAndSendAlert(remainingMB: Double) {
        guard notificationEnabled else { return }
        
        let thresholdMB = notificationThresholdGB * 1024
        
        // Scenario 1: First time crossing the main threshold
        if remainingMB < thresholdMB && lastAlertedMB == 0 {
            sendNotification(remaining: currentQuota)
            lastAlertedMB = remainingMB
            return
        }
        
        // Scenario 2: Subsequent 500MB drops
        if lastAlertedMB > 0 {
            let drop = lastAlertedMB - remainingMB
            if drop >= 500 {
                sendNotification(remaining: currentQuota)
                lastAlertedMB = remainingMB
                return
            }
        }
        
        // Reset logic: If user refills data (increases by more than 500MB above threshold)
        if remainingMB > thresholdMB + 500 {
            lastAlertedMB = 0
        }
    }
    
    private var alertWindow: NSPanel?

    private func sendNotification(remaining: String) {
        showCustomAlert(remaining: remaining)
    }
    
    func sendTestNotification() {
        showCustomAlert(remaining: "2.0 GB (Test)")
    }
    
    private func showCustomAlert(remaining: String) {
        if alertWindow != nil {
            alertWindow?.close()
        }
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 250),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        
        let alertView = QuotaAlertView(remaining: remaining) {
            panel.close()
        }
        
        panel.contentView = NSHostingView(rootView: alertView)
        panel.center()
        panel.orderFrontRegardless()
        
        self.alertWindow = panel
        
        // Bring app to front to show the panel
        NSApp.activate(ignoringOtherApps: true)
    }
    
    deinit {
        timer?.invalidate()
    }
}
