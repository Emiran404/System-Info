import SwiftUI

struct ContentView: View {
    @ObservedObject var monitor: SystemMonitor
    @StateObject private var langManager = LanguageManager.shared
    @State private var selectedTab: String = "Dashboard"
    
    let tabs = [
        ("Dashboard", "square.grid.2x2.fill"),
        ("CPU & Cores", "cpu"),
        ("Memory", "memorychip"),
        ("Network & Storage", "network"),
        ("Thermal & Fans", "thermometer.medium"),
        ("Specifications", "info.circle.fill"),
        ("Settings", "gearshape.fill")
    ]
    
    var body: some View {
        NavigationSplitView {
            List(tabs, id: \.0, selection: $selectedTab) { tab in
                HStack(spacing: 12) {
                    Image(systemName: tab.1)
                        .font(.title3)
                        .foregroundStyle(selectedTab == tab.0 ? .white : .accentColor)
                        .frame(width: 24)
                    
                    Text(tab.0.localized)
                        .font(.body)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 6)
                .tag(tab.0)
            }
            .listStyle(.sidebar)
            .navigationTitle("System Info")
            .frame(minWidth: 210)
        } detail: {
            ZStack {
                // Futuristic subtle gradient background
                LinearGradient(
                    colors: [
                        Color(nsColor: .windowBackgroundColor).opacity(0.85),
                        Color.accentColor.opacity(0.05),
                        Color(nsColor: .windowBackgroundColor)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerView
                        
                        switch selectedTab {
                        case "Dashboard":
                            dashboardView
                        case "CPU & Cores":
                            cpuDetailedView
                        case "Memory":
                            memoryDetailedView
                        case "Network & Storage":
                            networkStorageDetailedView
                        case "Thermal & Fans":
                            thermalFansDetailedView
                        case "Specifications":
                            specsDetailedView
                        case "Settings":
                            settingsDetailedView
                        default:
                            dashboardView
                        }
                    }
                    .padding(30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(width: 850, height: 620)
        .id("\(langManager.currentLanguage.rawValue)-\(langManager.tempUnit.rawValue)")
        .preferredColorScheme(langManager.appTheme == .system ? nil : (langManager.appTheme == .dark ? .dark : .light))
    }
    
    // MARK: - Header Component
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedTab.localized)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                Text(monitor.specs.cpuName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            // Premium status pills
            HStack(spacing: 12) {
                if monitor.isBatteryPresent {
                    StatusPill(
                        title: "Battery".localized,
                        value: "\(monitor.batteryPercentage)% (\(monitor.batteryTimeRemaining.localized))",
                        icon: monitor.isCharging ? "battery.100.bolt" : "battery.50",
                        color: monitor.batteryPercentage < 20 ? .red : .green
                    )
                }
                StatusPill(title: "OS".localized, value: monitor.specs.osVersion, icon: "apple.logo", color: .secondary)
                StatusPill(title: "Uptime".localized, value: monitor.specs.uptime, icon: "clock.fill", color: .green)
            }
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Dashboard View
    private var dashboardView: some View {
        VStack(spacing: 24) {
            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                // CPU Gauge Card
                MetricCard(
                    title: "CPU Load".localized,
                    subtitle: "\(monitor.specs.physicalCores) \("Physical Cores".localized) / \(monitor.specs.logicalCores) \("Logical Threads".localized)",
                    icon: "cpu",
                    color: .blue
                ) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("\(String(format: "%.1f", monitor.cpuUsageTotal))%")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        ProgressView(value: monitor.cpuUsageTotal, total: 100)
                            .progressViewStyle(.linear)
                            .tint(.blue)
                        
                        // Mini Sparkline History
                        MiniAreaChart(data: monitor.cpuHistory, maxVal: 100, color: .blue)
                            .frame(height: 35)
                            .padding(.top, 4)
                    }
                }
                
                // Memory Gauge Card
                MetricCard(
                    title: "Memory (RAM)".localized,
                    subtitle: "\(String(format: "%.1f", monitor.memoryTotal - monitor.memoryFree)) GB / \(String(format: "%.1f", monitor.memoryTotal)) GB",
                    icon: "memorychip",
                    color: .purple
                ) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("\(String(format: "%.1f", monitor.memoryUsedPercent))%")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        ProgressView(value: monitor.memoryUsedPercent, total: 100)
                            .progressViewStyle(.linear)
                            .tint(.purple)
                        
                        // Mini Sparkline History
                        MiniAreaChart(data: monitor.memoryHistory, maxVal: 100, color: .purple)
                            .frame(height: 35)
                            .padding(.top, 4)
                    }
                }
            }
            
            // Sub-grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                // Network Card
                MetricCard(title: "Network Speed".localized, subtitle: "Total Traffic".localized, icon: "network", color: .teal) {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Download".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatSpeed(monitor.downloadSpeed))
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.teal)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Upload".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatSpeed(monitor.uploadSpeed))
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                            }
                        }
                    }
                }
                
                // Storage Card
                MetricCard(title: "Storage (SSD)".localized, subtitle: "Main Partition".localized, icon: "internaldrive.fill", color: .orange) {
                    VStack(spacing: 12) {
                        if let mainDisk = monitor.disks.first {
                            let totalGB = Double(mainDisk.totalSpace) / 1_073_741_824.0
                            let usedGB = Double(mainDisk.usedSpace) / 1_073_741_824.0
                            
                            HStack {
                                Text("\(String(format: "%.1f", mainDisk.usagePercent * 100))%")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(String(format: "%.0f", usedGB)) GB / \(String(format: "%.0f", totalGB)) GB")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            
                            ProgressView(value: mainDisk.usagePercent, total: 1.0)
                                .tint(.orange)
                        } else {
                            Text("No disks detected".localized)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - CPU Detailed View
    private var cpuDetailedView: some View {
        VStack(alignment: .leading, spacing: 24) {
            MetricCard(title: "CPU Load".localized, subtitle: "Real-time core diagnostics".localized, icon: "cpu", color: .blue) {
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        VStack(alignment: .leading) {
                            Text("Total Utilization".localized)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.1f", monitor.cpuUsageTotal))%")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Physical Cores".localized)
                                .foregroundColor(.secondary)
                            Text("\(monitor.specs.physicalCores)")
                                .font(.system(size: 24, weight: .bold))
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Logical Threads".localized)
                                .foregroundColor(.secondary)
                            Text("\(monitor.specs.logicalCores)")
                                .font(.system(size: 24, weight: .bold))
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Telemetry History (Last 60s)".localized)
                            .font(.headline)
                        
                        MiniAreaChart(data: monitor.cpuHistory, maxVal: 100, color: .blue)
                            .frame(height: 100)
                            .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    // Core Map Grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Per-Core Utilization".localized)
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                            ForEach(0..<monitor.cpuUsagePerCore.count, id: \.self) { index in
                                let load = monitor.cpuUsagePerCore[index]
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Core \(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.1f", load))%")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    ProgressView(value: load, total: 100)
                                        .tint(.blue)
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Memory Detailed View
    private var memoryDetailedView: some View {
        VStack(alignment: .leading, spacing: 24) {
            MetricCard(title: "Memory Usage".localized, subtitle: "RAM breakdown".localized, icon: "memorychip", color: .purple) {
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        VStack(alignment: .leading) {
                            Text("Total RAM".localized)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.1f", monitor.memoryTotal)) GB")
                                .font(.system(size: 32, weight: .bold))
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Memory Usage".localized)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.1f", monitor.memoryUsedPercent))%")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.purple)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Telemetry History (Last 60s)".localized)
                            .font(.headline)
                        
                        MiniAreaChart(data: monitor.memoryHistory, maxVal: 100, color: .purple)
                            .frame(height: 100)
                            .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        MemoryStatRow(title: "Active".localized, value: monitor.memoryActive, total: monitor.memoryTotal, color: .red)
                        MemoryStatRow(title: "Wired".localized, value: monitor.memoryWired, total: monitor.memoryTotal, color: .orange)
                        MemoryStatRow(title: "Compressed".localized, value: monitor.memoryCompressed, total: monitor.memoryTotal, color: .yellow)
                        MemoryStatRow(title: "Free / Cached".localized, value: monitor.memoryFree, total: monitor.memoryTotal, color: .green)
                    }
                }
            }
        }
    }
    
    // MARK: - Network & Storage Detailed View
    private var networkStorageDetailedView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Network Details Card
            MetricCard(title: "Network Speed".localized, subtitle: "Interface telemetry throughput".localized, icon: "network", color: .teal) {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Download".localized)
                                .foregroundColor(.secondary)
                            Text(formatSpeed(monitor.downloadSpeed))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.teal)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Upload".localized)
                                .foregroundColor(.secondary)
                            Text(formatSpeed(monitor.uploadSpeed))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                        }
                    }
                }
            }
            
            // Storage details
            ForEach(monitor.disks) { disk in
                let totalGB = Double(disk.totalSpace) / 1_073_741_824.0
                let freeGB = Double(disk.freeSpace) / 1_073_741_824.0
                let usedGB = Double(disk.usedSpace) / 1_073_741_824.0
                
                MetricCard(title: "\("Volume".localized): \(disk.mountPath)", subtitle: "APFS Storage Partition".localized, icon: "internaldrive.fill", color: .orange) {
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Used Space".localized)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", usedGB)) GB")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Free Space".localized)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", freeGB)) GB")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        ProgressView(value: disk.usagePercent, total: 1.0)
                            .tint(.orange)
                            .scaleEffect(y: 2)
                        
                        HStack {
                            Text("Total Capacity".localized)
                            Spacer()
                            Text("\(String(format: "%.1f", totalGB)) GB")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Thermal & Fans Detailed View
    private var thermalFansDetailedView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Fans Details Card
            if !monitor.fanSpeeds.isEmpty {
                MetricCard(title: "System Fans".localized, subtitle: "Fan cooling telemetry".localized, icon: "wind", color: .blue) {
                    VStack(spacing: 12) {
                        ForEach(0..<monitor.fanSpeeds.count, id: \.self) { index in
                            let speed = monitor.fanSpeeds[index]
                            HStack {
                                Text("\("Fan Speed".localized) \(index + 1)")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(speed) \("RPM".localized)")
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            } else {
                MetricCard(title: "System Fans".localized, subtitle: "Fan cooling telemetry".localized, icon: "wind", color: .secondary) {
                    Text("Fanless System (Passive Cooling)".localized)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            // Temperatures List Card
            MetricCard(title: "System Temperatures".localized, subtitle: "On-chip sensor arrays".localized, icon: "thermometer.medium", color: .red) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Thermal telemetry description".localized)
                            .foregroundColor(.secondary)
                            .font(.callout)
                        
                        if monitor.isSandboxFallback {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Calculated".localized)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                            .help("Sandbox restrictions prevent direct hardware sensor access. Values are dynamically calculated based on actual CPU load.".localized)
                        }
                    }
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        ForEach(monitor.temperatures) { sensor in
                            HStack {
                                Text(sensor.name.localized)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                
                                Text(formatTemp(sensor.temperature))
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(tempColor(for: sensor.temperature).opacity(0.15))
                                    )
                                    .foregroundColor(tempColor(for: sensor.temperature))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Specifications Detailed View
    private var specsDetailedView: some View {
        VStack(alignment: .leading, spacing: 24) {
            MetricCard(title: "Hardware Specifications".localized, subtitle: "Detailed hardware overview".localized, icon: "info.circle.fill", color: .accentColor) {
                VStack(spacing: 16) {
                    SpecRow(title: "Computer Model".localized, value: monitor.specs.modelName)
                    SpecRow(title: "Processor/SoC".localized, value: monitor.specs.cpuName)
                    SpecRow(title: "Logical Core Count".localized, value: "\(monitor.specs.logicalCores)")
                    SpecRow(title: "Physical Core Count".localized, value: "\(monitor.specs.physicalCores)")
                    SpecRow(title: "System Uptime".localized, value: monitor.specs.uptime)
                    SpecRow(title: "Operating System".localized, value: monitor.specs.osVersion)
                    
                    if monitor.isBatteryPresent {
                        SpecRow(title: "Battery Health".localized, value: "\(monitor.batteryHealth)%")
                        SpecRow(title: "Cycle Count".localized, value: "\(monitor.batteryCycles)")
                    }
                }
            }
        }
    }
    
    // MARK: - Settings View
    private var settingsDetailedView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Customization/Theme Card
            MetricCard(title: "App Customization".localized, subtitle: "Choose your preferred layout theme:".localized, icon: "paintbrush.fill", color: .orange) {
                Picker("", selection: $langManager.appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                .padding(.vertical, 10)
            }
            
            // Language Selection Card
            MetricCard(title: "Language Selection".localized, subtitle: "Choose your preferred interface language:".localized, icon: "character.bubble.fill", color: .teal) {
                Picker("", selection: $langManager.currentLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                .padding(.vertical, 10)
            }
            
            // Temperature Unit Card
            MetricCard(title: "Temperature Unit".localized, subtitle: "Choose your preferred temperature unit:".localized, icon: "thermometer.medium", color: .red) {
                Picker("", selection: $langManager.tempUnit) {
                    ForEach(TemperatureUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                .padding(.vertical, 10)
            }
            
            // Menu Bar Customization Card
            MetricCard(title: "Menu Bar Display".localized, subtitle: "Choose what to display in the macOS Menu Bar:".localized, icon: "uiwindow.split.2x1", color: .purple) {
                Picker("", selection: $langManager.menuBarShowOption) {
                    ForEach(MenuBarOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                .padding(.vertical, 10)
            }
            
            // Auto Start Preference
            MetricCard(title: "App Launch Preference".localized, subtitle: "Launch System Info automatically at start".localized, icon: "power", color: .green) {
                Toggle("Start System Info when you log in".localized, isOn: $langManager.launchAtLoginEnabled)
                    .toggleStyle(.switch)
                    .padding(.vertical, 8)
            }
            
            // Developer and Repo Info Card
            MetricCard(title: "Settings & Developer Info".localized, subtitle: "System Monitor App Details".localized, icon: "info.circle.fill", color: .accentColor) {
                VStack(spacing: 16) {
                    SpecRow(title: "Developer".localized, value: "Emirhan Gök")
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("GitHub Repository".localized)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "https://github.com/Emiran404/System-Info") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("github.com/Emiran404/System-Info")
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .foregroundColor(.accentColor)
                                .fontWeight(.medium)
                            }
                            .buttonStyle(.plain)
                        }
                        Divider()
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func formatTemp(_ celsiusValue: Double) -> String {
        if langManager.tempUnit == .fahrenheit {
            let f = (celsiusValue * 9/5) + 32
            return String(format: "%.1f°F", f)
        } else {
            return String(format: "%.1f°C", celsiusValue)
        }
    }
    
    private func tempColor(for temp: Double) -> Color {
        if temp < 40 { return .blue }
        if temp < 60 { return .green }
        if temp < 80 { return .orange }
        return .red
    }
    
    private func formatSpeed(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1_048_576.0 {
            return String(format: "%.2f MB/s", bytesPerSec / 1_048_576.0)
        } else if bytesPerSec >= 1024.0 {
            return String(format: "%.1f KB/s", bytesPerSec / 1024.0)
        } else {
            return String(format: "%.0f B/s", bytesPerSec)
        }
    }
}

// Sparkline Custom Area Chart

struct MiniAreaChart: View {
    let data: [Double]
    let maxVal: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            if data.isEmpty {
                EmptyView()
            } else {
                Path { path in
                    let stepX = width / CGFloat(max(1, data.count - 1))
                    
                    for index in 0..<data.count {
                        let x = CGFloat(index) * stepX
                        let ratio = maxVal > 0 ? (data[index] / maxVal) : 0
                        let y = height - (CGFloat(ratio) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, lineWidth: 1.8)
                .background(
                    Path { path in
                        let stepX = width / CGFloat(max(1, data.count - 1))
                        path.move(to: CGPoint(x: 0, y: height))
                        for index in 0..<data.count {
                            let x = CGFloat(index) * stepX
                            let ratio = maxVal > 0 ? (data[index] / maxVal) : 0
                            let y = height - (CGFloat(ratio) * height)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.18), color.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
            }
        }
    }
}

// Support UI Elements

struct StatusPill: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 11, weight: .bold))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.06))
        .cornerRadius(8)
    }
}

struct MetricCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, subtitle: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct MemoryStatRow: View {
    let title: String
    let value: Double
    let total: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(String(format: "%.2f", value)) GB")
                    .fontWeight(.medium)
            }
            ProgressView(value: value, total: total)
                .tint(color)
        }
    }
}

struct SpecRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.trailing)
            }
            Divider()
        }
    }
}
