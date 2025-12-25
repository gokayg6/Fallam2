import SwiftUI

// MARK: - Love Compatibility Screen
struct LoveCompatibilityScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedZodiac1: String?
    @State private var selectedZodiac2: String?
    @State private var showResult = false
    @State private var animateContent = false
    @State private var compatibilityResult: CompatibilityResult?
    
    private let zodiacSigns = [
        ("Koç", "♈", "aries"),
        ("Boğa", "♉", "taurus"),
        ("İkizler", "♊", "gemini"),
        ("Yengeç", "♋", "cancer"),
        ("Aslan", "♌", "leo"),
        ("Başak", "♍", "virgo"),
        ("Terazi", "♎", "libra"),
        ("Akrep", "♏", "scorpio"),
        ("Yay", "♐", "sagittarius"),
        ("Oğlak", "♑", "capricorn"),
        ("Kova", "♒", "aquarius"),
        ("Balık", "♓", "pisces")
    ]
    
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
                        if showResult, let result = compatibilityResult {
                            resultSection(result: result)
                        } else {
                            selectionSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
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
            
            Text("Burç Uyumu")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Selection Section
    private var selectionSection: some View {
        VStack(spacing: 32) {
            // Title
            VStack(spacing: 8) {
                Text("💕")
                    .font(.system(size: 48))
                
                Text("Aşk Uyumunu Keşfet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("İki burcun uyumunu öğrenmek için seç")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            
            // Selection Cards
            HStack(spacing: 20) {
                // Zodiac 1
                zodiacSelector(
                    title: "1. Burç",
                    selected: selectedZodiac1,
                    onSelect: { selectedZodiac1 = $0 }
                )
                
                // Heart
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#C97CF6"))
                
                // Zodiac 2
                zodiacSelector(
                    title: "2. Burç",
                    selected: selectedZodiac2,
                    onSelect: { selectedZodiac2 = $0 }
                )
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)
            
            // Zodiac Grid
            VStack(spacing: 16) {
                Text("Burç Seç")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(zodiacSigns, id: \.2) { zodiac in
                        ZodiacButton(
                            name: zodiac.0,
                            symbol: zodiac.1,
                            isSelected: selectedZodiac1 == zodiac.2 || selectedZodiac2 == zodiac.2,
                            onTap: {
                                if selectedZodiac1 == nil {
                                    selectedZodiac1 = zodiac.2
                                } else if selectedZodiac2 == nil && selectedZodiac1 != zodiac.2 {
                                    selectedZodiac2 = zodiac.2
                                } else if selectedZodiac1 == zodiac.2 {
                                    selectedZodiac1 = nil
                                } else if selectedZodiac2 == zodiac.2 {
                                    selectedZodiac2 = nil
                                }
                            }
                        )
                    }
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
            .offset(y: animateContent ? 0 : 40)
            
            // Calculate Button
            Button(action: calculateCompatibility) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                    Text("Uyumu Hesapla")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    (selectedZodiac1 != nil && selectedZodiac2 != nil)
                        ? LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(hex: "#C97CF6").opacity(0.4), radius: 15, y: 5)
            }
            .disabled(selectedZodiac1 == nil || selectedZodiac2 == nil)
            .opacity(animateContent ? 1 : 0)
        }
    }
    
    private func zodiacSelector(title: String, selected: String?, onSelect: @escaping (String) -> Void) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selected != nil
                                    ? Color(hex: "#C97CF6")
                                    : Color.white.opacity(0.2),
                                lineWidth: selected != nil ? 2 : 1
                            )
                    )
                
                if let selected = selected,
                   let zodiac = zodiacSigns.first(where: { $0.2 == selected }) {
                    VStack(spacing: 4) {
                        Text(zodiac.1)
                            .font(.system(size: 28))
                        Text(zodiac.0)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }
    
    // MARK: - Result Section
    private func resultSection(result: CompatibilityResult) -> some View {
        VStack(spacing: 24) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(result.score) / 100)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(result.score)%")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Uyum")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Zodiac Pair
            HStack(spacing: 16) {
                if let z1 = zodiacSigns.first(where: { $0.2 == result.zodiac1 }),
                   let z2 = zodiacSigns.first(where: { $0.2 == result.zodiac2 }) {
                    VStack {
                        Text(z1.1)
                            .font(.system(size: 36))
                        Text(z1.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#C97CF6"))
                    
                    VStack {
                        Text(z2.1)
                            .font(.system(size: 36))
                        Text(z2.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Description
            Text(result.description)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            
            // Categories
            VStack(spacing: 12) {
                compatibilityRow(title: "Romantik Uyum", value: result.romantic)
                compatibilityRow(title: "İletişim", value: result.communication)
                compatibilityRow(title: "Güven", value: result.trust)
                compatibilityRow(title: "Cinsellik", value: result.intimacy)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            
            // Try Again
            Button(action: reset) {
                Text("Yeni Uyum Hesapla")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
        }
    }
    
    private func compatibilityRow(title: String, value: Int) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(value)%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(value) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
    
    // MARK: - Actions
    private func calculateCompatibility() {
        guard let z1 = selectedZodiac1, let z2 = selectedZodiac2 else { return }
        
        // Generate random but consistent scores
        let baseScore = Int.random(in: 60...95)
        
        compatibilityResult = CompatibilityResult(
            zodiac1: z1,
            zodiac2: z2,
            score: baseScore,
            romantic: Int.random(in: 50...100),
            communication: Int.random(in: 50...100),
            trust: Int.random(in: 50...100),
            intimacy: Int.random(in: 50...100),
            description: "Bu iki burç arasında güçlü bir çekim var. Duygusal bağ kurma konusunda uyumlu olabilirsiniz. İletişim konusunda dikkatli olmanız ve karşılıklı anlayış göstermeniz önemli. Uzun vadeli ilişki potansiyeli yüksek."
        )
        
        withAnimation(.spring()) {
            showResult = true
        }
    }
    
    private func reset() {
        withAnimation(.spring()) {
            showResult = false
            selectedZodiac1 = nil
            selectedZodiac2 = nil
            compatibilityResult = nil
        }
    }
}

// MARK: - Models
struct CompatibilityResult {
    let zodiac1: String
    let zodiac2: String
    let score: Int
    let romantic: Int
    let communication: Int
    let trust: Int
    let intimacy: Int
    let description: String
}

// MARK: - Zodiac Button
struct ZodiacButton: View {
    let name: String
    let symbol: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(symbol)
                    .font(.system(size: 24))
                
                Text(name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "#C97CF6").opacity(0.3) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color(hex: "#C97CF6") : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
    }
}

#Preview {
    LoveCompatibilityScreen()
}
