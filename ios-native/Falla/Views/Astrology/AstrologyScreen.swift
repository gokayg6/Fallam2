import SwiftUI

// MARK: - Astrology Screen
struct AstrologyScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSign: ZodiacSign?
    
    var body: some View {
        ZStack {
            // Background
            Image("app_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Today's Highlight
                        todayHighlightCard
                        
                        // Zodiac Signs Grid
                        zodiacGridSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedSign) { sign in
            ZodiacDetailScreen(sign: sign)
        }
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
            
            Text("Astroloji")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Astrology icon
            Image("icon_astrology")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Today's Highlight Card
    private var todayHighlightCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                
                Text("Günün Burcu")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 16) {
                // Zodiac Image
                Image("zodiac_aslan")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Aslan")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Bugün enerjiniz çok yüksek! Liderlik özellikleriniz ön plana çıkıyor.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
            }
            
            Button(action: {
                selectedSign = .aslan
            }) {
                Text("Detaylı Yorum")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Zodiac Grid Section
    private var zodiacGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Burçlar")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(ZodiacSign.allCases, id: \.self) { sign in
                    ZodiacCardView(sign: sign) {
                        selectedSign = sign
                    }
                }
            }
        }
    }
}

// MARK: - Zodiac Sign Enum
enum ZodiacSign: String, CaseIterable, Identifiable {
    case koc = "Koç"
    case boga = "Boğa"
    case ikizler = "İkizler"
    case yengec = "Yengeç"
    case aslan = "Aslan"
    case basak = "Başak"
    case terazi = "Terazi"
    case akrep = "Akrep"
    case yay = "Yay"
    case oglak = "Oğlak"
    case kova = "Kova"
    case balik = "Balık"
    
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .koc: return "zodiac_koc"
        case .boga: return "zodiac_boga"
        case .ikizler: return "zodiac_ikizler"
        case .yengec: return "zodiac_yengec"
        case .aslan: return "zodiac_aslan"
        case .basak: return "zodiac_basak"
        case .terazi: return "zodiac_terazi"
        case .akrep: return "zodiac_akrep"
        case .yay: return "zodiac_yay"
        case .oglak: return "zodiac_oglak"
        case .kova: return "zodiac_kova"
        case .balik: return "zodiac_balik"
        }
    }
    
    var dateRange: String {
        switch self {
        case .koc: return "21 Mart - 19 Nisan"
        case .boga: return "20 Nisan - 20 Mayıs"
        case .ikizler: return "21 Mayıs - 20 Haziran"
        case .yengec: return "21 Haziran - 22 Temmuz"
        case .aslan: return "23 Temmuz - 22 Ağustos"
        case .basak: return "23 Ağustos - 22 Eylül"
        case .terazi: return "23 Eylül - 22 Ekim"
        case .akrep: return "23 Ekim - 21 Kasım"
        case .yay: return "22 Kasım - 21 Aralık"
        case .oglak: return "22 Aralık - 19 Ocak"
        case .kova: return "20 Ocak - 18 Şubat"
        case .balik: return "19 Şubat - 20 Mart"
        }
    }
    
    var element: String {
        switch self {
        case .koc, .aslan, .yay: return "Ateş"
        case .boga, .basak, .oglak: return "Toprak"
        case .ikizler, .terazi, .kova: return "Hava"
        case .yengec, .akrep, .balik: return "Su"
        }
    }
    
    var elementColor: Color {
        switch element {
        case "Ateş": return Color(hex: "#FF6B35")
        case "Toprak": return Color(hex: "#8B4513")
        case "Hava": return Color(hex: "#87CEEB")
        case "Su": return Color(hex: "#4169E1")
        default: return .white
        }
    }
    
    var planet: String {
        switch self {
        case .koc: return "Mars"
        case .boga: return "Venüs"
        case .ikizler: return "Merkür"
        case .yengec: return "Ay"
        case .aslan: return "Güneş"
        case .basak: return "Merkür"
        case .terazi: return "Venüs"
        case .akrep: return "Plüton"
        case .yay: return "Jüpiter"
        case .oglak: return "Satürn"
        case .kova: return "Uranüs"
        case .balik: return "Neptün"
        }
    }
}

