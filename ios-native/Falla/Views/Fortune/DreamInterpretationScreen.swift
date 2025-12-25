import SwiftUI

// MARK: - Dream Interpretation Screen
struct DreamInterpretationScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dreamText: String = ""
    @State private var selectedMood: DreamMood = .neutral
    @State private var isAnalyzing = false
    @State private var interpretation: DreamInterpretation?
    
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
                        // Info Card
                        infoCard
                        
                        // Dream Input
                        dreamInputSection
                        
                        // Mood Selection
                        moodSelectionSection
                        
                        // Common Symbols
                        if interpretation == nil {
                            commonSymbolsSection
                        }
                        
                        // Analyze Button
                        if !dreamText.isEmpty && interpretation == nil {
                            analyzeButton
                        }
                        
                        // Interpretation Result
                        if let result = interpretation {
                            interpretationSection(result)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            
            // Analyzing Overlay
            if isAnalyzing {
                analyzingOverlay
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
            
            Text("Rüya Yorumu")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Karma cost
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("6")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#7986CB"), Color(hex: "#5C6BC0")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rüya Yorumu")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Rüyalarınızın gizli mesajlarını keşfedin")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("Rüyalar bilinçaltımızın mesajlarını taşır. Rüyanızı detaylı bir şekilde anlatın, yapay zeka rüyanızdaki sembolleri analiz ederek size anlamlı yorumlar sunacaktır.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Dream Input Section
    private var dreamInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Rüyanızı Anlatın")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(dreamText.count)/1000")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            TextEditor(text: $dreamText)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.05))
                .frame(minHeight: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if dreamText.isEmpty {
                            Text("Rüyanızı olabildiğince detaylı anlatın. Gördüğünüz nesneler, insanlar, mekanlar ve hissettiğiniz duygular önemlidir...")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(12)
                        }
                    },
                    alignment: .topLeading
                )
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Mood Selection Section
    private var moodSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rüyadaki Genel Mod")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 10) {
                ForEach(DreamMood.allCases, id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        selectedMood = mood
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Common Symbols Section
    private var commonSymbolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sık Görülen Semboller")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DreamSymbol.commonSymbols, id: \.name) { symbol in
                        SymbolChip(symbol: symbol) {
                            if !dreamText.contains(symbol.name) {
                                if !dreamText.isEmpty {
                                    dreamText += ", "
                                }
                                dreamText += symbol.name.lowercased()
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Analyze Button
    private var analyzeButton: some View {
        Button(action: analyzeDream) {
            HStack(spacing: 12) {
                Image(systemName: "moon.stars")
                    .font(.system(size: 18))
                Text("Rüyamı Yorumla")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#7986CB"), Color(hex: "#5C6BC0")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "#5C6BC0").opacity(0.4), radius: 20, x: 0, y: 8)
        }
    }
    
    // MARK: - Interpretation Section
    private func interpretationSection(_ result: DreamInterpretation) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rüya Yorumu")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Main Interpretation
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex: "#7986CB"))
                    Text("Genel Yorum")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(result.mainInterpretation)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#5C6BC0").opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Symbols Found
            if !result.symbolsFound.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "#7986CB"))
                        Text("Tespit Edilen Semboller")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    ForEach(result.symbolsFound, id: \.name) { symbol in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(symbol.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#7986CB"))
                            
                            Text(symbol.meaning)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            
            // Advice
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Tavsiye")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(result.advice)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Analyzing Overlay
    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    // Stars animation
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: CGFloat.random(in: 8...16)))
                            .foregroundColor(Color(hex: "#7986CB").opacity(0.6))
                            .offset(
                                x: CGFloat.random(in: -40...40),
                                y: CGFloat.random(in: -40...40)
                            )
                    }
                    
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#7986CB"), Color(hex: "#5C6BC0")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#7986CB"))
                }
                
                Text("Rüyanız yorumlanıyor...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Semboller analiz ediliyor")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    // MARK: - Analyze Dream
    private func analyzeDream() {
        isAnalyzing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isAnalyzing = false
            interpretation = DreamInterpretation(
                mainInterpretation: "Rüyanız bilinçaltınızın size önemli mesajlar vermeye çalıştığını gösteriyor. \(selectedMood.interpretationPrefix) Rüyanızdaki olaylar hayatınızda yakın zamanda yaşayacağınız değişimleri simgeliyor olabilir.",
                symbolsFound: [
                    DreamSymbol(name: "Su", meaning: "Duygusal durumunuzu ve bilinçaltı akışınızı temsil eder."),
                    DreamSymbol(name: "Yol", meaning: "Hayat yolculuğunuzu ve karar verme süreçlerinizi simgeler."),
                    DreamSymbol(name: "Ev", meaning: "İç dünyanız ve güvenlik ihtiyacınızı temsil eder.")
                ],
                advice: "Bu rüya size içsel bir yolculuğa çıkmanız gerektiğini hatırlatıyor. Kendinize zaman ayırın ve duygularınızla yüzleşmekten çekinmeyin. Yakın zamanda hayatınızda olumlu değişimler olacağına işaret ediyor."
            )
        }
    }
}

