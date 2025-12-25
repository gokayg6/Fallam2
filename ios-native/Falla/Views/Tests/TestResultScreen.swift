import SwiftUI

// MARK: - Test Result Screen
struct TestResultScreen: View {
    let result: QuizTestResult
    @Environment(\.dismiss) private var dismiss
    
    @State private var isFavorite = false
    @State private var showShareSheet = false
    @State private var animateContent = false
    @State private var animateResult = false
    @State private var glowAnimation = false
    
    // Simulated countdown (in production, this would be from Firebase)
    @State private var remainingSeconds = 15 * 60 // 15 minutes
    @State private var isLocked = true
    @State private var isSpeedingUp = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                        // Test Header Card
                        testHeaderCard
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                        
                        // Result or Locked Card
                        if isLocked {
                            lockedCard
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 40)
                        } else {
                            resultCard
                                .opacity(animateResult ? 1 : 0)
                                .scaleEffect(animateResult ? 1 : 0.9)
                        }
                        
                        // Action Buttons (only show when unlocked)
                        if !isLocked {
                            actionButtons
                                .opacity(animateResult ? 1 : 0)
                                .offset(y: animateResult ? 0 : 20)
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
            
            // Simulate: if result was created more than 15 minutes ago, unlock
            let timeSinceCreation = Date().timeIntervalSince(result.createdAt)
            if timeSinceCreation > 15 * 60 {
                isLocked = false
                remainingSeconds = 0
            } else {
                remainingSeconds = max(0, Int(15 * 60 - timeSinceCreation))
            }
        }
        .onReceive(timer) { _ in
            if remainingSeconds > 0 && isLocked {
                remainingSeconds -= 1
            } else if remainingSeconds <= 0 && isLocked {
                unlockResult()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
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
            
            Text("Test Sonucu")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { 
                withAnimation(.spring(response: 0.3)) {
                    isFavorite.toggle()
                }
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundColor(isFavorite ? .red : .white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Test Header Card
    private var testHeaderCard: some View {
        VStack(spacing: 16) {
            // Emoji
            Text(result.emoji ?? "✨")
                .font(.system(size: 56))
            
            // Title
            Text(result.testTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Date
            Text(formatDate(result.createdAt))
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.4), Color(hex: "#7B8CDE").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.6), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(color: Color(hex: "#C97CF6").opacity(0.3), radius: 20, y: 10)
    }
    
    // MARK: - Locked Card
    private var lockedCard: some View {
        VStack(spacing: 20) {
            // Psychology Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: Color(hex: "#C97CF6").opacity(glowAnimation ? 0.6 : 0.3), radius: 20)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            // Title
            Text("Sonuç Hazırlanıyor")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Yapay zeka test sonuçlarını analiz ediyor...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            // Countdown Timer
            VStack(spacing: 8) {
                Text("Kalan Süre")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(formattedTime)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Speed Up Button
            Button(action: speedUp) {
                HStack(spacing: 10) {
                    if isSpeedingUp {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                        Text("Hızlandır (Reklam İzle)")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "#C97CF6").opacity(0.4), radius: 15, y: 5)
            }
            .disabled(isSpeedingUp)
            
            // Info
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#C97CF6"))
                
                Text("Reklam izleyerek 5 dakika hızlandırabilirsiniz")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#C97CF6").opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "#C97CF6").opacity(0.3), lineWidth: 1)
            }
        )
    }
    
    // MARK: - Result Card
    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#C97CF6").opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#C97CF6"))
                }
                
                Text("Analiz Sonucu")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Result Text
            Text(result.resultText)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(6)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Success Badge
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#10B981"))
                
                Text("Analiz tamamlandı")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#10B981"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(hex: "#10B981").opacity(0.15))
            .clipShape(Capsule())
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.4), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color(hex: "#C97CF6").opacity(0.2), radius: 15, y: 8)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 14) {
            // Share Button
            Button(action: { showShareSheet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                    Text("Paylaş")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // Copy Button
            Button(action: copyToClipboard) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16))
                    Text("Kopyala")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    // MARK: - Computed Properties
    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var shareText: String {
        """
        \(result.emoji ?? "✨") \(result.testTitle)
        
        \(result.resultText)
        
        Tarih: \(formatDate(result.createdAt))
        
        #Falla #TestSonucu
        """
    }
    
    // MARK: - Functions
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Bugün \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Dün"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.string(from: date)
        }
    }
    
    private func speedUp() {
        isSpeedingUp = true
        
        // Simulate watching ad and speeding up by 5 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSpeedingUp = false
            remainingSeconds = max(0, remainingSeconds - 5 * 60)
            
            if remainingSeconds <= 0 {
                unlockResult()
            }
        }
    }
    
    private func unlockResult() {
        isLocked = false
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animateResult = true
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = shareText
        // In production, show a toast/notification
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - QuizTestResult Extension for emoji
extension QuizTestResult {
    var emoji: String? {
        // Return emoji based on testId
        switch testId {
        case "personality": return "🧠"
        case "friendship": return "👥"
        case "love": return "❤️"
        case "compatibility": return "💕"
        case "love_what_you_want": return "💞"
        case "red_flags": return "🚩"
        case "funny": return "🎭"
        case "chaos": return "🌪️"
        case "super_power": return "⚡"
        case "planet_energy": return "🪐"
        case "soulmate_zodiac": return "💞"
        case "mental_health_color": return "🎨"
        case "spirit_animal": return "🦋"
        case "energy_stage": return "✨"
        default: return "✨"
        }
    }
}

#Preview {
    TestResultScreen(result: QuizTestResult(
        id: "test1",
        userId: "user1",
        testId: "personality",
        testTitle: "Kişilik Testi",
        resultText: "Analiz sonuçlarına göre sen içsel bir güce sahip, derin düşünen bir kişiliğe sahipsin. Empati yeteneğin yüksek ve çevrene değer veriyorsun. Karar verirken hem mantığını hem de duygularını dengeleyebiliyorsun.",
        answers: ["p1": "a2", "p2": "a3"],
        createdAt: Date()
    ))
}
