import SwiftUI

// MARK: - Premium Screen
struct PremiumScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PremiumPlan = .monthly
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            // Background - Premium Gold Theme
            Image("theme_gold")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Dark overlay for readability
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Premium Badge
                        premiumBadge
                        
                        // Features List
                        featuresSection
                        
                        // Pricing Plans
                        pricingSection
                        
                        // Subscribe Button
                        subscribeButton
                        
                        // Privacy & Terms
                        policiesSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Premium Badge
    private var premiumBadge: some View {
        VStack(spacing: 20) {
            // Diamond Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#FFA500").opacity(0.5), radius: 30, x: 0, y: 10)
                
                Image(systemName: "diamond.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            
            // Title
            Text("Falla Premium")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color(hex: "#FFA500").opacity(0.5), radius: 15)
            
            // Subtitle
            Text("Sınırsız fal deneyimi için\npremium üyeliğe geçin")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 12) {
            PremiumFeatureRow(
                icon: "bell.slash.fill",
                title: "Reklamsız Deneyim",
                description: "Tüm reklamları kaldırın",
                color: Color(hex: "#FFA500")
            )
            
            PremiumFeatureRow(
                icon: "flame.fill",
                title: "Günlük 25 Karma",
                description: "Her gün ücretsiz karma kazanın",
                color: Color(hex: "#FF6B35")
            )
            
            PremiumFeatureRow(
                icon: "bolt.fill",
                title: "Öncelikli Fal Yorumu",
                description: "Fallarınız öncelikli işlenir",
                color: Color(hex: "#FFD700")
            )
            
            PremiumFeatureRow(
                icon: "heart.fill",
                title: "Aura Match Avantajları",
                description: "Burç eşleşmelerinde öncelik",
                color: Color(hex: "#FF6B9D")
            )
        }
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(spacing: 12) {
            ForEach(PremiumPlan.allCases, id: \.self) { plan in
                PremiumPlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPlan = plan
                    }
                }
            }
        }
    }
    
    // MARK: - Subscribe Button
    private var subscribeButton: some View {
        Button(action: subscribeToPremium) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                    Text("Aboneliği Başlat")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "#FFA500").opacity(0.5), radius: 20, x: 0, y: 10)
        }
        .disabled(isProcessing)
    }
    
    // MARK: - Policies Section
    private var policiesSection: some View {
        HStack(spacing: 20) {
            Button(action: {}) {
                Text("Gizlilik Politikası")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .underline()
            }
            
            Button(action: {}) {
                Text("Kullanım Şartları")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .underline()
            }
        }
    }
    
    // MARK: - Subscribe Action
    private func subscribeToPremium() {
        isProcessing = true
        
        // Simulate purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            // TODO: Implement StoreKit purchase
        }
    }
}

// MARK: - Premium Plan Enum
enum PremiumPlan: CaseIterable {
    case weekly
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .weekly: return "Haftalık"
        case .monthly: return "Aylık"
        case .yearly: return "Yıllık"
        }
    }
    
    var price: String {
        switch self {
        case .weekly: return "₺39,99"
        case .monthly: return "₺89,99"
        case .yearly: return "₺499,99"
        }
    }
    
    var period: String {
        switch self {
        case .weekly: return "hafta"
        case .monthly: return "ay"
        case .yearly: return "yıl"
        }
    }
    
    var isPopular: Bool {
        self == .monthly
    }
    
    var badge: String? {
        switch self {
        case .yearly: return "EN AVANTAJLI"
        default: return nil
        }
    }
}

// MARK: - Premium Feature Row
struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#FFD700"))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Premium Plan Card
struct PremiumPlanCard: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                        
                        if plan.isPopular {
                            Text("POPÜLER")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: "#FFA500"))
                                .clipShape(Capsule())
                        }
                        
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: "#10B981"))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("\(plan.price) / \(plan.period)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "#FFD700"))
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected 
                        ? LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? Color(hex: "#FFA500").opacity(0.3) : .clear, radius: 15, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PremiumScreen()
}