// MARK: - Zodiac Card View
struct ZodiacCardView: View {
    let sign: ZodiacSign
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Zodiac Image
                Image(sign.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                
                Text(sign.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(sign.elementColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Zodiac Detail Screen
struct ZodiacDetailScreen: View {
    let sign: ZodiacSign
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Image("app_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .glassCircleButton(size: 36)
                    }
                    
                    Spacer()
                    
                    Text(sign.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .glassCircleButton(size: 36)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Sign Header
                        signHeaderCard
                        
                        // Daily Horoscope
                        dailyHoroscopeCard
                        
                        // Compatibility
                        compatibilityCard
                        
                        // Characteristics
                        characteristicsCard
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
        }
    }
    
    // MARK: - Sign Header Card
    private var signHeaderCard: some View {
        VStack(spacing: 16) {
            // Zodiac Image
            Image(sign.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            Text(sign.rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(sign.dateRange)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            // Tags
            HStack(spacing: 12) {
                InfoTag(icon: "flame.fill", text: sign.element, color: sign.elementColor)
                InfoTag(icon: "globe", text: sign.planet, color: Color(hex: "#A78BDA"))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Daily Horoscope Card
    private var dailyHoroscopeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Text("Günlük Yorum")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Bugün")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Text(getDailyHoroscope())
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(6)
            
            // Ratings
            HStack(spacing: 20) {
                RatingView(title: "Aşk", rating: 4, color: .pink)
                RatingView(title: "Kariyer", rating: 3, color: .blue)
                RatingView(title: "Sağlık", rating: 5, color: .green)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Compatibility Card
    private var compatibilityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.pink)
                
                Text("Uyumlu Burçlar")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 16) {
                ForEach(getCompatibleSigns(), id: \.self) { compatSign in
                    VStack(spacing: 8) {
                        Image(compatSign.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        
                        Text(compatSign.rawValue)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Characteristics Card
    private var characteristicsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#A78BDA"))
                
                Text("Karakteristik Özellikler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                CharacteristicRow(title: "Güçlü Yönler", traits: getStrengths())
                CharacteristicRow(title: "Zayıf Yönler", traits: getWeaknesses())
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Helper Functions
    private func getDailyHoroscope() -> String {
        "Bugün \(sign.planet) gezegeninin etkisinde olacaksınız. Bu dönem sizin için önemli fırsatlar sunuyor. Enerjinizi doğru yönlendirdiğinizde başarıya ulaşmanız kaçınılmaz. Duygusal dengelerinize dikkat edin ve kendinize zaman ayırın."
    }
    
    private func getCompatibleSigns() -> [ZodiacSign] {
        switch sign {
        case .koc: return [.aslan, .yay, .ikizler]
        case .boga: return [.basak, .oglak, .yengec]
        case .ikizler: return [.terazi, .kova, .koc]
        case .yengec: return [.akrep, .balik, .boga]
        case .aslan: return [.yay, .koc, .ikizler]
        case .basak: return [.oglak, .boga, .yengec]
        case .terazi: return [.kova, .ikizler, .aslan]
        case .akrep: return [.balik, .yengec, .basak]
        case .yay: return [.koc, .aslan, .terazi]
        case .oglak: return [.boga, .basak, .akrep]
        case .kova: return [.ikizler, .terazi, .yay]
        case .balik: return [.yengec, .akrep, .oglak]
        }
    }
    
    private func getStrengths() -> [String] {
        switch sign {
        case .koc: return ["Cesur", "Enerjik", "Lider"]
        case .boga: return ["Kararlı", "Güvenilir", "Sadık"]
        case .ikizler: return ["Zeki", "Uyumlu", "İletişimci"]
        case .yengec: return ["Duygusal", "Koruyucu", "Sadık"]
        case .aslan: return ["Karizmatik", "Cömert", "Lider"]
        case .basak: return ["Analitik", "Çalışkan", "Pratik"]
        case .terazi: return ["Diplomatik", "Zarif", "Adil"]
        case .akrep: return ["Tutkulu", "Kararlı", "Sezgisel"]
        case .yay: return ["İyimser", "Maceracı", "Felsefi"]
        case .oglak: return ["Disiplinli", "Sorumlu", "Azimli"]
        case .kova: return ["Yenilikçi", "Bağımsız", "İnsancıl"]
        case .balik: return ["Sezgisel", "Şefkatli", "Sanatsal"]
        }
    }
    
    private func getWeaknesses() -> [String] {
        switch sign {
        case .koc: return ["Sabırsız", "Dürtüsel"]
        case .boga: return ["İnatçı", "Sahiplenici"]
        case .ikizler: return ["Kararsız", "Yüzeysel"]
        case .yengec: return ["Aşırı hassas", "Karamsar"]
        case .aslan: return ["Kibirli", "İnatçı"]
        case .basak: return ["Eleştirici", "Endişeli"]
        case .terazi: return ["Kararsız", "Çatışmadan kaçan"]
        case .akrep: return ["Kıskanç", "Gizlemci"]
        case .yay: return ["Sabırsız", "Taktisiz"]
        case .oglak: return ["Kötümser", "İnatçı"]
        case .kova: return ["Mesafeli", "İnatçı"]
        case .balik: return ["Kaçınmacı", "Aşırı hassas"]
        }
    }
}

// MARK: - Supporting Views
struct InfoTag: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

struct RatingView: View {
    let title: String
    let rating: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < rating ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundColor(index < rating ? color : .white.opacity(0.3))
                }
            }
        }
    }
}

struct CharacteristicRow: View {
    let title: String
    let traits: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 8) {
                ForEach(traits, id: \.self) { trait in
                    Text(trait)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    AstrologyScreen()
}
