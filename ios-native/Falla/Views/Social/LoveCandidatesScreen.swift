import SwiftUI

// MARK: - Love Candidates Screen
struct LoveCandidatesScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var candidates: [LoveCandidate] = []
    @State private var isLoading = true
    @State private var animateContent = false
    @State private var selectedFilter: CandidateFilter = .all
    
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
                
                // Filter Pills
                filterBar
                
                // Content
                if isLoading {
                    loadingView
                } else if candidates.isEmpty {
                    emptyView
                } else {
                    candidatesList
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadCandidates()
            withAnimation(.spring(response: 0.6).delay(0.2)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Aşk Adayları")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(candidates.count) potansiyel eşleşme")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            NavigationLink(destination: LoveCandidateFormScreen()) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CandidateFilter.allCases, id: \.self) { filter in
                    FilterPill(
                        title: filter.title,
                        isSelected: selectedFilter == filter,
                        onTap: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Candidates List
    private var candidatesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(filteredCandidates) { candidate in
                    CandidateCard(candidate: candidate)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
    
    private var filteredCandidates: [LoveCandidate] {
        switch selectedFilter {
        case .all:
            return candidates
        case .highMatch:
            return candidates.filter { $0.matchScore >= 80 }
        case .nearby:
            return candidates.filter { $0.distance <= 10 }
        case .online:
            return candidates.filter { $0.isOnline }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#C97CF6")))
                .scaleEffect(1.5)
            
            Text("Adaylar yükleniyor...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "#C97CF6").opacity(0.5))
            
            Text("Henüz Aday Yok")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Yeni aday ekleyerek başla")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            NavigationLink(destination: LoveCandidateFormScreen()) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Aday Ekle")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Data
    private func loadCandidates() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            candidates = [
                LoveCandidate(id: "1", name: "Elif", age: 24, zodiac: "Kova", auraColor: "#C97CF6", matchScore: 92, distance: 5, isOnline: true, bio: "Hayatı seven, pozitif enerji sahibi"),
                LoveCandidate(id: "2", name: "Zeynep", age: 26, zodiac: "Balık", auraColor: "#7B8CDE", matchScore: 87, distance: 8, isOnline: true, bio: "Kitap kurdu ve kahve tutkunu"),
                LoveCandidate(id: "3", name: "Merve", age: 23, zodiac: "Yay", auraColor: "#10B981", matchScore: 84, distance: 12, isOnline: false, bio: "Macera arıyorum 🌍"),
                LoveCandidate(id: "4", name: "Ayşe", age: 25, zodiac: "Terazi", auraColor: "#F59E0B", matchScore: 78, distance: 3, isOnline: false, bio: "Sanat ve müzik aşığı"),
                LoveCandidate(id: "5", name: "Selin", age: 27, zodiac: "Aslan", auraColor: "#EF4444", matchScore: 75, distance: 15, isOnline: true, bio: "Fitness ve sağlıklı yaşam")
            ]
            isLoading = false
        }
    }
}

// MARK: - Models
struct LoveCandidate: Identifiable {
    let id: String
    let name: String
    let age: Int
    let zodiac: String
    let auraColor: String
    let matchScore: Int
    let distance: Int
    let isOnline: Bool
    let bio: String
}

enum CandidateFilter: CaseIterable {
    case all, highMatch, nearby, online
    
    var title: String {
        switch self {
        case .all: return "Tümü"
        case .highMatch: return "Yüksek Uyum"
        case .nearby: return "Yakındakiler"
        case .online: return "Çevrimiçi"
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                )
        }
    }
}

// MARK: - Candidate Card
struct CandidateCard: View {
    let candidate: LoveCandidate
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(Color(hex: candidate.auraColor).opacity(0.3))
                        .frame(width: 64, height: 64)
                    
                    Text(candidate.name.prefix(1))
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(hex: candidate.auraColor))
                }
                
                // Online indicator
                if candidate.isOnline {
                    Circle()
                        .fill(Color(hex: "#10B981"))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(candidate.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(candidate.age)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                HStack(spacing: 8) {
                    Label(candidate.zodiac, systemImage: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: candidate.auraColor))
                    
                    Label("\(candidate.distance) km", systemImage: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Text(candidate.bio)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Match Score
            VStack(spacing: 4) {
                Text("\(candidate.matchScore)%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(scoreColor)
                
                Text("uyum")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: candidate.auraColor).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var scoreColor: Color {
        if candidate.matchScore >= 85 {
            return Color(hex: "#10B981")
        } else if candidate.matchScore >= 70 {
            return Color(hex: "#F59E0B")
        } else {
            return Color(hex: "#EF4444")
        }
    }
}

#Preview {
    NavigationStack {
        LoveCandidatesScreen()
    }
}
