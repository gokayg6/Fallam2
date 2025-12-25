import SwiftUI

// MARK: - Horoscope Detail Screen
struct HoroscopeDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    let zodiacSign: ZodiacSign
    @State private var selectedPeriod: HoroscopePeriod = .daily
    @State private var animateContent = false
    
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
                    VStack(spacing: 24) {
                        // Zodiac Card
                        zodiacCard
                        
                        // Period Selector
                        periodSelector
                        
                        // Horoscope Content
                        horoscopeContent
                        
                        // Characteristics
                        characteristicsSection
                        
                        // Planet Info
                        planetInfo
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.1)) {
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
            
            Spacer()
            
            Text(zodiacSign.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Zodiac Card
    private var zodiacCard: some View {
        VStack(spacing: 20) {
            // Large Symbol
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color(hex: zodiacSign.color).opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: zodiacSign.color), Color(hex: zodiacSign.color).opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: zodiacSign.color).opacity(0.5), radius: 20)
                
                Text(zodiacSign.symbol)
                    .font(.system(size: 50))
            }
            
            // Info
            VStack(spacing: 8) {
                Text(zodiacSign.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(zodiacSign.dateRange)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 16) {
                    infoTag(icon: "flame.fill", text: zodiacSign.element)
                    infoTag(icon: "globe", text: rulingPlanet)
                }
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color(hex: zodiacSign.color).opacity(0.4), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
        .scaleEffect(animateContent ? 1 : 0.95)
    }
    
    private func infoTag(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(Color(hex: zodiacSign.color))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(hex: zodiacSign.color).opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var rulingPlanet: String {
        switch zodiacSign.name {
        case "Koç": return "Mars"
        case "Boğa": return "Venüs"
        case "İkizler": return "Merkür"
        case "Yengeç": return "Ay"
        case "Aslan": return "Güneş"
        case "Başak": return "Merkür"
        case "Terazi": return "Venüs"
        case "Akrep": return "Plüton"
        case "Yay": return "Jüpiter"
        case "Oğlak": return "Satürn"
        case "Kova": return "Uranüs"
        case "Balık": return "Neptün"
        default: return "Bilinmiyor"
        }
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach(HoroscopePeriod.allCases, id: \.self) { period in
                Button(action: { selectedPeriod = period }) {
                    Text(period.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedPeriod == period ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedPeriod == period
                                ? RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                : nil
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .opacity(animateContent ? 1 : 0)
    }
    
    // MARK: - Horoscope Content
    private var horoscopeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(contentTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < contentRating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#F59E0B"))
                    }
                }
            }
            
            Text(contentText)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(6)
            
            // Insights
            VStack(spacing: 12) {
                insightRow(title: "Aşk", rating: 4)
                insightRow(title: "Kariyer", rating: 3)
                insightRow(title: "Sağlık", rating: 5)
                insightRow(title: "Finans", rating: 3)
            }
            .padding(.top, 8)
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
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    private var contentTitle: String {
        switch selectedPeriod {
        case .daily: return "Günlük Yorum"
        case .weekly: return "Haftalık Yorum"
        case .monthly: return "Aylık Yorum"
        }
    }
    
    private var contentRating: Int {
        switch selectedPeriod {
        case .daily: return 4
        case .weekly: return 3
        case .monthly: return 5
        }
    }
    
    private var contentText: String {
        switch selectedPeriod {
        case .daily:
            return "Bugün \(zodiacSign.name) burcu için enerjik bir gün olacak. \(rulingPlanet) gezegeni size güç veriyor. Yeni fırsatlar kapınızı çalabilir, bunlara açık olun. Sosyal ilişkilerinizde dikkatli olmanız gereken bir dönemdesiniz."
        case .weekly:
            return "Bu hafta \(zodiacSign.name) burcu için dönüşüm haftası. Haftanın başında bazı zorluklarla karşılaşabilirsiniz ancak hafta ortasından itibaren işler yoluna girecek. Önümüzdeki hafta sonu için planlarınızı şimdiden yapın."
        case .monthly:
            return "Bu ay \(zodiacSign.name) burcu için kariyer açısından önemli gelişmeler olacak. \(rulingPlanet)'ın etkisiyle yaratıcılığınız artacak. Aşk hayatınızda heyecan verici gelişmeler yaşayabilirsiniz. Mali konularda dikkatli olun."
        }
    }
    
    private func insightRow(title: String, rating: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(0..<5) { i in
                    Circle()
                        .fill(i < rating ? Color(hex: "#C97CF6") : Color.white.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
    // MARK: - Characteristics Section
    private var characteristicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Karakter Özellikleri")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                characteristic(title: "Güçlü Yönler", traits: strengthTraits, color: "#10B981")
                characteristic(title: "Zayıf Yönler", traits: weakTraits, color: "#EF4444")
            }
        }
        .opacity(animateContent ? 1 : 0)
    }
    
    private func characteristic(title: String, traits: [String], color: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: color))
            
            ForEach(traits, id: \.self) { trait in
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 4, height: 4)
                    
                    Text(trait)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: color).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var strengthTraits: [String] {
        switch zodiacSign.element {
        case "Ateş": return ["Cesur", "Enerjik", "Tutkulu"]
        case "Toprak": return ["Kararlı", "Güvenilir", "Pratik"]
        case "Hava": return ["Zeki", "İletişimci", "Uyumlu"]
        case "Su": return ["Sezgisel", "Duygusal", "Yaratıcı"]
        default: return ["Güçlü", "Kararlı", "Sadık"]
        }
    }
    
    private var weakTraits: [String] {
        switch zodiacSign.element {
        case "Ateş": return ["Sabırsız", "İmpulsif"]
        case "Toprak": return ["İnatçı", "Muhafazakar"]
        case "Hava": return ["Kararsız", "Yüzeysel"]
        case "Su": return ["Aşırı hassas", "Karamsar"]
        default: return ["Şüpheci", "Endişeli"]
        }
    }
    
    // MARK: - Planet Info
    private var planetInfo: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: zodiacSign.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: zodiacSign.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Yönetici Gezegen")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(rulingPlanet)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Element")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(zodiacSign.element)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .opacity(animateContent ? 1 : 0)
    }
}

// MARK: - Period Enum
enum HoroscopePeriod: CaseIterable {
    case daily, weekly, monthly
    
    var title: String {
        switch self {
        case .daily: return "Günlük"
        case .weekly: return "Haftalık"
        case .monthly: return "Aylık"
        }
    }
}

#Preview {
    HoroscopeDetailScreen(zodiacSign: ZodiacSign.allSigns[10])
}
