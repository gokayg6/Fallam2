import SwiftUI

// MARK: - View Extensions for Liquid Glass Effects
extension View {
    
    // MARK: - Glass Circle Button Modifier
    @ViewBuilder
    func glassCircleButton(size: CGFloat = 44) -> some View {
        self
            .frame(width: size, height: size)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    // MARK: - Glass Card Modifier
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Liquid Glass Effect (iOS 26+)
    @ViewBuilder
    func liquidGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect()
        } else {
            self.glassCard()
        }
    }
    
    // MARK: - Action Icon Modifier
    func actionIcon(size: CGFloat = 24, color: Color = .white) -> some View {
        self
            .font(.system(size: size, weight: .medium))
            .foregroundColor(color)
    }
    
    // MARK: - Glass Text Field Style
    @ViewBuilder
    func glassTextField() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    // MARK: - Gradient Button Modifier
    @ViewBuilder
    func gradientButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "#7B8CDE"),
                        Color(hex: "#8B7FD3"),
                        Color(hex: "#A78BDA")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(hex: "#8B7FD3").opacity(0.4), radius: 20, x: 0, y: 8)
    }
}
