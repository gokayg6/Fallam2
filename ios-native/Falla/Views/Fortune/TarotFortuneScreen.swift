import SwiftUI

// MARK: - Tarot Fortune Screen
struct TarotFortuneScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSpread: TarotSpread = .threeCard
    @State private var drawnCards: [TarotCard] = []
    @State private var isDrawing = false
    @State private var showResult = false
    @State private var question: String = ""
    
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
                        // Tarot Info Card
                        tarotInfoCard
                        
                        // Spread Selection
                        spreadSelectionSection
                        
                        // Question Input
                        questionSection
                        
                        // Card Display
                        if !drawnCards.isEmpty {
                            drawnCardsSection
                        }
                        
                        // Draw Button
                        drawButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            
            // Drawing Overlay
            if isDrawing {
                drawingOverlay
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
            
            Text("Tarot Falı")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Karma cost
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("8")
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
    
    // MARK: - Tarot Info Card
    private var tarotInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#C97CF6"), Color(hex: "#9B59B6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tarot Kartları")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Gizemli kartlar geleceğinizi aydınlatır")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("Tarot kartları yüzyıllardır geleceği keşfetmek ve içsel bilgeliğe ulaşmak için kullanılmaktadır. Kartlarınızı çekmeden önce zihninizi sakinleştirin ve sormak istediğiniz soruya odaklanın.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Spread Selection
    private var spreadSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Açılım Seçin")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(TarotSpread.allCases, id: \.self) { spread in
                    SpreadButton(
                        spread: spread,
                        isSelected: selectedSpread == spread
                    ) {
                        selectedSpread = spread
                        drawnCards = []
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Question Section
    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sorunuz (Opsiyonel)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            TextField("", text: $question, prompt: Text("Örn: Aşk hayatım nasıl olacak?").foregroundColor(.white.opacity(0.4)))
                .foregroundColor(.white)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Drawn Cards Section
    private var drawnCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Çekilen Kartlar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(Array(drawnCards.enumerated()), id: \.offset) { index, card in
                    TarotCardView(card: card, position: selectedSpread.positions[index])
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Draw Button
    private var drawButton: some View {
        Button(action: drawCards) {
            HStack(spacing: 12) {
                Image(systemName: drawnCards.isEmpty ? "rectangle.stack" : "arrow.counterclockwise")
                    .font(.system(size: 18))
                Text(drawnCards.isEmpty ? "Kartları Çek" : "Yeniden Çek")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#C97CF6"), Color(hex: "#9B59B6")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "#9B59B6").opacity(0.4), radius: 20, x: 0, y: 8)
        }
    }
    
    // MARK: - Drawing Overlay
    private var drawingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated cards
                HStack(spacing: -20) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#C97CF6"), Color(hex: "#9B59B6")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 90)
                            .overlay(
                                Image(systemName: "sparkle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.8))
                            )
                            .rotationEffect(.degrees(Double(index - 1) * 15))
                    }
                }
                
                Text("Kartlar karıştırılıyor...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    // MARK: - Draw Cards
    private func drawCards() {
        isDrawing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isDrawing = false
            // Generate random cards based on spread
            drawnCards = (0..<selectedSpread.cardCount).map { _ in
                TarotCard.allCards.randomElement()!
            }
        }
    }
}

// MARK: - Tarot Spread
enum TarotSpread: CaseIterable {
    case singleCard
    case threeCard
    case celticCross
    
    var title: String {
        switch self {
        case .singleCard: return "Tek Kart"
        case .threeCard: return "3 Kart"
        case .celticCross: return "Kelt Haçı"
        }
    }
    
    var cardCount: Int {
        switch self {
        case .singleCard: return 1
        case .threeCard: return 3
        case .celticCross: return 10
        }
    }
    
    var positions: [String] {
        switch self {
        case .singleCard: return ["Genel"]
        case .threeCard: return ["Geçmiş", "Şimdi", "Gelecek"]
        case .celticCross: return ["Şimdi", "Engel", "Bilinç", "Altbilinç", "Geçmiş", "Gelecek", "Ben", "Çevre", "Umut", "Sonuç"]
        }
    }
}

// MARK: - Spread Button
struct SpreadButton: View {
    let spread: TarotSpread
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("\(spread.cardCount)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(spread.title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "#9B59B6") : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tarot Card
struct TarotCard: Identifiable {
    let id = UUID()
    let name: String
    let meaning: String
    let isReversed: Bool
    
    static let allCards: [TarotCard] = [
        TarotCard(name: "The Fool", meaning: "Yeni başlangıçlar, masumiyet", isReversed: false),
        TarotCard(name: "The Magician", meaning: "Yaratıcılık, irade gücü", isReversed: false),
        TarotCard(name: "The High Priestess", meaning: "Sezgi, gizem", isReversed: false),
        TarotCard(name: "The Empress", meaning: "Bereket, doğa", isReversed: false),
        TarotCard(name: "The Emperor", meaning: "Otorite, yapı", isReversed: false),
        TarotCard(name: "The Lovers", meaning: "Aşk, uyum", isReversed: false),
        TarotCard(name: "The Chariot", meaning: "Zafer, kontrol", isReversed: false),
        TarotCard(name: "Strength", meaning: "Güç, cesaret", isReversed: false),
        TarotCard(name: "The Hermit", meaning: "İçsel arayış", isReversed: false),
        TarotCard(name: "Wheel of Fortune", meaning: "Şans, döngüler", isReversed: false),
    ]
}

// MARK: - Tarot Card View
struct TarotCardView: View {
    let card: TarotCard
    let position: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Card
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#2D1B4E"), Color(hex: "#1A0F2E")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 80, height: 120)
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#C97CF6"))
                        
                        Text(card.name)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "#C97CF6").opacity(0.5), lineWidth: 1)
                )
            
            // Position
            Text(position)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview {
    TarotFortuneScreen()
}
