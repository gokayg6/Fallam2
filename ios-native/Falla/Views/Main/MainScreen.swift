import SwiftUI

// MARK: - Main Screen with Tab Navigation
struct MainScreen: View {
    @EnvironmentObject var authProvider: AuthProvider
    @State private var selectedTab: Int = 0
    
    private let navItems: [NavBarItem] = [
        NavBarItem(icon: "house", activeIcon: "house.fill", title: "Ana Sayfa"),
        NavBarItem(icon: "sparkles", activeIcon: "sparkles", title: "Fal"),
        NavBarItem(icon: "star", activeIcon: "star.fill", title: "Astroloji"),
        NavBarItem(icon: "person.2", activeIcon: "person.2.fill", title: "Sosyal"),
        NavBarItem(icon: "person", activeIcon: "person.fill", title: "Profil")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Image("app_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Tab Content
            VStack(spacing: 0) {
                // Current Tab View
                TabView(selection: $selectedTab) {
                    HomeTabView()
                        .tag(0)
                    
                    FortuneTabView()
                        .tag(1)
                    
                    AstrologyTabView()
                        .tag(2)
                    
                    SocialTabView()
                        .tag(3)
                    
                    ProfileTabView()
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Floating Glass Nav Bar
                FloatingGlassNavBar(
                    selectedTab: $selectedTab,
                    items: navItems
                )
            }
        }
    }
}

// MARK: - Home Tab View
struct HomeTabView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HomeHeaderView()
                    .padding(.top, 16)
                
                // Fortune Types Section
                FortuneTypesSection()
                
                // Biorhythm Section
                BiorhythmSection()
                
                // Daily Horoscope Section
                DailyHoroscopeSection()
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Home Header View
struct HomeHeaderView: View {
    var body: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.tealAccent)
                    .rotationEffect(.degrees(-45))
                
                Text("Falla")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Karma Display
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                
                Text("52")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Fortune Types Section
struct FortuneTypesSection: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title
            HStack {
                Text("Fal Türleri")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Image(systemName: "sparkle")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
            }
            
            // Fortune Cards Grid
            LazyVGrid(columns: columns, spacing: 12) {
                FortuneTypeCard(
                    title: "Kahve Falı",
                    icon: "cup.and.saucer.fill",
                    gradient: [Color(hex: "#E8A87C"), Color(hex: "#C38D6A")],
                    imageName: "icon_coffee"
                )
                
                FortuneTypeCard(
                    title: "Tarot",
                    icon: "rectangle.stack.fill",
                    gradient: [Color(hex: "#C97CF6"), Color(hex: "#9B59B6")],
                    imageName: "icon_tarot"
                )
                
                FortuneTypeCard(
                    title: "El Falı",
                    icon: "hand.raised.fill",
                    gradient: [Color(hex: "#F5A9B8"), Color(hex: "#E87E95")],
                    imageName: "icon_palm"
                )
                
                FortuneTypeCard(
                    title: "Katina Falı",
                    icon: "sparkles",
                    gradient: [Color(hex: "#87CEEB"), Color(hex: "#5DADE2")],
                    imageName: "icon_katina"
                )
            }
        }
    }
}

// MARK: - Fortune Type Card
struct FortuneTypeCard: View {
    let title: String
    let icon: String
    let gradient: [Color]
    var imageName: String? = nil
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                    
                    if let imageName = imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 28))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        gradient[0].opacity(0.2),
                                        gradient[1].opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Biorhythm Section
