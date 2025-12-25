import SwiftUI

// MARK: - Fortune History View
struct FortuneHistoryView: View {
    @State private var selectedFilter: FortuneFilter = .all
    @State private var selectedCategory: FortuneCategory = .newest
    
    var body: some View {
        ZStack {
            // Background
            Image("app_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                historyHeader
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                
                // Filter Chips
                filterChips
                    .padding(.top, 16)
                
                // Category Chips
                categoryChips
                    .padding(.top, 12)
                
                // Fortune History List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        FortuneHistoryCard(
                            type: "Kahve Falı",
                            date: "dün",
                            icon: "cup.and.saucer.fill",
                            gradient: [Color(hex: "#FF9A56"), Color(hex: "#FF6B35")]
                        )
                        
                        FortuneHistoryCard(
                            type: "Kahve Falı",
                            date: "dün",
                            icon: "cup.and.saucer.fill",
                            gradient: [Color(hex: "#FF9A56"), Color(hex: "#FF6B35")]
                        )
                        
                        FortuneHistoryCard(
                            type: "Tarot Yorum",
                            date: "dün",
                            icon: "rectangle.stack.fill",
                            gradient: [Color(hex: "#FF6B9D"), Color(hex: "#C44569")]
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Header
    private var historyHeader: some View {
        HStack {
            Text("Fal Geçmişi")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Login Button
            Button(action: {}) {
                Text("Login")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FortuneFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        isSelected: selectedFilter == filter,
                        color: filter.color
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Category Chips
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FortuneCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.title,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Fortune Filter Enum
enum FortuneFilter: CaseIterable {
    case all, tarot, coffee
    
    var title: String {
        switch self {
        case .all: return "Tümü"
        case .tarot: return "Tarot"
        case .coffee: return "Kahve Falı"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(hex: "#10B981")
        case .tarot: return Color(hex: "#8B5CF6")
        case .coffee: return Color(hex: "#F59E0B")
        }
    }
}

// MARK: - Fortune Category Enum
enum FortuneCategory: CaseIterable {
    case newest, oldest, favorites
    
    var title: String {
        switch self {
        case .newest: return "En Yeni"
        case .oldest: return "En Eski"
        case .favorites: return "Favoriler"
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "#10B981") : .white.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fortune History Card
struct FortuneHistoryCard: View {
    let type: String
    let date: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(type)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(date)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        gradient[0].opacity(0.3),
                        gradient[1].opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
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

#Preview {
    FortuneHistoryView()
        .environmentObject(AuthProvider())
}
