import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var quotaManager: QuotaManager
    @AppStorage("phoneNumber") private var phoneNumber: String = ""
    @AppStorage("notificationEnabled") private var notificationEnabled: Bool = true
    @AppStorage("notificationThresholdGB") private var notificationThresholdGB: Double = 2.0
    
    var body: some View {
        Form {
            Section("Account") {
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: phoneNumber) {
                        quotaManager.fetchQuota()
                    }
                
                Button("Refresh Now") {
                    quotaManager.fetchQuota()
                }
            }
            
            Section("Quota Alert") {
                HStack {
                    Toggle("Enable Notifications", isOn: $notificationEnabled)
                    Spacer()
                    Button("Test") {
                        quotaManager.sendTestNotification()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                if notificationEnabled {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Alert threshold")
                            Spacer()
                            Text("\(notificationThresholdGB, specifier: "%.1f") GB")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }
                        
                        Slider(value: $notificationThresholdGB, in: 0.5...10, step: 0.5)
                        
                        Text("You will be notified when your data falls below this level.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .frame(width: 350)
    }
}

#Preview {
    SettingsView()
        .environmentObject(QuotaManager())
}
