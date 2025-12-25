import SwiftUI

// MARK: - Daily Astrology Screen
struct DailyAstrologyScreen: View {
    @Environment(\.dismiss) private var dismiss
    let zodiacSign: ZodiacSign
    @State private var selectedCategory: AstrologyCategory = .general
    @State private var animateContent = false
    @State private var luckyItems: LuckyItems?
    
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
                        // Zodiac Header
                        zodiacHeader
                        
                        // Category Tabs
                        categoryTabs
                        
                        // Daily Reading
                        dailyReading
                        
                        // Lucky Items
                        luckySection
                        
                        // Compatibility
                        compatibilitySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            generateLuckyItems()
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
            
            Text("Günlük Burç Yorumu")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
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
    
    // MARK: - Zodiac Header
    private var zodiacHeader: some View {
        VStack(spacing: 16) {
            // Zodiac Symbol
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: zodiacSign.color), Color(hex: zodiacSign.color).opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: Color(hex: zodiacSign.color).opacity(0.5), radius: 20)
                
                Text(zodiacSign.symbol)
                    .font(.system(size: 44))
            }
            
            // Info
            VStack(spacing: 4) {
                Text(zodiacSign.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(zodiacSign.dateRange)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(formattedDate)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
        }
        .opacity(animateContent ? 1 : 0)
        .scaleEffect(animateContent ? 1 : 0.9)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: Date())
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AstrologyCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        title: category.title,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        onTap: { selectedCategory = category }
                    )
                }
            }
        }
        .opacity(animateContent ? 1 : 0)
    }
    
    // MARK: - Daily Reading
    private var dailyReading: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: selectedCategory.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#C97CF6"))
                
                Text(selectedCategory.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(readingText)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(6)
            
            // Rating
            HStack(spacing: 4) {
                ForEach(0..<5) { i in
                    Image(systemName: i < rating ? "star.fill" : "star")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#F59E0B"))
                }
                
                Text("(\(rating)/5)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
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
    
    private var readingText: String {
        switch selectedCategory {
        case .general:
            return "Bugün genel olarak olumlu bir gün seni bekliyor. Ay'ın konumu sana güç veriyor ve yaratıcı projeler için ideal bir zaman. Beklenmedik haberler alabilirsin, bunları açık bir zihinle karşıla. İş yerinde veya sosyal çevrende yeni fırsatlar kapını çalabilir."
        case .love:
            return "Aşk hayatında heyecan verici gelişmeler olabilir. Venüs'ün etkisiyle çekiciliğin artacak ve karşı cinsten ilgi göreceksin. İlişkide olanlar için romantik bir akşam planlamak iyi bir fikir. Bekarlar yeni tanışıklıklar için açık olmalı."
        case .career:
            return "Kariyer açısından önemli adımlar atman için uygun bir gün. Merkür'ün desteğiyle iletişim yeteneklerin ön plana çıkıyor. Toplantılarda fikirlerini rahatlıkla ifade edebilirsin. Mali konularda dikkatli ol, büyük harcamalardan kaçın."
        case .health:
            return "Sağlık açısından enerjik bir gün seni bekliyor. Fiziksel aktiviteler için ideal bir zaman. Ancak aşırıya kaçmamak önemli. Stres yönetimine dikkat et ve yeterli uyku almayı ihmal etme. Dengeli beslenme bugün özellikle önemli."
        }
    }
    
    private var rating: Int {
        switch selectedCategory {
        case .general: return 4
        case .love: return 5
        case .career: return 3
        case .health: return 4
        }
    }
    
    // MARK: - Lucky Section
    private var luckySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Şanslı Öğeler")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                if let items = luckyItems {
                    luckyItem(icon: "number", title: "Sayı", value: items.number)
                    luckyItem(icon: "paintbrush.fill", title: "Renk", value: items.color)
                    luckyItem(icon: "clock", title: "Saat", value: items.time)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#10B981").opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
    }
    
    private func luckyItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#10B981").opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#10B981"))
            }
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Compatibility Section
    private var compatibilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bugün Uyumlu Burçlar")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                ForEach(compatibleSigns.prefix(3), id: \.name) { sign in
                    VStack(spacing: 8) {
                        Text(sign.symbol)
                            .font(.system(size: 28))
                        
                        Text(sign.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: sign.color).opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: sign.color).opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .opacity(animateContent ? 1 : 0)
    }
    
    private var compatibleSigns: [ZodiacSign] {
        // Return different signs based on element
        let allSigns = ZodiacSign.allSigns
        return allSigns.filter { $0.name != zodiacSign.name }.shuffled()
    }
    
    // MARK: - Helpers
    private func generateLuckyItems() {
        let numbers = ["3", "7", "12", "21", "33", "42"]
        let colors = ["Mor", "Mavi", "Yeşil", "Altın", "Gümüş"]
        let times = ["09:00", "14:30", "17:00", "21:00"]
        
        luckyItems = LuckyItems(
            number: numbers.randomElement() ?? "7",
            color: colors.randomElement() ?? "Mor",
            time: times.randomElement() ?? "14:30"
        )
    }
}

