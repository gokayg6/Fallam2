import SwiftUI

// MARK: - Floating Glass Navigation Bar
struct FloatingGlassNavBar: View {
    @Binding var selectedTab: Int
    let items: [NavBarItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                NavBarItemView(
                    item: item,
                    isSelected: selectedTab == index,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Ultra thin material for glass effect
                Capsule()
                    .fill(.ultraThinMaterial)
                
                // Inner glow/tint overlay
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .clipShape(Capsule())
        .overlay(
            // Glass edge stroke
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

// MARK: - Nav Bar Item
struct NavBarItem: Identifiable {
    let id = UUID()
    let icon: String
    let activeIcon: String
    let title: String
}

// MARK: - Nav Bar Item View
struct NavBarItemView: View {
    let item: NavBarItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? item.activeIcon : item.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                    .contentTransition(.symbolEffect(.replace))
                
                Text(item.title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Image("app_background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            FloatingGlassNavBar(
                selectedTab: .constant(0),
                items: [
                    NavBarItem(icon: "house", activeIcon: "house.fill", title: "Ana Sayfa"),
                    NavBarItem(icon: "sparkles", activeIcon: "sparkles", title: "Fal"),
                    NavBarItem(icon: "star", activeIcon: "star.fill", title: "Astroloji"),
                    NavBarItem(icon: "person.2", activeIcon: "person.2.fill", title: "Sosyal"),
                    NavBarItem(icon: "person", activeIcon: "person.fill", title: "Profil")
                ]
            )
        }
    }
}
