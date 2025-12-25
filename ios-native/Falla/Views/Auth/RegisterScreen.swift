import SwiftUI

// MARK: - Register Screen (Create Your Account)
struct RegisterScreen: View {
    @EnvironmentObject var authProvider: AuthProvider
    @Environment(\.dismiss) private var dismiss
    @Namespace private var glassNamespace
    
    // Form State
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    // UI State
    @State private var isAnimating = false
    @State private var showLogin = false
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Bar
                    topBar
                        .padding(.top, 16)
                    
                    // Title
                    titleSection
                        .padding(.top, 24)
                    
                    // Glass Form Container
                    glassFormContainer
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                    
                    // Terms Text
                    termsText
                        .padding(.top, 24)
                        .padding(.horizontal, 40)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showLogin) {
            LoginScreen()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Image("login_background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .glassCircleButton(size: 40)
            }
            
            Spacer()
            
            // Logo
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.tealAccent)
                    .rotationEffect(.degrees(-45))
                
                Text("Falla")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Profile Placeholder
            Image(systemName: "person")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .glassCircleButton(size: 40)
        }
        .padding(.horizontal, 20)
        .opacity(isAnimating ? 1 : 0)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        Text("Create Your\nAccount")
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
    }
    
    // MARK: - Glass Form Container
    private var glassFormContainer: some View {
        VStack(spacing: 16) {
            // Full Name Field
            GlassTextField(
                placeholder: "Full Name",
                text: $fullName,
                icon: "person"
            )
            
            // Email Field
            GlassTextField(
                placeholder: "Email",
                text: $email,
                icon: "envelope"
            )
            
            // Password Field
            GlassTextField(
                placeholder: "Password",
                text: $password,
                icon: "lock",
                isSecure: true
            )
            
            Spacer().frame(height: 8)
            
            // Sign Up Button
            GlassButton(
                title: "Sign Up",
                isLoading: authProvider.isLoading,
                style: .gradient
            ) {
                Task {
                    await signUp()
                }
            }
            
            // Divider
            dividerSection
                .padding(.vertical, 4)
            
            // Google Sign Up
            GoogleSignInButton(title: "Sign Up with Google") {
                Task {
                    await signUpWithGoogle()
                }
            }
        }
        .padding(24)
        .glassCard(cornerRadius: 24)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 30)
    }
    
    // MARK: - Divider Section
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
            
            Text("Or sign up with")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 16)
            
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
        }
    }
    
    // MARK: - Terms Text
    private var termsText: some View {
        VStack(spacing: 4) {
            Text("By signing up, you agree to our ")
                .foregroundColor(.white.opacity(0.7))
            +
            Text("Terms of Service")
                .foregroundColor(Color(hex: "#8BB8F8"))
                .underline()
            
            Text("and ")
                .foregroundColor(.white.opacity(0.7))
            +
            Text("Privacy Policy")
                .foregroundColor(Color(hex: "#8BB8F8"))
                .underline()
        }
        .font(.system(size: 13))
        .multilineTextAlignment(.center)
        .opacity(isAnimating ? 1 : 0)
    }
    
    // MARK: - Actions
    private func signUp() async {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else { return }
        
        let success = await authProvider.signUpWithEmail(
            email: email,
            password: password,
            displayName: fullName
        )
        
        if success {
            // Navigate to main screen
        }
    }
    
    private func signUpWithGoogle() async {
        let _ = await authProvider.signInWithGoogle()
    }
}

#Preview {
    NavigationStack {
        RegisterScreen()
            .environmentObject(AuthProvider())
            .environmentObject(ThemeProvider())
    }
}