// MARK: - Models
struct LuckyItems {
    let number: String
    let color: String
    let time: String
}

enum AstrologyCategory: CaseIterable {
    case general, love, career, health
    
    var title: String {
        switch self {
        case .general: return "Genel"
        case .love: return "Aşk"
        case .career: return "Kariyer"
        case .health: return "Sağlık"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "sparkles"
        case .love: return "heart.fill"
        case .career: return "briefcase.fill"
        case .health: return "cross.fill"
        }
    }
}

// MARK: - Category Tab
struct CategoryTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
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

// MARK: - Zodiac Sign Model
struct ZodiacSign {
    let name: String
    let symbol: String
    let dateRange: String
    let color: String
    let element: String
    
    static let allSigns: [ZodiacSign] = [
        ZodiacSign(name: "Koç", symbol: "♈", dateRange: "21 Mar - 19 Nis", color: "#EF4444", element: "Ateş"),
        ZodiacSign(name: "Boğa", symbol: "♉", dateRange: "20 Nis - 20 May", color: "#10B981", element: "Toprak"),
        ZodiacSign(name: "İkizler", symbol: "♊", dateRange: "21 May - 20 Haz", color: "#F59E0B", element: "Hava"),
        ZodiacSign(name: "Yengeç", symbol: "♋", dateRange: "21 Haz - 22 Tem", color: "#3B82F6", element: "Su"),
        ZodiacSign(name: "Aslan", symbol: "♌", dateRange: "23 Tem - 22 Ağu", color: "#F59E0B", element: "Ateş"),
        ZodiacSign(name: "Başak", symbol: "♍", dateRange: "23 Ağu - 22 Eyl", color: "#10B981", element: "Toprak"),
        ZodiacSign(name: "Terazi", symbol: "♎", dateRange: "23 Eyl - 22 Eki", color: "#EC4899", element: "Hava"),
        ZodiacSign(name: "Akrep", symbol: "♏", dateRange: "23 Eki - 21 Kas", color: "#8B5CF6", element: "Su"),
        ZodiacSign(name: "Yay", symbol: "♐", dateRange: "22 Kas - 21 Ara", color: "#EF4444", element: "Ateş"),
        ZodiacSign(name: "Oğlak", symbol: "♑", dateRange: "22 Ara - 19 Oca", color: "#6B7280", element: "Toprak"),
        ZodiacSign(name: "Kova", symbol: "♒", dateRange: "20 Oca - 18 Şub", color: "#3B82F6", element: "Hava"),
        ZodiacSign(name: "Balık", symbol: "♓", dateRange: "19 Şub - 20 Mar", color: "#8B5CF6", element: "Su")
    ]
}

#Preview {
    DailyAstrologyScreen(zodiacSign: ZodiacSign.allSigns[10]) // Kova
}
