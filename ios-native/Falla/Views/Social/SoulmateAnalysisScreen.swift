import SwiftUI

// MARK: - Soulmate Analysis Screen
struct SoulmateAnalysisScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isAnalyzing = false
    @State private var analysisProgress: CGFloat = 0
    @State private var showResult = false
    @State private var animateContent = false
    @State private var glowAnimation = false
    @State private var candidates: [SoulmateCandidate] = []
    
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
                        if showResult {
                            resultSection
                        } else if isAnalyzing {
                            analyzingSection
                        } else {
                            introSection
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
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowAnimation = true
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
            
            Text("Ruh Eşi Analizi")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Intro Section
    private var introSection: some View {
        VStack(spacing: 24) {
            // Main Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "#C97CF6").opacity(glowAnimation ? 0.7 : 0.4), radius: 30)
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.white)
            }
            .opacity(animateContent ? 1 : 0)
            .scaleEffect(animateContent ? 1 : 0.8)
            
            VStack(spacing: 12) {
                Text("Ruh Eşini Bul")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Aura enerjini analiz edip sana en uygun kişileri bulalım")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            
            // Features
            VStack(spacing: 12) {
                featureRow(icon: "sparkles", text: "Aura frekansı eşleştirme")
                featureRow(icon: "star.fill", text: "Burç uyumu analizi")
                featureRow(icon: "heart.fill", text: "Kişilik uyumu hesaplama")
                featureRow(icon: "moon.stars.fill", text: "Kozmik enerji analizi")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#C97CF6").opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)
            
            // Start Button
            Button(action: startAnalysis) {
                HStack(spacing: 10) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 18))
                    Text("Analizi Başlat")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(hex: "#C97CF6").opacity(0.5), radius: 20, y: 10)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 40)
            
            // Karma Cost
            HStack(spacing: 6) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text("10 Karma gerekli")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#C97CF6"))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#10B981"))
        }
    }
    
    // MARK: - Analyzing Section
    private var analyzingSection: some View {
        VStack(spacing: 32) {
            // Animated Icon
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color(hex: "#C97CF6").opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                        .frame(width: CGFloat(100 + i * 30), height: CGFloat(100 + i * 30))
                        .scaleEffect(glowAnimation ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: glowAnimation)
                }
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(glowAnimation ? 5 : -5))
            }
            .padding(.top, 40)
            
            Text("Aura Analiz Ediliyor...")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            // Progress Bar
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.7 * analysisProgress, height: 12)
                }
                .frame(width: UIScreen.main.bounds.width * 0.7)
                
                Text("\(Int(analysisProgress * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
            
            // Status Text
            Text(analysisStatusText)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
    
    private var analysisStatusText: String {
        if analysisProgress < 0.3 {
            return "Aura frekansın taranıyor..."
        } else if analysisProgress < 0.6 {
            return "Uyumlu kişiler aranıyor..."
        } else if analysisProgress < 0.9 {
            return "Kozmik enerji hesaplanıyor..."
        } else {
            return "Sonuçlar hazırlanıyor..."
        }
    }
    
    // MARK: - Result Section
    private var resultSection: some View {
        VStack(spacing: 24) {
            // Success Header
            VStack(spacing: 12) {
                Text("🎉")
                    .font(.system(size: 48))
                
                Text("\(candidates.count) Potansiyel Eşleşme Bulundu!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Candidates List
            ForEach(candidates) { candidate in
                CandidateCard(candidate: candidate)
            }
            
            // Try Again Button
            Button(action: { 
                showResult = false
                candidates = []
            }) {
                Text("Yeni Analiz Yap")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
        }
    }
    
    // MARK: - Actions
    private func startAnalysis() {
        isAnalyzing = true
        analysisProgress = 0
        
        // Simulate analysis
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            analysisProgress += 0.01
            
            if analysisProgress >= 1.0 {
                timer.invalidate()
                
                // Generate results
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    candidates = [
                        SoulmateCandidate(id: "1", name: "Elif", age: 24, zodiac: "Kova", auraColor: "#C97CF6", compatibility: 92),
                        SoulmateCandidate(id: "2", name: "Zeynep", age: 26, zodiac: "Balık", auraColor: "#7B8CDE", compatibility: 87),
                        SoulmateCandidate(id: "3", name: "Merve", age: 23, zodiac: "Yay", auraColor: "#10B981", compatibility: 84)
                    ]
                    
                    withAnimation(.spring()) {
                        isAnalyzing = false
                        showResult = true
                    }
                }
            }
        }
    }
}

// MARK: - Soulmate Candidate Model
struct SoulmateCandidate: Identifiable {
    let id: String
    let name: String
    let age: Int
    let zodiac: String
    let auraColor: String
    let compatibility: Int
}

// MARK: - Candidate Card
struct CandidateCard: View {
    let candidate: SoulmateCandidate
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: candidate.auraColor).opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Text(candidate.name.prefix(1))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: candidate.auraColor))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(candidate.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("\(candidate.age) yaş")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text(candidate.zodiac)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Compatibility Score
            VStack(spacing: 2) {
                Text("\(candidate.compatibility)%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#10B981"))
                
                Text("uyum")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: candidate.auraColor).opacity(0.4), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SoulmateAnalysisScreen()
}
