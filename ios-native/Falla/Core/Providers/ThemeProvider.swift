import Foundation
import SwiftUI
import Combine

// MARK: - Theme Provider
class ThemeProvider: ObservableObject {
    @Published var isDarkMode: Bool = true
    @Published var selectedTheme: AppTheme = .mystic
    
    init() {
        // Load saved theme preference
        loadThemePreference()
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        saveThemePreference()
    }
    
    func setTheme(_ theme: AppTheme) {
        selectedTheme = theme
        saveThemePreference()
    }
    
    private func loadThemePreference() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if let themeRaw = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: themeRaw) {
            selectedTheme = theme
        }
    }
    
    private func saveThemePreference() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
    }
}

// MARK: - App Theme
enum AppTheme: String, CaseIterable {
    case mystic = "mystic"
    case cosmic = "cosmic"
    case nature = "nature"
    case ocean = "ocean"
    
    var displayName: String {
        switch self {
        case .mystic: return "Mistik"
        case .cosmic: return "Kozmik"
        case .nature: return "Doğa"
        case .ocean: return "Okyanus"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .mystic: return AppColors.mysticPurple
        case .cosmic: return Color(hex: "#1E3A8A")
        case .nature: return Color(hex: "#059669")
        case .ocean: return Color(hex: "#0891B2")
        }
    }
}