struct BiorhythmSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Biyoritim")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                // Physical
                BiorhythmIndicator(
                    label: "Fiziksel",
                    value: 56,
                    icon: "figure.walk",
                    color: Color(hex: "#4FC3F7")
                )
                
                // Emotional
                BiorhythmIndicator(
                    label: "Duygusal",
                    value: 1,
                    icon: "heart.fill",
                    color: Color(hex: "#F48FB1")
                )
                
                // Circular Score
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.52)
                        .stroke(
                            AngularGradient(
                                colors: [.green, .yellow, .orange, .red],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("52")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("Ort")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Biorhythm Indicator
struct BiorhythmIndicator: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Daily Horoscope Section
struct DailyHoroscopeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Günlük Burç Yorumu")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            // Horoscope Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                    
                    Text("Koç")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Bugün")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text("Bugün enerjiniz yüksek olacak. Yeni başlangıçlar için harika bir gün...")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                Button(action: {}) {
                    Text("Devamını Oku")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.tealAccent)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Fortune Tab View
struct FortuneTabView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Fal Türleri")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // All Fortune Types
                FortuneListSection()
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Fortune List Section
struct FortuneListSection: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            FortuneTypeCard(
                title: "Kahve Falı",
                icon: "cup.and.saucer.fill",
                gradient: [Color(hex: "#E8A87C"), Color(hex: "#C38D6A")],
                imageName: "icon_coffee"
            )
            
            FortuneTypeCard(
                title: "Tarot",
                icon: "rectangle.stack.fill",
                gradient: [Color(hex: "#C97CF6"), Color(hex: "#9B59B6")],
                imageName: "icon_tarot"
            )
            
            FortuneTypeCard(
                title: "El Falı",
                icon: "hand.raised.fill",
                gradient: [Color(hex: "#F5A9B8"), Color(hex: "#E87E95")],
                imageName: "icon_palm"
            )
            
            FortuneTypeCard(
                title: "Katina Falı",
                icon: "sparkles",
                gradient: [Color(hex: "#87CEEB"), Color(hex: "#5DADE2")],
                imageName: "icon_katina"
            )
            
            FortuneTypeCard(
                title: "Yüz Analizi",
                icon: "face.smiling",
                gradient: [Color(hex: "#98D98E"), Color(hex: "#7CB342")],
                imageName: "icon_face"
            )
            
            FortuneTypeCard(
                title: "Rüya Yorumu",
                icon: "moon.stars.fill",
                gradient: [Color(hex: "#7986CB"), Color(hex: "#5C6BC0")],
                imageName: "icon_water"
            )
        }
    }
}

// MARK: - Astrology Tab View
struct AstrologyTabView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Text("Astroloji")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Zodiac Signs Grid
                ZodiacSignsGrid()
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Zodiac Signs Grid
struct ZodiacSignsGrid: View {
    let signs = [
        ("Koç", "♈️"), ("Boğa", "♉️"), ("İkizler", "♊️"),
        ("Yengeç", "♋️"), ("Aslan", "♌️"), ("Başak", "♍️"),
        ("Terazi", "♎️"), ("Akrep", "♏️"), ("Yay", "♐️"),
        ("Oğlak", "♑️"), ("Kova", "♒️"), ("Balık", "♓️")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(signs, id: \.0) { sign in
                ZodiacCard(name: sign.0, symbol: sign.1)
            }
        }
    }
}

// MARK: - Zodiac Card
struct ZodiacCard: View {
    let name: String
    let symbol: String
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Text(symbol)
                    .font(.system(size: 36))
                
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Social Tab View
struct SocialTabView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Text("Sosyal")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.pink)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // Love Compatibility
                SocialFeatureCard(
                    title: "Aşk Uyumu",
                    subtitle: "Ruh eşinizi bulun",
                    icon: "heart.circle.fill",
                    gradient: [Color(hex: "#FF6B9D"), Color(hex: "#C44569")]
                )
                
                // Soulmate Analysis
                SocialFeatureCard(
                    title: "Ruh Eşi Analizi",
                    subtitle: "Detaylı uyum raporu",
                    icon: "person.2.circle.fill",
                    gradient: [Color(hex: "#A29BFE"), Color(hex: "#6C5CE7")]
                )
                
                // Live Chat
                SocialFeatureCard(
                    title: "Canlı Sohbet",
                    subtitle: "Topluluğa katılın",
                    icon: "bubble.left.and.bubble.right.fill",
                    gradient: [Color(hex: "#74B9FF"), Color(hex: "#0984E3")]
                )
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Social Feature Card
struct SocialFeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Tab View
struct ProfileTabView: View {
    @EnvironmentObject var authProvider: AuthProvider
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Profile Header
                ProfileHeaderView()
                    .padding(.top, 20)
                
                // Settings Options
                ProfileSettingsSection()
                
                // Sign Out Button
                Button(action: {
                    authProvider.signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18))
                        Text("Çıkış Yap")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A78BDA"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            
            // Name
            Text("Kullanıcı")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Email
            Text("user@example.com")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            // Stats Row
            HStack(spacing: 40) {
                ProfileStatView(value: "52", label: "Karma")
                ProfileStatView(value: "12", label: "Fal")
                ProfileStatView(value: "3", label: "Gün")
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

// MARK: - Profile Stat View
struct ProfileStatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Profile Settings Section
struct ProfileSettingsSection: View {
    var body: some View {
        VStack(spacing: 12) {
            ProfileSettingRow(icon: "person.fill", title: "Profili Düzenle")
            ProfileSettingRow(icon: "bell.fill", title: "Bildirimler")
            ProfileSettingRow(icon: "lock.fill", title: "Gizlilik")
            ProfileSettingRow(icon: "questionmark.circle.fill", title: "Yardım")
            ProfileSettingRow(icon: "info.circle.fill", title: "Hakkında")
        }
    }
}

// MARK: - Profile Setting Row
struct ProfileSettingRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainScreen()
        .environmentObject(AuthProvider())
        .environmentObject(ThemeProvider())
}
