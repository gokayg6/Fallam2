import SwiftUI

// MARK: - Aura Update Screen
struct AuraUpdateScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColor: AuraColor = .purple
    @State private var frequency: Double = 50
    @State private var animateContent = false
    @State private var showColorPicker = false
    @State private var isSaving = false
    @State private var pulseAnimation = false
    
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
                    VStack(spacing: 32) {
                        // Aura Visualization
                        auraVisualization
                        
                        // Color Selection
                        colorSection
                        
                        // Frequency Slider
                        frequencySection
                        
                        // Meaning Section
                        meaningSection
                        
                        // Save Button
                        saveButton
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
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
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
            
            Text("Aura Güncelle")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "info.circle")
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
    
    // MARK: - Aura Visualization
    private var auraVisualization: some View {
        ZStack {
            // Outer rings
            ForEach(0..<4) { i in
                Circle()
                    .stroke(
                        Color(hex: selectedColor.hex).opacity(0.2 - Double(i) * 0.05),
                        lineWidth: 2
                    )
                    .frame(
                        width: 150 + CGFloat(i) * 40 + (pulseAnimation ? 10 : 0),
                        height: 150 + CGFloat(i) * 40 + (pulseAnimation ? 10 : 0)
                    )
            }
            
            // Glow
            Circle()
                .fill(Color(hex: selectedColor.hex).opacity(0.3))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .scaleEffect(pulseAnimation ? 1.1 : 0.9)
            
            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: selectedColor.hex),
                            Color(hex: selectedColor.hex).opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .shadow(color: Color(hex: selectedColor.hex).opacity(0.5), radius: 30)
            
            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.white)
            
            // Frequency label
            VStack {
                Spacer()
                Text("\(Int(frequency)) Hz")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
            }
            .frame(height: 200)
        }
        .frame(height: 280)
        .opacity(animateContent ? 1 : 0)
        .scaleEffect(animateContent ? 1 : 0.8)
    }
    
    // MARK: - Color Section
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Aura Rengi")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(AuraColor.allCases, id: \.self) { color in
                    Button(action: { selectedColor = color }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: color.hex))
                                .frame(width: 50, height: 50)
                                .shadow(color: Color(hex: color.hex).opacity(0.5), radius: selectedColor == color ? 10 : 0)
                            
                            if selectedColor == color {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            
            Text("Seçilen: \(selectedColor.name)")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: selectedColor.hex))
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
    
    // MARK: - Frequency Section
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Frekans Seviyesi")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(frequency)) Hz")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: selectedColor.hex))
            }
            
            // Slider
            VStack(spacing: 8) {
                Slider(value: $frequency, in: 1...100, step: 1)
                    .tint(Color(hex: selectedColor.hex))
                
                HStack {
                    Text("Düşük")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text("Yüksek")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Frequency description
            Text(frequencyDescription)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
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
    }
    
    private var frequencyDescription: String {
        if frequency < 30 {
            return "Düşük frekans: Dingin, içe dönük ve huzurlu bir enerji. Meditasyon ve iç huzur için ideal."
        } else if frequency < 70 {
            return "Orta frekans: Dengeli ve uyumlu bir enerji. Günlük yaşam ve sosyal etkileşimler için ideal."
        } else {
            return "Yüksek frekans: Enerjik, dışa dönük ve tutkulu. Yaratıcılık ve liderlik için güçlü bir enerji."
        }
    }
    
    // MARK: - Meaning Section
    private var meaningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: selectedColor.hex))
                
                Text("\(selectedColor.name) Aura Anlamı")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(selectedColor.meaning)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(5)
            
            // Traits
            HStack(spacing: 8) {
                ForEach(selectedColor.traits, id: \.self) { trait in
                    Text(trait)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: selectedColor.hex).opacity(0.3))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: selectedColor.hex).opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: save) {
            HStack(spacing: 10) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Aura'yı Güncelle")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(hex: selectedColor.hex), Color(hex: selectedColor.hex).opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: selectedColor.hex).opacity(0.5), radius: 20, y: 10)
        }
        .disabled(isSaving)
        .opacity(animateContent ? 1 : 0)
    }
    
    private func save() {
        isSaving = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Aura Color Enum
enum AuraColor: CaseIterable {
    case purple, blue, green, yellow, orange, red, pink, turquoise
    
    var name: String {
        switch self {
        case .purple: return "Mor"
        case .blue: return "Mavi"
        case .green: return "Yeşil"
        case .yellow: return "Sarı"
        case .orange: return "Turuncu"
        case .red: return "Kırmızı"
        case .pink: return "Pembe"
        case .turquoise: return "Turkuaz"
        }
    }
    
    var hex: String {
        switch self {
        case .purple: return "#9B59B6"
        case .blue: return "#3498DB"
        case .green: return "#2ECC71"
        case .yellow: return "#F1C40F"
        case .orange: return "#E67E22"
        case .red: return "#E74C3C"
        case .pink: return "#EC4899"
        case .turquoise: return "#1ABC9C"
        }
    }
    
    var meaning: String {
        switch self {
        case .purple: return "Mor aura, spirituel farkındalık, sezgi ve bilgeliği temsil eder. Bu renk, derin düşünce ve meditasyonu simgeler."
        case .blue: return "Mavi aura, huzur, iletişim ve güveni temsil eder. Sakin ve dengeleyici bir enerji taşır."
        case .green: return "Yeşil aura, şifa, büyüme ve doğayla bağlantıyı temsil eder. Dengeli ve uyumlu bir enerji."
        case .yellow: return "Sarı aura, neşe, yaratıcılık ve intellektüel gücü temsil eder. Pozitif ve aydınlatıcı bir enerji."
        case .orange: return "Turuncu aura, tutku, macera ve cesareti temsil eder. Dinamik ve heyecan verici bir enerji."
        case .red: return "Kırmızı aura, güç, enerji ve yaşam gücünü temsil eder. Güçlü ve kararlı bir enerji."
        case .pink: return "Pembe aura, sevgi, şefkat ve romantizmi temsil eder. Nazik ve besleyici bir enerji."
        case .turquoise: return "Turkuaz aura, iyileşme, koruma ve iletişimi temsil eder. Sakinleştirici ve dengeleyici."
        }
    }
    
    var traits: [String] {
        switch self {
        case .purple: return ["Sezgisel", "Bilge", "Spiritüel"]
        case .blue: return ["Sakin", "Güvenilir", "İletişimci"]
        case .green: return ["Şifacı", "Dengeli", "Doğal"]
        case .yellow: return ["Yaratıcı", "Neşeli", "Zeki"]
        case .orange: return ["Cesur", "Maceracı", "Tutkulu"]
        case .red: return ["Güçlü", "Enerjik", "Kararlı"]
        case .pink: return ["Sevgi dolu", "Şefkatli", "Romantik"]
        case .turquoise: return ["Şifacı", "Koruyucu", "Sakin"]
        }
    }
}

#Preview {
    AuraUpdateScreen()
}
