import SwiftUI

// MARK: - Katina Fortune Screen
struct KatinaFortuneScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCards: [Int] = []
    @State private var isRevealing = false
    @State private var revealedCards: [KatinaCard] = []
    @State private var question: String = ""
    
    private let totalCards = 13
    private let cardsToSelect = 5
    
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
                        
                        // Question Section
                        questionSection
                        
                        // Card Selection
                        if revealedCards.isEmpty {
                            cardSelectionSection
                        } else {
                            // Revealed Cards
                            revealedCardsSection
                        }
                        
                        // Action Button
                        actionButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            
            // Revealing Overlay
            if isRevealing {
                revealingOverlay
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
            
            Text("Katina Falı")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Karma cost
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("7")
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
                                colors: [Color(hex: "#87CEEB"), Color(hex: "#5DADE2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Katina Falı")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("13 karttan 5 tanesini seçin")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("Katina falı, antik Yunan'dan gelen mistik bir kehanet sanatıdır. 13 kart arasından seçeceğiniz 5 kart, geleceğiniz hakkında önemli mesajlar verecektir. Kartları seçerken içgüdülerinize güvenin.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
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
            
            TextField("", text: $question, prompt: Text("Aklınızdaki soruyu yazın...").foregroundColor(.white.opacity(0.4)))
                .foregroundColor(.white)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Card Selection Section
    private var cardSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Kartlarınızı Seçin")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(selectedCards.count)/\(cardsToSelect)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selectedCards.count == cardsToSelect ? Color(hex: "#5DADE2") : .white.opacity(0.6))
            }
            
            // Card Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(1...totalCards, id: \.self) { cardNumber in
                    KatinaCardButton(
                        number: cardNumber,
                        isSelected: selectedCards.contains(cardNumber),
                        isDisabled: selectedCards.count >= cardsToSelect && !selectedCards.contains(cardNumber)
                    ) {
                        toggleCard(cardNumber)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Revealed Cards Section
    private var revealedCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kartlarınız")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(revealedCards.enumerated()), id: \.offset) { index, card in
                        RevealedKatinaCard(card: card, position: index + 1)
                    }
                }
            }
            
            // Interpretation
            VStack(alignment: .leading, spacing: 12) {
                Text("Yorum")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(revealedCards) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#5DADE2"))
                        
                        Text(card.meaning)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: revealedCards.isEmpty ? revealCards : resetCards) {
            HStack(spacing: 12) {
                Image(systemName: revealedCards.isEmpty ? "wand.and.stars" : "arrow.counterclockwise")
                    .font(.system(size: 18))
                Text(revealedCards.isEmpty ? "Kartları Aç" : "Yeniden Başla")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: selectedCards.count == cardsToSelect || !revealedCards.isEmpty
                        ? [Color(hex: "#87CEEB"), Color(hex: "#5DADE2")]
                        : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: selectedCards.count == cardsToSelect ? Color(hex: "#5DADE2").opacity(0.4) : .clear, radius: 20, x: 0, y: 8)
        }
        .disabled(selectedCards.count != cardsToSelect && revealedCards.isEmpty)
    }
    
    // MARK: - Revealing Overlay
    private var revealingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Card fan animation
                ZStack {
                    ForEach(0..<5, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#87CEEB"), Color(hex: "#5DADE2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 70)
                            .overlay(
                                Image(systemName: "sparkle")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                            )
                            .rotationEffect(.degrees(Double(index - 2) * 10))
                            .offset(x: CGFloat(index - 2) * 15)
                    }
                }
                
                Text("Kartlar açılıyor...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    // MARK: - Actions
    private func toggleCard(_ number: Int) {
        if let index = selectedCards.firstIndex(of: number) {
            selectedCards.remove(at: index)
        } else if selectedCards.count < cardsToSelect {
            selectedCards.append(number)
        }
    }
    
    private func revealCards() {
        isRevealing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRevealing = false
            revealedCards = selectedCards.map { _ in
                KatinaCard.allCards.randomElement()!
            }
        }
    }
    
    private func resetCards() {
        selectedCards = []
        revealedCards = []
    }
}

// MARK: - Katina Card Model
struct KatinaCard: Identifiable {
    let id = UUID()
    let name: String
    let meaning: String
    
    static let allCards: [KatinaCard] = [
        KatinaCard(name: "Güneş", meaning: "Başarı ve mutluluk kapıda. Parlak günler sizi bekliyor."),
        KatinaCard(name: "Ay", meaning: "Duygusal değişimler yaşayacaksınız. İç sesinizi dinleyin."),
        KatinaCard(name: "Yıldız", meaning: "Umut ve ilham dolu bir dönem başlıyor."),
        KatinaCard(name: "Kalp", meaning: "Aşk hayatınızda güzel gelişmeler olacak."),
        KatinaCard(name: "Anahtar", meaning: "Yeni fırsatların kapısı açılıyor."),
        KatinaCard(name: "Kule", meaning: "Ani değişikliklere hazırlıklı olun."),
        KatinaCard(name: "Çiçek", meaning: "Güzellik ve bereket hayatınıza girecek."),
        KatinaCard(name: "Kuş", meaning: "Haberler geliyor. İletişim önem kazanacak."),
        KatinaCard(name: "Balık", meaning: "Maddi kazanç ve bolluk dönemine giriyorsunuz."),
        KatinaCard(name: "Gemi", meaning: "Yolculuklar ve yeni başlangıçlar."),
        KatinaCard(name: "Kitap", meaning: "Gizli bilgiler ortaya çıkacak."),
        KatinaCard(name: "Halka", meaning: "Ortaklıklar ve bağlantılar güçlenecek."),
        KatinaCard(name: "Baykuş", meaning: "Bilgelik ve içgörü kazanacaksınız."),
    ]
}

// MARK: - Katina Card Button
struct KatinaCardButton: View {
    let number: Int
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                            ? LinearGradient(colors: [Color(hex: "#87CEEB"), Color(hex: "#5DADE2")], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(height: 60)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(isDisabled ? 0.3 : 0.7))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - Revealed Katina Card
struct RevealedKatinaCard: View {
    let card: KatinaCard
    let position: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1A3A5C"), Color(hex: "#0D1F33")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 110)
                
                VStack(spacing: 6) {
                    Image(systemName: iconForCard(card.name))
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#87CEEB"))
                    
                    Text(card.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#5DADE2").opacity(0.5), lineWidth: 1)
            )
            
            Text("\(position). Kart")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private func iconForCard(_ name: String) -> String {
        switch name {
        case "Güneş": return "sun.max.fill"
        case "Ay": return "moon.fill"
        case "Yıldız": return "star.fill"
        case "Kalp": return "heart.fill"
        case "Anahtar": return "key.fill"
        case "Kule": return "building.2.fill"
        case "Çiçek": return "leaf.fill"
        case "Kuş": return "bird.fill"
        case "Balık": return "fish.fill"
        case "Gemi": return "sailboat.fill"
        case "Kitap": return "book.fill"
        case "Halka": return "circle"
        case "Baykuş": return "owl"
        default: return "sparkle"
        }
    }
}

#Preview {
    KatinaFortuneScreen()
}
