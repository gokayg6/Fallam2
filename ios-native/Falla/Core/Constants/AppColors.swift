import SwiftUI

// MARK: - App Colors
struct AppColors {
    // Primary Colors
    static let primary = Color(hex: "#8B5CF6")
    static let secondary = Color(hex: "#6366F1")
    static let accent = Color(hex: "#EC4899")
    
    // Mystic Theme Colors
    static let mysticPurple = Color(hex: "#7C3AED")
    static let mysticPurpleAccent = Color(hex: "#A855F7")
    static let mysticMagenta = Color(hex: "#D946EF")
    static let mysticLavender = Color(hex: "#C4B5FD")
    static let mysticDeepPurple = Color(hex: "#4C1D95")
    
    // Background Colors
    static let background = Color(hex: "#0F0A1A")
    static let surface = Color(hex: "#1A1425")
    static let cardBackground = Color(hex: "#1F1730")
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    
    // Gradient Colors
    static let gradientStart = Color(hex: "#7B8CDE")
    static let gradientMiddle = Color(hex: "#8B7FD3")
    static let gradientEnd = Color(hex: "#A78BDA")
    
    // Teal/Cyan for logo
    static let tealAccent = Color(hex: "#5BC4BE")
    
    // Premium Gradient
    static var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [gradientStart, gradientMiddle, gradientEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // Background Gradient
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#1A0B2E"),
                Color(hex: "#16082A"),
                Color(hex: "#0F0A1A")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
