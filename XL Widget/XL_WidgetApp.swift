//
//  XL_WidgetApp.swift
//  XL Widget
//
//  Created by Achmad Musyaffa on 3/28/26.
//

import SwiftUI

@main
struct XL_WidgetApp: App {
    @StateObject private var quotaManager = QuotaManager()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(quotaManager)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                Text("\(quotaManager.currentQuota)\(quotaManager.daysRemaining)")
                    .font(.system(size: 11, weight: .medium))
            }
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
                .environmentObject(quotaManager)
        }
    }
}
