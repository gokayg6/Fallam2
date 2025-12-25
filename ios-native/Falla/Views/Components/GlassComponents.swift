import SwiftUI

// MARK: - Glass Text Field Component
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            
            // Text Field
            if isSecure && !isPasswordVisible {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                    .foregroundColor(.white)
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            // Password Toggle
            if isSecure {
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Glass Button Component
struct GlassButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    var style: ButtonStyle = .gradient
    let action: () -> Void
    
    enum ButtonStyle {
        case gradient
        case white
        case outline
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style == .white ? Color(hex: "#4A5568") : .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                    }
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundView)
            .cornerRadius(16)
            .overlay(overlayView)
            .shadow(color: shadowColor, radius: 20, x: 0, y: 8)
        }
        .disabled(isLoading)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .gradient: return .white
        case .white: return Color(hex: "#4A5568")
        case .outline: return .white.opacity(0.9)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .gradient:
            LinearGradient(
                colors: [
                    Color(hex: "#7B8CDE"),
                    Color(hex: "#8B7FD3"),
                    Color(hex: "#A78BDA")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .white:
            Color.white
        case .outline:
            Color.clear
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if style == .outline {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
        } else {
            EmptyView()
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .gradient: return Color(hex: "#8B7FD3").opacity(0.4)
        case .white: return .black.opacity(0.1)
        case .outline: return .clear
        }
    }
}

// MARK: - Google Sign In Button
struct GoogleSignInButton: View {
    var title: String = "Sign Up with Google"
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Google "G" icon
                Text("G")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#4285F4"))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#4A5568"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 16) {
            GlassTextField(
                placeholder: "Email",
                text: .constant(""),
                icon: "envelope"
            )
            
            GlassTextField(
                placeholder: "Password",
                text: .constant(""),
                icon: "lock",
                isSecure: true
            )
            
            GlassButton(title: "Sign Up", style: .gradient) {}
            
            GoogleSignInButton {}
            
            GlassButton(title: "Continue as Guest", icon: "person", style: .outline) {}
        }
        .padding()
    }
}
