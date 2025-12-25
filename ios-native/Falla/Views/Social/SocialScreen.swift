import SwiftUI

// MARK: - Social Screen
struct SocialScreen: View {
    @State private var selectedTab = 0
    @State private var isLoading = true
    @State private var animateContent = false
    @State private var matches: [ChatMatch] = []
    @State private var pendingRequests: [SocialRequest] = []
    @State private var blockedUsers: [BlockedUser] = []
    @State private var socialVisibility = true
    
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
                
                // Tab Bar
                tabBar
                    .padding(.top, 8)
                
                // Content
                TabView(selection: $selectedTab) {
                    requestsTab
                        .tag(0)
                    
                    chatTab
                        .tag(1)
                    
                    privacyTab
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            loadData()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                animateContent = true
            }
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
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            Text("Sosyal")
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
    
    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                tabButton(
                    index: index,
                    icon: tabIcon(for: index),
                    title: tabTitle(for: index),
                    badge: tabBadge(for: index)
                )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#C97CF6").opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
    
    private func tabButton(index: Int, icon: String, title: String, badge: Int) -> some View {
        Button(action: { 
            withAnimation(.spring(response: 0.3)) {
                selectedTab = index 
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if selectedTab == index {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(hex: "#C97CF6").opacity(0.4), radius: 10)
                    }
                }
            )
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "heart.fill"
        case 1: return "bubble.left.fill"
        case 2: return "hand.raised.fill"
        default: return "heart.fill"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "İstekler"
        case 1: return "Sohbet"
        case 2: return "Gizlilik"
        default: return ""
        }
    }
    
    private func tabBadge(for index: Int) -> Int {
        switch index {
        case 0: return pendingRequests.count
        case 1: return matches.count
        default: return 0
        }
    }
    
    // MARK: - Requests Tab
    private var requestsTab: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Aura Match Section
                auraMatchSection
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                
                // Pending Requests
                if !pendingRequests.isEmpty {
                    pendingRequestsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .refreshable {
            await refreshData()
        }
    }
    
    // MARK: - Aura Match Section
    private var auraMatchSection: some View {
        VStack(spacing: 20) {
            // Aura Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "#C97CF6").opacity(0.5), radius: 20)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            Text("Aura Eşleşme")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text("Aura frekansına göre sana en uygun kişileri bul")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: SoulmateAnalysisScreen()) {
                HStack(spacing: 10) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 16))
                    Text("Ruh Eşini Bul")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "#C97CF6").opacity(0.4), radius: 15, y: 5)
            }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.4), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    // MARK: - Pending Requests Section
    private var pendingRequestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Bekleyen İstekler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(pendingRequests.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#C97CF6").opacity(0.5))
                    .clipShape(Capsule())
            }
            
            ForEach(pendingRequests) { request in
                RequestCard(request: request, onAccept: {
                    acceptRequest(request)
                }, onReject: {
                    rejectRequest(request)
                })
            }
        }
    }
    
    // MARK: - Chat Tab
    private var chatTab: some View {
        ScrollView(showsIndicators: false) {
            if matches.isEmpty {
                emptyStateView(
                    icon: "bubble.left.and.bubble.right",
                    title: "Henüz Eşleşme Yok",
                    subtitle: "Aura eşleşme ile yeni insanlarla tanış"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(matches) { match in
                        NavigationLink(destination: ChatDetailScreen(match: match)) {
                            ChatMatchCard(match: match)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .padding(.bottom, 100)
    }
    
    // MARK: - Privacy Tab
    private var privacyTab: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Visibility Toggle
                privacyToggleCard
                
                // Blocked Users
                blockedUsersSection
                
                // Privacy Info
                privacyInfoCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 100)
        }
    }
    
    private var privacyToggleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#C97CF6").opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "eye")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#C97CF6"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sosyal Görünürlük")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Diğer kullanıcılar seni görebilsin")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Toggle("", isOn: $socialVisibility)
                    .tint(Color(hex: "#C97CF6"))
            }
            
            // Status
            HStack(spacing: 8) {
                Image(systemName: socialVisibility ? "checkmark.circle.fill" : "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#C97CF6"))
                
                Text(socialVisibility ? "Profilin görünür durumda" : "Profilin gizli durumda")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#C97CF6").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.2))
            }
        )
    }
    
    private var blockedUsersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                }
                
                Text("Engellenen Kullanıcılar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(blockedUsers.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            if blockedUsers.isEmpty {
                Text("Engellenen kullanıcı yok")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(blockedUsers) { user in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(user.name.prefix(1))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                        
                        Text(user.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { unblockUser(user) }) {
                            Text("Engeli Kaldır")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#C97CF6"))
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.2))
            }
        )
    }
    
    private var privacyInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#C97CF6"))
                
                Text("Gizlilik Politikası")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Verileriniz güvenli bir şekilde saklanmaktadır. Kişisel bilgileriniz üçüncü şahıslarla paylaşılmaz.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 8) {
                privacyPoint("Mesajlarınız şifrelenir")
                privacyPoint("Fotoğraflarınız güvenli sunucularda saklanır")
                privacyPoint("İstediğiniz zaman hesabınızı silebilirsiniz")
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.2))
            }
        )
    }
    
    private func privacyPoint(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#10B981"))
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // MARK: - Empty State
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "#C97CF6").opacity(0.5))
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Data Functions
    private func loadData() {
        isLoading = true
        
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Demo data
            pendingRequests = [
                SocialRequest(id: "1", userId: "u1", userName: "Elif", auraColor: "#C97CF6", score: 85, createdAt: Date()),
                SocialRequest(id: "2", userId: "u2", userName: "Ahmet", auraColor: "#7B8CDE", score: 72, createdAt: Date())
            ]
            
            matches = [
                ChatMatch(id: "m1", userId: "u3", userName: "Zeynep", auraColor: "#C97CF6", lastMessage: "Merhaba! 👋", lastMessageTime: Date()),
                ChatMatch(id: "m2", userId: "u4", userName: "Can", auraColor: "#10B981", lastMessage: "Nasılsın?", lastMessageTime: Date().addingTimeInterval(-3600))
            ]
            
            isLoading = false
        }
    }
    
    private func refreshData() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loadData()
    }
    
    private func acceptRequest(_ request: SocialRequest) {
        pendingRequests.removeAll { $0.id == request.id }
        matches.append(ChatMatch(
            id: UUID().uuidString,
            userId: request.userId,
            userName: request.userName,
            auraColor: request.auraColor,
            lastMessage: "Yeni eşleşme! 🎉",
            lastMessageTime: Date()
        ))
    }
    
    private func rejectRequest(_ request: SocialRequest) {
        pendingRequests.removeAll { $0.id == request.id }
    }
    
    private func unblockUser(_ user: BlockedUser) {
        blockedUsers.removeAll { $0.id == user.id }
    }
}

// MARK: - Models
struct SocialRequest: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let auraColor: String
    let score: Int
    let createdAt: Date
}

struct ChatMatch: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let auraColor: String
    let lastMessage: String
    let lastMessageTime: Date
}

struct BlockedUser: Identifiable {
    let id: String
    let name: String
}

// MARK: - Request Card
struct RequestCard: View {
    let request: SocialRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: request.auraColor).opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Text(request.userName.prefix(1))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: request.auraColor))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(request.userName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("\(request.score)% uyum")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: request.auraColor))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onReject) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                        .frame(width: 36, height: 36)
                        .background(Color.green.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: request.auraColor).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Chat Match Card
struct ChatMatchCard: View {
    let match: ChatMatch
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: match.auraColor).opacity(0.3))
                    .frame(width: 54, height: 54)
                
                Text(match.userName.prefix(1))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: match.auraColor))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(match.userName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(match.lastMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatTime(match.lastMessageTime))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        SocialScreen()
    }
}
