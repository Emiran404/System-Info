import SwiftUI

@main
struct System_InfoApp: App {
    @StateObject private var monitor = SystemMonitor()
    @StateObject private var langManager = LanguageManager.shared
    
    init() {
        let icon = generateAppIcon()
        DispatchQueue.main.async {
            if let icon = icon {
                NSApplication.shared.applicationIconImage = icon
            }
        }
    }
    
    private func generateAppIcon() -> NSImage? {
        let size = NSSize(width: 512, height: 512)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw background: rounded rect with dark gray background
        let rect = NSRect(origin: .zero, size: size)
        let path = NSBezierPath(roundedRect: rect, xRadius: 110, yRadius: 110)
        path.addClip()
        
        NSColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0).setFill()
        rect.fill()
        
        let center = NSPoint(x: 256, y: 256)
        let radius: CGFloat = 135
        let lineWidth: CGFloat = 45
        
        let blueColor = NSColor(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0)
        let whiteColor = NSColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)
        
        // Draw Segment 1 (Top-Right): Blue
        let path1 = NSBezierPath()
        path1.appendArc(withCenter: center, radius: radius, startAngle: 15, endAngle: 75)
        path1.lineWidth = lineWidth
        path1.lineCapStyle = .round
        blueColor.setStroke()
        path1.stroke()
        
        // Draw Segment 2 (Left): Blue
        let path2 = NSBezierPath()
        path2.appendArc(withCenter: center, radius: radius, startAngle: 105, endAngle: 190)
        path2.lineWidth = lineWidth
        path2.lineCapStyle = .round
        blueColor.setStroke()
        path2.stroke()
        
        // Draw Segment 3 (Bottom): White
        let path3 = NSBezierPath()
        path3.appendArc(withCenter: center, radius: radius, startAngle: 220, endAngle: 345)
        path3.lineWidth = lineWidth
        path3.lineCapStyle = .round
        whiteColor.setStroke()
        path3.stroke()
        
        image.unlockFocus()
        return image
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(monitor: monitor)
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra(isInserted: .constant(langManager.menuBarShowOption != .none)) {
            Button("Show Main Window".localized) {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            
            Divider()
            
            Button("Quit".localized) {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            HStack(spacing: 4) {
                if let icon = menuBarIcon {
                    Image(systemName: icon)
                }
                Text(menuBarText)
            }
        }
    }
    
    private var menuBarIcon: String? {
        switch langManager.menuBarShowOption {
        case .cpu: return "cpu"
        case .temperature: return "thermometer.medium"
        case .memory: return "memorychip"
        case .none: return nil
        }
    }
    
    private var menuBarText: String {
        switch langManager.menuBarShowOption {
        case .cpu:
            return String(format: "%.0f%%", monitor.cpuUsageTotal)
        case .temperature:
            if let first = monitor.temperatures.first {
                if langManager.tempUnit == .fahrenheit {
                    let f = (first.temperature * 9/5) + 32
                    return String(format: "%.0f°F", f)
                }
                return String(format: "%.0f°C", first.temperature)
            }
            return "--°C"
        case .memory:
            return String(format: "%.0f%%", monitor.memoryUsedPercent)
        case .none:
            return ""
        }
    }
}