// MARK: - Dream Mood
enum DreamMood: CaseIterable {
    case happy, neutral, scary, sad, confusing
    
    var title: String {
        switch self {
        case .happy: return "Mutlu"
        case .neutral: return "Nötr"
        case .scary: return "Korkutucu"
        case .sad: return "Üzücü"
        case .confusing: return "Kafa Karıştırıcı"
        }
    }
    
    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .neutral: return "face.smiling.inverse"
        case .scary: return "exclamationmark.triangle"
        case .sad: return "cloud.rain"
        case .confusing: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return Color(hex: "#4CAF50")
        case .neutral: return Color(hex: "#9E9E9E")
        case .scary: return Color(hex: "#F44336")
        case .sad: return Color(hex: "#2196F3")
        case .confusing: return Color(hex: "#FF9800")
        }
    }
    
    var interpretationPrefix: String {
        switch self {
        case .happy: return "Pozitif enerjilerle dolu bir rüya görmüşsünüz."
        case .neutral: return "Rüyanız dengeli bir bilinç durumunu yansıtıyor."
        case .scary: return "Bu rüya bilinçaltınızdaki korkularla yüzleşmenizi istiyor."
        case .sad: return "Rüyanız duygusal bir arınma sürecine işaret ediyor."
        case .confusing: return "Hayatınızdaki belirsizlikler rüyanıza yansımış."
        }
    }
}

// MARK: - Mood Button
struct MoodButton: View {
    let mood: DreamMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mood.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : mood.color)
                
                Text(mood.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mood.color : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(mood.color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dream Symbol
struct DreamSymbol {
    let name: String
    let meaning: String
    
    static let commonSymbols: [DreamSymbol] = [
        DreamSymbol(name: "Su", meaning: "Duygular"),
        DreamSymbol(name: "Uçmak", meaning: "Özgürlük"),
        DreamSymbol(name: "Düşmek", meaning: "Kontrol kaybı"),
        DreamSymbol(name: "Ev", meaning: "Güvenlik"),
        DreamSymbol(name: "Yol", meaning: "Hayat yolu"),
        DreamSymbol(name: "Ölüm", meaning: "Dönüşüm"),
        DreamSymbol(name: "Bebek", meaning: "Yeni başlangıç"),
        DreamSymbol(name: "Hayvan", meaning: "İçgüdüler"),
    ]
}

// MARK: - Symbol Chip
struct SymbolChip: View {
    let symbol: DreamSymbol
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#7986CB"))
                
                Text(symbol.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dream Interpretation
struct DreamInterpretation {
    let mainInterpretation: String
    let symbolsFound: [DreamSymbol]
    let advice: String
}

#Preview {
    DreamInterpretationScreen()
}
