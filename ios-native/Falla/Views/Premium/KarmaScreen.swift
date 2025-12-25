import SwiftUI

// MARK: - Karma Screen
struct KarmaScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: KarmaPackage?
    @State private var isProcessing = false
    @State private var currentKarma: Int = 52
    
    var body: some View {
        ZStack {
            // Background - Purple Theme
            Image("theme_purple")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Overlay for readability
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Current Karma Display
                        currentKarmaCard
                        
                        // What is Karma
                        karmaInfoCard
                        
                        // Karma Packages
                        karmaPackagesSection
                        
                        // Watch Ad Section
                        watchAdSection
                        
                        // Daily Bonus Info
                        dailyBonusInfo
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            
            // Processing Overlay
            if isProcessing {
                processingOverlay
            }
        }
        .navigationBarHidden(true)
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
            
            Text("Karma")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Current Karma
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                Text("\(currentKarma)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Current Karma Card
    private var currentKarmaCard: some View {
        VStack(spacing: 16) {
            // Flame Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FF6B35"), Color(hex: "#F7931E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "#FF6B35").opacity(0.5), radius: 20, x: 0, y: 10)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            Text("\(currentKarma)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("Mevcut Karmanız")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Karma Info Card
    private var karmaInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "#A78BDA"))
                
                Text("Karma Nedir?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Karma, Falla'da fal baktırmak ve özel özellikleri kullanmak için gereken puandır. Her fal türü belirli miktarda karma harcar. Karma satın alabilir veya reklam izleyerek kazanabilirsiniz.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Karma costs
            VStack(alignment: .leading, spacing: 8) {
                KarmaCostRow(fortune: "Kahve Falı", cost: 5)
                KarmaCostRow(fortune: "Tarot Falı", cost: 8)
                KarmaCostRow(fortune: "El Falı", cost: 10)
                KarmaCostRow(fortune: "Yüz Analizi", cost: 12)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Karma Packages Section
    private var karmaPackagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Karma Satın Al")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(KarmaPackage.allCases, id: \.self) { package in
                KarmaPackageCard(
                    package: package,
                    isSelected: selectedPackage == package,
                    action: {
                        selectedPackage = package
                        purchaseKarma(package)
                    }
                )
            }
        }
    }
    
    // MARK: - Watch Ad Section
    private var watchAdSection: some View {
        Button(action: watchAd) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#10B981").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "#10B981"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reklam İzle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Kısa bir reklam izleyerek 2 karma kazan")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("+2")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#10B981"))
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#10B981").opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Daily Bonus Info
    private var dailyBonusInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text("Premium Avantajı")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Premium üyeler her gün 25 karma kazanır! Reklamsız deneyim ve öncelikli fal yorumları için Premium'a geçin.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
            
            NavigationLink(destination: PremiumScreen()) {
                Text("Premium'a Geç")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#FFD700"))
            }
        }
        .padding(20)
        .background(Color(hex: "#FFD700").opacity(0.1))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Processing Overlay
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("İşleniyor...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    // MARK: - Actions
    private func purchaseKarma(_ package: KarmaPackage) {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            currentKarma += package.karma
            selectedPackage = nil
            // TODO: Implement StoreKit purchase
        }
    }
    
    private func watchAd() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            currentKarma += 2
        }
    }
}

// MARK: - Karma Package Enum
enum KarmaPackage: CaseIterable {
    case small // 10 karma
    case medium // 25 karma
    case large // 50 karma
    case pack75 // 75 karma package
    case pack100 // 100 karma package
    case pack250 // 250 karma package
    
    var karma: Int {
        switch self {
        case .small: return 10
        case .medium: return 25
        case .large: return 50
        case .pack75: return 75
        case .pack100: return 100
        case .pack250: return 250
        }
    }
    
    var price: String {
        switch self {
        case .small: return "₺19,99"
        case .medium: return "₺39,99"
        case .large: return "₺69,99"
        case .pack75: return "₺89,99"
        case .pack100: return "₺109,99"
        case .pack250: return "₺249,99"
        }
    }
    
    var bonus: String? {
        switch self {
        case .pack75: return "+5 Bonus"
        case .pack100: return "+15 Bonus"
        case .pack250: return "+50 Bonus"
        default: return nil
        }
    }
    
    var isBestValue: Bool {
        self == .pack250
    }
}

// MARK: - Karma Cost Row
struct KarmaCostRow: View {
    let fortune: String
    let cost: Int
    
    var body: some View {
        HStack {
            Text(fortune)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("\(cost)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - Karma Package Card
struct KarmaPackageCard: View {
    let package: KarmaPackage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Karma Amount
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(package.karma)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                    }
                    
                    if let bonus = package.bonus {
                        Text(bonus)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#10B981"))
                    }
                }
                .frame(width: 80)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 40)
                
                // Price
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    if package.isBestValue {
                        Text("EN AVANTAJLI")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "#10B981"))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Buy Button
                Text("Satın Al")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#A78BDA"), Color(hex: "#7B8CDE")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(package.isBestValue ? Color(hex: "#10B981").opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    KarmaScreen()
}
