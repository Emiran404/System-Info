import Foundation
import Combine
import ServiceManagement

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System Theme".localized
        case .light: return "Light Mode".localized
        case .dark: return "Dark Mode".localized
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case german = "de"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .german: return "Deutsch"
        }
    }
}

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius = "C"
    case fahrenheit = "F"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

enum MenuBarOption: String, CaseIterable, Identifiable {
    case none = "none"
    case cpu = "cpu"
    case temperature = "temp"
    case memory = "memory"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .none: return "Disabled".localized
        case .cpu: return "CPU Load".localized
        case .temperature: return "Thermal Sensors".localized
        case .memory: return "Memory (RAM)".localized
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage = .turkish {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }
    
    @Published var tempUnit: TemperatureUnit = .celsius {
        didSet {
            UserDefaults.standard.set(tempUnit.rawValue, forKey: "temp_unit")
        }
    }
    
    @Published var menuBarShowOption: MenuBarOption = .cpu {
        didSet {
            UserDefaults.standard.set(menuBarShowOption.rawValue, forKey: "menubar_option")
        }
    }
    
    @Published var appTheme: AppTheme = .system {
        didSet {
            UserDefaults.standard.set(appTheme.rawValue, forKey: "app_theme")
        }
    }
    
    @Published var launchAtLoginEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(launchAtLoginEnabled, forKey: "launch_at_login")
            updateLaunchAtLoginSetting()
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "app_language"),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            let preferred = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
            if preferred == "tr" {
                self.currentLanguage = .turkish
            } else if preferred == "de" {
                self.currentLanguage = .german
            } else {
                self.currentLanguage = .english
            }
        }
        
        if let savedUnit = UserDefaults.standard.string(forKey: "temp_unit"),
           let unit = TemperatureUnit(rawValue: savedUnit) {
            self.tempUnit = unit
        } else {
            self.tempUnit = .celsius
        }
        
        if let savedMenu = UserDefaults.standard.string(forKey: "menubar_option"),
           let option = MenuBarOption(rawValue: savedMenu) {
            self.menuBarShowOption = option
        } else {
            self.menuBarShowOption = .cpu
        }
        
        if let savedTheme = UserDefaults.standard.string(forKey: "app_theme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.appTheme = theme
        } else {
            self.appTheme = .system
        }
        
        self.launchAtLoginEnabled = UserDefaults.standard.bool(forKey: "launch_at_login")
    }
    
    private func updateLaunchAtLoginSetting() {
        let service = SMAppService.mainApp
        if launchAtLoginEnabled {
            try? service.register()
        } else {
            try? service.unregister()
        }
    }
    
    private let translations: [String: [AppLanguage: String]] = [
        "Dashboard": [
            .english: "Dashboard",
            .turkish: "Panel",
            .german: "Dashboard"
        ],
        "CPU & Cores": [
            .english: "CPU & Cores",
            .turkish: "İşlemci & Çekirdekler",
            .german: "CPU & Kerne"
        ],
        "Memory": [
            .english: "Memory",
            .turkish: "Bellek",
            .german: "Speicher"
        ],
        "Storage": [
            .english: "Storage",
            .turkish: "Depolama",
            .german: "Festplatte"
        ],
        "Thermal & Sensors": [
            .english: "Thermal & Sensors",
            .turkish: "Sıcaklık & Sensörler",
            .german: "Temperatur & Sensoren"
        ],
        "Specifications": [
            .english: "Specifications",
            .turkish: "Sistem Özellikleri",
            .german: "Spezifikationen"
        ],
        "Settings": [
            .english: "Settings",
            .turkish: "Ayarlar",
            .german: "Einstellungen"
        ],
        "CPU Load": [
            .english: "CPU Load",
            .turkish: "İşlemci Yükü",
            .german: "CPU-Auslastung"
        ],
        "Memory (RAM)": [
            .english: "Memory (RAM)",
            .turkish: "Bellek (RAM)",
            .german: "Arbeitsspeicher (RAM)"
        ],
        "Storage (SSD)": [
            .english: "Storage (SSD)",
            .turkish: "Depolama (SSD)",
            .german: "Speicherplatz (SSD)"
        ],
        "Thermal Sensors": [
            .english: "Thermal Sensors",
            .turkish: "Sıcaklık Sensörleri",
            .german: "Thermosensoren"
        ],
        "Uptime": [
            .english: "Uptime",
            .turkish: "Açık Kalma Süresi",
            .german: "Betriebszeit"
        ],
        "OS": [
            .english: "OS",
            .turkish: "İşletim Sistemi",
            .german: "Betriebssystem"
        ],
        "Main Partition": [
            .english: "Main Partition",
            .turkish: "Ana Bölüm",
            .german: "Hauptpartition"
        ],
        "Total Utilization": [
            .english: "Total Utilization",
            .turkish: "Toplam Kullanım",
            .german: "Gesamtauslastung"
        ],
        "Physical Cores": [
            .english: "Physical Cores",
            .turkish: "Fiziksel Çekirdek",
            .german: "Physische Kerne"
        ],
        "Logical Threads": [
            .english: "Logical Threads",
            .turkish: "Mantıksal İzlekler",
            .german: "Logische Threads"
        ],
        "Per-Core Utilization": [
            .english: "Per-Core Utilization",
            .turkish: "Çekirdek Başına Kullanım",
            .german: "Auslastung pro Kern"
        ],
        "Total RAM": [
            .english: "Total RAM",
            .turkish: "Toplam RAM",
            .german: "Gesamt-RAM"
        ],
        "Memory Usage": [
            .english: "Memory Usage",
            .turkish: "Bellek Kullanımı",
            .german: "Speichernutzung"
        ],
        "Active": [
            .english: "Active",
            .turkish: "Aktif",
            .german: "Aktiv"
        ],
        "Wired": [
            .english: "Wired",
            .turkish: "Bağlı (Wired)",
            .german: "Reserviert (Wired)"
        ],
        "Compressed": [
            .english: "Compressed",
            .turkish: "Sıkıştırılmış",
            .german: "Komprimiert"
        ],
        "Free / Cached": [
            .english: "Free / Cached",
            .turkish: "Serbest / Önberlek",
            .german: "Frei / Cache"
        ],
        "Volume": [
            .english: "Volume",
            .turkish: "Bölüm",
            .german: "Volume"
        ],
        "APFS Storage Partition": [
            .english: "APFS Storage Partition",
            .turkish: "APFS Depolama Bölümü",
            .german: "APFS-Speicherpartition"
        ],
        "Used Space": [
            .english: "Used Space",
            .turkish: "Kullanılan Alan",
            .german: "Belegter Speicher"
        ],
        "Free Space": [
            .english: "Free Space",
            .turkish: "Boş Alan",
            .german: "Freier Speicher"
        ],
        "Total Capacity": [
            .english: "Total Capacity",
            .turkish: "Toplam Kapasite",
            .german: "Gesamtkapazität"
        ],
        "System Temperatures": [
            .english: "System Temperatures",
            .turkish: "Sistem Sıcaklıkları",
            .german: "Systemtemperaturen"
        ],
        "On-chip sensor arrays": [
            .english: "On-chip sensor arrays",
            .turkish: "Çip üzeri sensör dizileri",
            .german: "Integrierte Sensor-Arrays"
        ],
        "Thermal telemetry description": [
            .english: "Thermal telemetry is fetched directly from Apple Silicon sensor pipelines.",
            .turkish: "Sıcaklık telemetrisi doğrudan Apple Silicon sensör kanallarından alınmaktadır.",
            .german: "Thermelemetrie wird direkt aus den Apple Silicon Sensor-Pipelines bezogen."
        ],
        "Computer Model": [
            .english: "Computer Model",
            .turkish: "Bilgisayar Modeli",
            .german: "Computermodell"
        ],
        "Processor/SoC": [
            .english: "Processor/SoC",
            .turkish: "İşlemci/SoC",
            .german: "Prozessor/SoC"
        ],
        "Logical Core Count": [
            .english: "Logical Core Count",
            .turkish: "Mantıksal Çekirdek Sayısı",
            .german: "Logische Kernanzahl"
        ],
        "Physical Core Count": [
            .english: "Physical Core Count",
            .turkish: "Fiziksel Çekirdek Sayısı",
            .german: "Physische Kernanzahl"
        ],
        "System Uptime": [
            .english: "System Uptime",
            .turkish: "Sistem Açık Kalma Süresi",
            .german: "Systembetriebszeit"
        ],
        "Operating System": [
            .english: "Operating System",
            .turkish: "İşletim Sistemi",
            .german: "Betriebssystem"
        ],
        "Settings & Developer Info": [
            .english: "Settings & Developer Info",
            .turkish: "Ayarlar & Geliştirici Bilgisi",
            .german: "Einstellungen & Entwickler-Info"
        ],
        "Developer": [
            .english: "Developer",
            .turkish: "Geliştirici",
            .german: "Entwickler"
        ],
        "GitHub Repository": [
            .english: "GitHub Repository",
            .turkish: "GitHub Deposu",
            .german: "GitHub-Repository"
        ],
        "Language Selection": [
            .english: "Language Selection",
            .turkish: "Dil Seçimi",
            .german: "Sprachauswahl"
        ],
        "Choose your preferred interface language:": [
            .english: "Choose your preferred interface language:",
            .turkish: "Tercih ettiğiniz arayüz dilini seçin:",
            .german: "Wählen Sie Ihre bevorzugte Benutzeroberflächensprache:"
        ],
        "Temperature Unit": [
            .english: "Temperature Unit",
            .turkish: "Sıcaklık Birimi",
            .german: "Temperatureinheit"
        ],
        "Choose your preferred temperature unit:": [
            .english: "Choose your preferred temperature unit:",
            .turkish: "Tercih ettiğiniz sıcaklık birimini seçin:",
            .german: "Wählen Sie Ihre bevorzugte Temperatureinheit:"
        ],
        "Disabled": [
            .english: "Disabled",
            .turkish: "Devre Dışı",
            .german: "Deaktiviert"
        ],
        "Menu Bar Display": [
            .english: "Menu Bar Display",
            .turkish: "Menü Çubuğu Gösterimi",
            .german: "Menüleisten-Anzeige"
        ],
        "Choose what to display in the macOS Menu Bar:": [
            .english: "Choose what to display in the macOS Menu Bar:",
            .turkish: "macOS Menü Çubuğunda neyin gösterileceğini seçin:",
            .german: "Wählen Sie, was in der macOS-Menüleiste angezeigt werden soll:"
        ],
        "Thermal State": [
            .english: "Thermal State",
            .turkish: "Termal Durum",
            .german: "Thermischer Zustand"
        ],
        "Gathering thermal telemetry...": [
            .english: "Gathering thermal telemetry...",
            .turkish: "Termal veriler toplanıyor...",
            .german: "Thermelemetrie wird geladen..."
        ],
        "No disks detected": [
            .english: "No disks detected",
            .turkish: "Disk algılanamadı",
            .german: "Keine Festplatten erkannt"
        ],
        "Hardware Specifications": [
            .english: "Hardware Specifications",
            .turkish: "Donanım Özellikleri",
            .german: "Hardware-Spezifikationen"
        ],
        "Detailed hardware overview": [
            .english: "Detailed hardware overview",
            .turkish: "Detaylı donanım özeti",
            .german: "Detaillierte Hardware-Übersicht"
        ],
        "Real-time core diagnostics": [
            .english: "Real-time core diagnostics",
            .turkish: "Gerçek zamanlı çekirdek analizi",
            .german: "Echtzeit-Kerndiagnose"
        ],
        "RAM breakdown": [
            .english: "RAM breakdown",
            .turkish: "RAM detaylı dağılımı",
            .german: "RAM-Aufteilung"
        ],
        "Network": [
            .english: "Network",
            .turkish: "Ağ",
            .german: "Netzwerk"
        ],
        "Download": [
            .english: "Download",
            .turkish: "İndirme",
            .german: "Download"
        ],
        "Upload": [
            .english: "Upload",
            .turkish: "Yükleme",
            .german: "Upload"
        ],
        "Network Speed": [
            .english: "Network Speed",
            .turkish: "Ağ Hızı",
            .german: "Netzwerkgeschwindigkeit"
        ],
        "Battery": [
            .english: "Battery",
            .turkish: "Pil",
            .german: "Batterie"
        ],
        "Battery Health": [
            .english: "Battery Health",
            .turkish: "Pil Sağlığı",
            .german: "Batteriezustand"
        ],
        "Cycle Count": [
            .english: "Cycle Count",
            .turkish: "Devir Sayısı",
            .german: "Ladezyklen"
        ],
        "Capacity": [
            .english: "Capacity",
            .turkish: "Kapasite",
            .german: "Kapazität"
        ],
        "Time Remaining": [
            .english: "Time Remaining",
            .turkish: "Kalan Süre",
            .german: "Restzeit"
        ],
        "Power Source": [
            .english: "Power Source",
            .turkish: "Güç Kaynağı",
            .german: "Stromquelle"
        ],
        "Charging": [
            .english: "Charging",
            .turkish: "Şarj Ediliyor",
            .german: "Lädt"
        ],
        "Discharging": [
            .english: "Discharging",
            .turkish: "Deşarj Oluyor",
            .german: "Entlädt"
        ],
        "Fan Speed": [
            .english: "Fan Speed",
            .turkish: "Fan Hızı",
            .german: "Lüfterdrehzahl"
        ],
        "RPM": [
            .english: "RPM",
            .turkish: "RPM",
            .german: "U/min"
        ],
        "System Fans": [
            .english: "System Fans",
            .turkish: "Sistem Fanları",
            .german: "Systemlüfter"
        ],
        "Launch at Login": [
            .english: "Launch at Login",
            .turkish: "Başlangıçta Çalıştır",
            .german: "Beim Start öffnen"
        ],
        "Theme": [
            .english: "Theme",
            .turkish: "Tema",
            .german: "Design"
        ],
        "System Theme": [
            .english: "System Theme",
            .turkish: "Sistem Teması",
            .german: "System-Design"
        ],
        "Light Mode": [
            .english: "Light Mode",
            .turkish: "Açık Tema",
            .german: "Heller Modus"
        ],
        "Dark Mode": [
            .english: "Dark Mode",
            .turkish: "Koyu Tema",
            .german: "Dunkler Modus"
        ],
        "App Customization": [
            .english: "App Customization",
            .turkish: "Uygulama Kişiselleştirme",
            .german: "App-Personalisierung"
        ],
        "App Launch Preference": [
            .english: "App Launch Preference",
            .turkish: "Başlangıç Tercihleri",
            .german: "Start-Präferenzen"
        ],
        "Start System Info when you log in": [
            .english: "Start System Info when you log in",
            .turkish: "Giriş yaptığınızda Sistem Bilgisini başlatın",
            .german: "System-Info beim Anmelden starten"
        ],
        "Telemetry History (Last 60s)": [
            .english: "Telemetry History (Last 60s)",
            .turkish: "Telemetri Geçmişi (Son 60sn)",
            .german: "Telemetrieverlauf (Letzte 60s)"
        ],
        "CPU & RAM Telemetry History": [
            .english: "CPU & RAM Telemetry History",
            .turkish: "Canlı İşlemci ve Bellek Kullanım Grafikleri",
            .german: "Live-CPU- und RAM-Verlaufsgrafiken"
        ],
        "Network & Storage": [
            .english: "Network & Storage",
            .turkish: "Ağ & Depolama",
            .german: "Netzwerk & Speicher"
        ],
        "Thermal & Fans": [
            .english: "Thermal & Fans",
            .turkish: "Sıcaklık & Fanlar",
            .german: "Temperatur & Lüfter"
        ],
        "Fan cooling telemetry": [
            .english: "Fan cooling telemetry",
            .turkish: "Fan soğutma telemetrisi",
            .german: "Lüfterkühlung-Telemetrie"
        ],
        "Fanless System (Passive Cooling)": [
            .english: "Fanless System (Passive Cooling)",
            .turkish: "Fansız Sistem (Pasif Soğutma)",
            .german: "Lüfterloses System (Passive Kühlung)"
        ],
        "Interface telemetry throughput": [
            .english: "Interface telemetry throughput",
            .turkish: "Ağ arayüzü veri akış hızı",
            .german: "Netzwerkschnittstellen-Durchsatz"
        ],
        "Total Traffic": [
            .english: "Total Traffic",
            .turkish: "Toplam Trafik",
            .german: "Gesamtverkehr"
        ],
        "Launch System Info automatically at start": [
            .english: "Launch System Info automatically at start",
            .turkish: "Sistem Bilgisini başlangıçta otomatik başlat",
            .german: "System-Info beim Systemstart automatisch starten"
        ],
        "Choose your preferred layout theme:": [
            .english: "Choose your preferred layout theme:",
            .turkish: "Tercih ettiğiniz arayüz temasını seçin:",
            .german: "Wählen Sie Ihr bevorzugtes Layout-Design:"
        ],
        "System Monitor App Details": [
            .english: "System Monitor App Details",
            .turkish: "Sistem Monitörü Uygulama Detayları",
            .german: "Systemmonitor-App-Details"
        ],
        "CPU Performance Cluster": [
            .english: "CPU Performance Cluster",
            .turkish: "CPU Performans Çekirdekleri",
            .german: "CPU-Performance-Cluster"
        ],
        "CPU Efficiency Cluster": [
            .english: "CPU Efficiency Cluster",
            .turkish: "CPU Verimlilik Çekirdekleri",
            .german: "CPU-Effizienz-Cluster"
        ],
        "GPU Cluster": [
            .english: "GPU Cluster",
            .turkish: "GPU Kümesi",
            .german: "GPU-Cluster"
        ],
        "Apple Neural Engine": [
            .english: "Apple Neural Engine",
            .turkish: "Yapay Sinir Motoru (ANE)",
            .german: "Apple Neural Engine"
        ],
        "PMU Controller": [
            .english: "PMU Controller",
            .turkish: "PMU Güç Denetleyicisi",
            .german: "PMU-Controller"
        ],
        "Battery Pack": [
            .english: "Battery Pack",
            .turkish: "Batarya Bloğu",
            .german: "Akkupack"
        ],
        "SOC Temperature": [
            .english: "SOC Temperature",
            .turkish: "SOC Sıcaklığı",
            .german: "SOC-Temperatur"
        ],
        "PMU Core": [
            .english: "PMU Core",
            .turkish: "PMU Çekirdeği",
            .german: "PMU-Kern"
        ],
        "CPU Core Cluster": [
            .english: "CPU Core Cluster",
            .turkish: "CPU Çekirdek Kümesi",
            .german: "CPU-Kern-Cluster"
        ],
        "AC Connected": [
            .english: "AC Connected",
            .turkish: "Güç Kaynağına Bağlı",
            .german: "Netzteil angeschlossen"
        ],
        "Calculating": [
            .english: "Calculating",
            .turkish: "Hesaplanıyor",
            .german: "Berechnung läuft"
        ],
        "Show Main Window": [
            .english: "Show Main Window",
            .turkish: "Ana Pencereyi Göster",
            .german: "Hauptfenster anzeigen"
        ],
        "Quit": [
            .english: "Quit",
            .turkish: "Çıkış",
            .german: "Beenden"
        ],
        "AC Connected (Charging)": [
            .english: "AC Connected (Charging)",
            .turkish: "Güç Kaynağına Bağlı (Şarj Ediliyor)",
            .german: "Netzteil angeschlossen (Wird geladen)"
        ]
    ]
    
    func localizedString(_ key: String) -> String {
        guard let entry = translations[key] else { return key }
        return entry[currentLanguage] ?? entry[.english] ?? key
    }
}

// Global Extension helper
extension String {
    var localized: String {
        return LanguageManager.shared.localizedString(self)
    }
}
