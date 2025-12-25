import SwiftUI

// MARK: - Get Started Screen
struct GetStartedScreen: View {
    @EnvironmentObject var authProvider: AuthProvider
    @State private var isAnimating = false
    @State private var showLogin = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("falla_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Top Logo
                    logoSection
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Girl Illustration
                    girlIllustration
                    
                    Spacer()
                    
                    // Welcome Text & Button
                    bottomSection
                        .padding(.bottom, 60)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginScreen()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        HStack(spacing: 10) {
            // Butterfly Logo
            Image(systemName: "leaf.fill")
                .font(.system(size: 28))
                .foregroundColor(AppColors.tealAccent)
                .rotationEffect(.degrees(-45))
            
            Text("Falla")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : -20)
    }
    
    // MARK: - Girl Illustration
    private var girlIllustration: some View {
        ZStack {
            // Soft glow behind
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
            
            // Girl Image
            Image("falla_girl")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 280, height: 280)
        }
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1 : 0.8)
    }
    
    // MARK: - Bottom Section
    private var bottomSection: some View {
        VStack(spacing: 16) {
            // Welcome Title
            Text("Welcome to Falla")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            // Subtitle
            Text("Your personal space\nmental health & self-care")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer()
                .frame(height: 32)
            
            // Get Started Button
            Button(action: {
                showLogin = true
            }) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#4A5568"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            }
            .padding(.horizontal, 40)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 30)
    }
}

#Preview {
    GetStartedScreen()
        .environmentObject(AuthProvider())
        .environmentObject(ThemeProvider())
}
