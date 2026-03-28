//
//  ContentView.swift
//  XL Widget
//
//  Created by Achmad Musyaffa on 3/28/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var quotaManager: QuotaManager
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            Divider()
            
            ZStack {
                if quotaManager.phoneNumber.isEmpty || quotaManager.phoneNumber == "628192432670" && quotaManager.packages.isEmpty {
                    // Check if it's actually empty OR still the default but we have no data
                    // actually let's just check if it's empty for simplicity if that's what user wants
                    // but the user's default is 628192432670. 
                }
                
                if quotaManager.phoneNumber.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "phone.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 4) {
                            Text("No Phone Number")
                                .font(.headline)
                            Text("Please set your XL number in settings to check your quota.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        
                        SettingsLink {
                            Text("Open Settings")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if quotaManager.isLoading && quotaManager.packages.isEmpty {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = quotaManager.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if quotaManager.packages.isEmpty {
                    Text("No package data found.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(quotaManager.packages, id: \.name) { package in
                                PackageSection(package: package)
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(height: 350)
            
            Divider()
            
            FooterView()
        }
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct HeaderView: View {
    @EnvironmentObject var quotaManager: QuotaManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("XL Axiata")
                    .font(.system(size: 13, weight: .bold))
                Text(quotaManager.phoneNumber)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
            if quotaManager.isLoading {
                ProgressView()
                    .scaleEffect(0.5)
            } else {
                Button(action: { quotaManager.fetchQuota() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct PackageSection: View {
    let package: Package
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(package.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.blue)
            
            Text("Expires: \(package.expiry)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            ForEach(package.quotas, id: \.name) { quota in
                QuotaRow(quota: quota)
            }
        }
    }
}

struct QuotaRow: View {
    let quota: Quota
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(quota.name)
                    .font(.system(size: 12))
                Spacer()
                Text("\(quota.remaining) / \(quota.total)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: quota.percent, total: 100)
                .progressViewStyle(.linear)
                .tint(progressColor(for: quota.percent))
        }
    }
    
    private func progressColor(for percent: Double) -> Color {
        if percent < 20 {
            return .red
        } else if percent < 50 {
            return .orange
        } else {
            return .green
        }
    }
}

struct FooterView: View {
    @EnvironmentObject var quotaManager: QuotaManager
    
    var body: some View {
        HStack(spacing: 12) {
            if let lastUpdated = quotaManager.lastUpdated {
                Text("Updated \(lastUpdated, format: .dateTime.hour().minute())")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
            SettingsLink {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Image(systemName: "power")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
        .environmentObject(QuotaManager())
}
