import SwiftUI

// MARK: - Fortune History Screen
struct FortuneHistoryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FortuneHistoryViewModel()
    @State private var selectedFilter: FortuneFilter = .all
    @State private var selectedSort: FortuneSort = .newest
    
    var body: some View {
        ZStack {
            // Background - Purple Theme
            Image("theme_purple")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Dark overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 16)
                
                // Filters
                filtersSection
                    .padding(.top, 16)
                
                // Fortune List
                if viewModel.isLoading {
                    Spacer()
                    loadingView
                    Spacer()
                } else if filteredFortunes.isEmpty {
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    fortunesList
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadFortunes()
        }
    }
    
    // MARK: - Filtered Fortunes
    private var filteredFortunes: [FortuneModel] {
        var fortunes = viewModel.fortunes
        
        // Apply filter
        if selectedFilter != .all {
            fortunes = fortunes.filter { $0.type == selectedFilter.fortuneType }
        }
        
        // Apply favorites filter
        if selectedSort == .favorites {
            fortunes = fortunes.filter { $0.isFavorite }
        }
        
        // Apply sorting
        switch selectedSort {
        case .newest:
            fortunes.sort { $0.createdAt > $1.createdAt }
        case .oldest:
            fortunes.sort { $0.createdAt < $1.createdAt }
        case .rating:
            fortunes.sort { $0.rating > $1.rating }
        case .favorites:
            fortunes.sort { $0.createdAt > $1.createdAt }
        }
        
        return fortunes
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .glassCircleButton(size: 40)
            }
            
            Spacer()
            
            Text("Fal Geçmişi")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Total count badge
            Text("\(viewModel.fortunes.count) fal")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(hex: "#A78BDA").opacity(0.5))
                )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Filters Section
    private var filtersSection: some View {
        VStack(spacing: 12) {
            // Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FortuneFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.title,
                            icon: filter.icon,
                            isSelected: selectedFilter == filter,
                            color: filter.color
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Sort Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FortuneSort.allCases, id: \.self) { sort in
                        SortChip(
                            title: sort.title,
                            icon: sort.icon,
                            isSelected: selectedSort == sort
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSort = sort
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Fallar yükleniyor...")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#A78BDA").opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text("Henüz Fal Yok")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text("İlk falınızı baktırın ve\nburada görüntüleyin")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 32)
    }
    
    // MARK: - Fortunes List
    private var fortunesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredFortunes.enumerated()), id: \.element.id) { index, fortune in
                    FortuneHistoryCard(fortune: fortune, index: index)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - View Model
class FortuneHistoryViewModel: ObservableObject {
    @Published var fortunes: [FortuneModel] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadFortunes() {
        isLoading = true
        
        // Simulated data for preview - replace with actual Firebase call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.fortunes = FortuneModel.sampleFortunes
            self?.isLoading = false
        }
        
        // TODO: Actual Firebase implementation
        // Task {
        //     do {
        //         let userId = FirebaseService.shared.currentUser?.uid ?? ""
        //         let fortunes = try await FirebaseService.shared.getUserFortunes(userId: userId)
        //         await MainActor.run {
        //             self.fortunes = fortunes
        //             self.isLoading = false
        //         }
        //     } catch {
        //         await MainActor.run {
        //             self.error = error.localizedDescription
        //             self.isLoading = false
        //         }
        //     }
        // }
    }
}

// MARK: - Fortune Filter
enum FortuneFilter: CaseIterable {
    case all
    case tarot
    case coffee
    case palm
    case astrology
    case dream
    
    var title: String {
        switch self {
        case .all: return "Tümü"
        case .tarot: return "Tarot"
        case .coffee: return "Kahve"
        case .palm: return "El Falı"
        case .astrology: return "Astroloji"
        case .dream: return "Rüya"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "infinity"
        case .tarot: return "rectangle.stack.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .palm: return "hand.raised.fill"
        case .astrology: return "star.fill"
        case .dream: return "moon.stars.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(hex: "#A78BDA")
        case .tarot: return Color(hex: "#C97CF6")
        case .coffee: return Color(hex: "#C4A477")
        case .palm: return Color(hex: "#9B8ED0")
        case .astrology: return Color(hex: "#E6D3A3")
        case .dream: return Color(hex: "#7C6FA8")
        }
    }
    
    var fortuneType: FortuneType? {
        switch self {
        case .all: return nil
        case .tarot: return .tarot
        case .coffee: return .coffee
        case .palm: return .palm
        case .astrology: return .astrology
        case .dream: return .dream
        }
    }
}

// MARK: - Fortune Sort
enum FortuneSort: CaseIterable {
    case newest
    case oldest
    case favorites
    case rating
    
    var title: String {
        switch self {
        case .newest: return "En Yeni"
        case .oldest: return "En Eski"
        case .favorites: return "Favoriler"
        case .rating: return "Puan"
        }
    }
    
    var icon: String {
        switch self {
        case .newest: return "clock.fill"
        case .oldest: return "clock"
        case .favorites: return "heart.fill"
        case .rating: return "star.fill"
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.white.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? color.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sort Chip
struct SortChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "#8B7BC0") : Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fortune History Card
struct FortuneHistoryCard: View {
    let fortune: FortuneModel
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: fortune.type.colorHex).opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(fortune.type.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
            }
            .shadow(color: Color(hex: fortune.type.colorHex).opacity(0.3), radius: 10)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(fortune.type.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    if fortune.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.pink)
                    }
                }
                
                HStack(spacing: 12) {
                    // Date
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(formatDate(fortune.createdAt))
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    
                    // Rating
                    if fortune.rating > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.yellow)
                            Text("\(fortune.rating)/5")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.05))
                .clipShape(Circle())
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: fortune.type.colorHex).opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)
        
        if diff < 3600 {
            let mins = Int(diff / 60)
            return "\(mins) dk önce"
        } else if diff < 86400 {
            let hours = Int(diff / 3600)
            return "\(hours) saat önce"
        } else if diff < 86400 * 2 {
            return "Dün"
        } else if diff < 86400 * 7 {
            let days = Int(diff / 86400)
            return "\(days) gün önce"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d/M/yyyy"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    FortuneHistoryScreen()
}
