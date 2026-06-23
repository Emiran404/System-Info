# System Info - macOS Native System Monitor

A premium, lightweight, native macOS system monitor written in Swift and SwiftUI. It tracks real-time CPU utilization, RAM usage breakdown, storage partition status, active download/upload speeds, battery health diagnostics, fan speeds, and Apple Silicon thermal sensor arrays.

## 🚀 Features

- 💻 **Real-time Telemetry Dashboard**: Visual gauges, progress indicators, and dynamic stats.
- ⚡ **CPU & Memory History Graphs**: Beautiful, glowing area/sparkline charts displaying usage over the last 60 seconds.
- 🌡️ **Thermal Sensor Array**: Real-time readings directly from Apple Silicon SoC clusters and PMU controllers.
- 🌬️ **Fan Speed Monitoring**: Dynamic RPM tracking that responds to system load.
- 💾 **Storage & Partition Manager**: Detailed APFS volume usage breakdowns.
- 🔋 **Battery Diagnostics**: Tracks remaining charge, cycle count, health percentage, and power source status.
- 🌐 **Network Throughput**: Sums active interface bytes for download and upload speeds.
- ⚙️ **Custom Settings**:
  - **Multi-language**: Turkish, English, German.
  - **Launch at Login**: Auto-starts the utility when logging in using modern `SMAppService` API.
  - **Theme Selection**: System theme, light mode, or dark mode.
  - **Temperature Units**: Celsius (°C) and Fahrenheit (°F).
  - **Menu Bar Display**: Option to show live CPU, RAM, or temperature readings on the macOS Status Bar.

## 🛠️ Installation & Build

### 📥 Install via DMG (Recommended)
1. Download the latest `SystemInfo.dmg` from the repository releases or the root folder.
2. Double-click the `SystemInfo.dmg` to open it.
3. Drag `SystemInfo.app` into your **Applications** folder.
4. Open the application from your launchpad or Applications folder.

### Compiling from Command Line
You can compile the app directly using the native compiler:
```bash
swiftc -sdk $(xcrun --show-sdk-path --sdk macosx) "System Info/System_InfoApp.swift" "System Info/ContentView.swift" "System Info/SystemMonitor.swift" "System Info/LanguageManager.swift" -o SystemInfo
```

### Building via Xcode
1. Open `System Info.xcodeproj` in Xcode.
2. Select your target (My Mac) and click **Build / Run (Cmd + R)**.

## 👤 Developer
- **Emirhan Gök**
- GitHub: [@Emiran404](https://github.com/Emiran404)

## 📄 License
This project is open-source and available under the MIT License.
