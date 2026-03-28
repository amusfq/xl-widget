# 📶 XL Data Widget for macOS

A lightweight, native macOS menu bar utility that keeps your XL Axiata data quota and package expiry visible at all times. Built with SwiftUI and modern Swift concurrency.

## ✨ Features

- **Live Menu Bar Display**: See your remaining quota (GB/MB) and days until expiry directly in your macOS menu bar.
- **Detailed Popover**: Click the menu bar icon to see a full breakdown of all your active packages, expiry dates, and visual progress bars.
- **Custom Milestone Alerts**: Instead of boring system notifications, get a custom centered popup when your data is low.
- **Smart Tracking**: Alerts trigger at your chosen threshold (e.g., 2GB) and then again for every 500MB drop (1.5GB, 1.0GB, etc.).
- **Battery & Memory Optimized**: Uses modern `async/await` and shared expensive resources (like DateFormatters) to ensure minimal impact on your system.
- **Secure**: Runs in the macOS App Sandbox with only the necessary network permissions.

## 📸 Preview

> [!TIP]
> **Menu Bar Format:** `{Icon} {Quota} / {Days}d` (e.g., 📶 4.6GB / 12d)

## 🚀 Getting Started

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0+

### Installation
1. Clone this repository.
2. Open `XL Widget.xcodeproj` in Xcode.
3. Build and Run (**Cmd + R**).
4. The app will appear in your menu bar.
5. Click the **Gear Icon** (Settings) to enter your XL Phone Number.

## 🛠 Tech Stack
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Concurrency**: Async/Await
- **Persistence**: `@AppStorage` (UserDefaults)
- **Architecture**: Clean MVVM-style with logic-heavy models

## ⚙️ Configuration
You can customize the following in the app settings:
- **Phone Number**: Your XL Axiata number.
- **Notification Toggle**: Enable/Disable custom popup alerts.
- **Alert Threshold**: Set the GB level at which you want to be first notified.

## 🔒 Security & Privacy
This app communicates directly with the quota endpoint. It requires the `com.apple.security.network.client` entitlement to function. No personal data is stored outside of your local `UserDefaults`.

---
*Created with ❤️ for XL Axiata users on Mac.*
