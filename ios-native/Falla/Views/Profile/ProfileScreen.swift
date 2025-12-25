import SwiftUI

// MARK: - Profile Screen
struct ProfileScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @State private var animateContent = false
    @State private var showEditProfile = false
    @State private var showDeleteAlert = false
    @State private var showSignOutAlert = false
    @State private var isDarkMode = true
    
    var body: some View {
        ZStack {
            // Background
            Image("theme_purple")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile Card
                        profileCard
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Stats Card
                        statsCard
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                        
                        // Settings Section
                        settingsSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 40)
                        
                        // Theme Settings
                        themeSection
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 50)
                        
                        // Action Buttons
                        actionButtons
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 60)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadUserData()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileScreen(user: viewModel.user)
        }
        .alert("Hesabı Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("Bu işlem geri alınamaz. Tüm verileriniz silinecek.")
        }
        .alert("Çıkış Yap", isPresented: $showSignOutAlert) {
            Button("İptal", role: .cancel) {}
            Button("Çıkış Yap", role: .destructive) {
                viewModel.signOut()
            }
        } message: {
            Text("Hesabınızdan çıkış yapılacak.")
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.4), Color(hex: "#7B8CDE").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: Color(hex: "#C97CF6").opacity(0.3), radius: 15)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            Text("Profil")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: "#C97CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
    
    // MARK: - Profile Card
    private var profileCard: some View {
        VStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#C97CF6").opacity(0.5), radius: 20)
                
                if let firstLetter = viewModel.user?.name.first {
                    Text(String(firstLetter).uppercased())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
            }
            
            // Name
            Text(viewModel.user?.name ?? "Misafir")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Email
            if let email = viewModel.user?.email {
                Text(email)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Karma Badge
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                
                Text("\(viewModel.user?.karma ?? 0) Karma")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Color(hex: "#FFD700"))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(hex: "#FFD700").opacity(0.15))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color(hex: "#FFD700").opacity(0.4), lineWidth: 1)
            )
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.5), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    // MARK: - Stats Card
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("İstatistikler")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statItem(
                    title: "Toplam Fal",
                    value: "\(viewModel.totalFortunes)",
                    icon: "sparkles",
                    color: "#C97CF6"
                )
                
                statItem(
                    title: "Favoriler",
                    value: "\(viewModel.favoriteFortunes)",
                    icon: "heart.fill",
                    color: "#EC4899"
                )
                
                statItem(
                    title: "Üyelik",
                    value: formatMemberDate(viewModel.user?.createdAt),
                    icon: "calendar",
                    color: "#3B82F6"
                )
                
                statItem(
                    title: "Son Giriş",
                    value: formatLastLogin(viewModel.user?.lastLoginAt),
                    icon: "clock",
                    color: "#10B981"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func statItem(title: String, value: String, icon: String, color: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: color).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: color))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ayarlar")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                settingsRow(icon: "globe", title: "Dil", value: "Türkçe") {
                    // Language action
                }
                
                settingsRow(icon: "hand.raised.fill", title: "Gizlilik", value: nil) {
                    // Privacy action
                }
                
                settingsRow(icon: "questionmark.circle", title: "Yardım", value: nil) {
                    // Help action
                }
                
                settingsRow(icon: "info.circle", title: "Hakkında", value: "v1.0.0") {
                    // About action
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func settingsRow(icon: String, title: String, value: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#C97CF6").opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#C97CF6"))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    // MARK: - Theme Section
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tema Ayarları")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#C97CF6").opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#C97CF6"))
                }
                
                Text(isDarkMode ? "Karanlık Tema" : "Aydınlık Tema")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $isDarkMode)
                    .tint(Color(hex: "#C97CF6"))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Edit Profile
            actionButton(
                title: "Profili Düzenle",
                icon: "pencil",
                color: Color(hex: "#C97CF6")
            ) {
                showEditProfile = true
            }
            
            // Delete Account
            actionButton(
                title: "Hesabı Sil",
                icon: "trash",
                color: .red
            ) {
                showDeleteAlert = true
            }
            
            // Sign Out
            actionButton(
                title: "Çıkış Yap",
                icon: "rectangle.portrait.and.arrow.right",
                color: .red.opacity(0.8)
            ) {
                showSignOutAlert = true
            }
        }
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#C97CF6")))
                    .scaleEffect(1.5)
                
                Text("Yükleniyor...")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    // MARK: - Helpers
    private func formatMemberDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatLastLogin(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Bugün"
        } else if calendar.isDateInYesterday(date) {
            return "Dün"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: date)
        }
    }
}

// MARK: - Profile View Model
class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    @Published var isLoading = false
    @Published var totalFortunes = 0
    @Published var favoriteFortunes = 0
    
    func loadUserData() {
        isLoading = true
        
        // Simulate loading from Firebase/Backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.user = UserProfile(
                id: "user_123",
                name: "Kullanıcı",
                email: "kullanici@email.com",
                karma: 150,
                createdAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()),
                lastLoginAt: Date()
            )
            self.totalFortunes = 24
            self.favoriteFortunes = 8
            self.isLoading = false
        }
    }
    
    func signOut() {
        isLoading = true
        // Call Firebase signOut
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.user = nil
            self.isLoading = false
        }
    }
    
    func deleteAccount() {
        isLoading = true
        // Call Firebase deleteAccount
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.user = nil
            self.isLoading = false
        }
    }
}

// MARK: - User Profile Model
struct UserProfile {
    let id: String
    let name: String
    let email: String?
    let karma: Int
    let createdAt: Date?
    let lastLoginAt: Date?
}

#Preview {
    ProfileScreen()
}
