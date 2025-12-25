import SwiftUI

// MARK: - Test Question Screen
struct TestQuestionScreen: View {
    let testDefinition: QuizTestDefinition
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var answers: [String: String] = [:]
    @State private var isSubmitting = false
    @State private var showResult = false
    @State private var showResultScreen = false
    @State private var resultText = ""
    @State private var animateQuestion = false
    @State private var selectedOption: String?
    @State private var testResult: QuizTestResult?
    
    private var currentQuestion: QuizQuestion {
        testDefinition.questions[currentQuestionIndex]
    }
    
    private var progress: CGFloat {
        CGFloat(currentQuestionIndex + 1) / CGFloat(testDefinition.questions.count)
    }
    
    var body: some View {
        ZStack {
            // Background
            Image("theme_purple")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Progress Bar
                progressBar
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Question Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Question Card
                        questionCard
                            .opacity(animateQuestion ? 1 : 0)
                            .offset(x: animateQuestion ? 0 : 50)
                        
                        // Options
                        optionsView
                            .opacity(animateQuestion ? 1 : 0)
                            .offset(y: animateQuestion ? 0 : 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .padding(.bottom, 120)
                }
                
                // Navigation Buttons
                navigationButtons
            }
            
            // Loading Overlay
            if isSubmitting {
                loadingOverlay
            }
            
            // Result Sheet
            if showResult {
                resultView
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            animateIn()
        }
        .fullScreenCover(isPresented: $showResultScreen) {
            if let result = testResult {
                TestResultScreen(result: result)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if let imageName = testDefinition.imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else if let emoji = testDefinition.emoji {
                        Text(emoji)
                            .font(.system(size: 18))
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#C97CF6"))
                    }
                    
                    Text(testDefinition.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Soru \(currentQuestionIndex + 1) / \(testDefinition.questions.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Karma Badge
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("\(testDefinition.karmaCost)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.1))
                
                // Progress
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
                    .animation(.spring(response: 0.5), value: progress)
                
                // Shimmer Effect
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 8)
    }
    
    // MARK: - Question Card
    private var questionCard: some View {
        VStack(spacing: 16) {
            // Large Image or Emoji
            if let imageName = testDefinition.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color(hex: "#C97CF6").opacity(0.3), radius: 10)
            } else if let emoji = testDefinition.emoji {
                Text(emoji)
                    .font(.system(size: 56))
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: "#C97CF6"))
            }
            
            // Question Text
            Text(currentQuestion.question)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Hint if exists
            if let hint = currentQuestion.hint {
                Text(hint)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "#C97CF6").opacity(0.1))
                
                // Inner Glow Border
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#C97CF6").opacity(0.5), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(color: Color(hex: "#C97CF6").opacity(0.2), radius: 20, y: 10)
    }
    
    // MARK: - Options View
    private var optionsView: some View {
        VStack(spacing: 12) {
            ForEach(Array(currentQuestion.options.enumerated()), id: \.element.id) { index, option in
                OptionButton(
                    option: option,
                    isSelected: answers[currentQuestion.id] == option.id,
                    index: index
                ) {
                    selectOption(option)
                }
            }
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back Button
            if currentQuestionIndex > 0 {
                Button(action: previousQuestion) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Geri")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 100, height: 54)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            
            Spacer()
            
            // Next/Complete Button
            Button(action: nextOrComplete) {
                HStack(spacing: 8) {
                    Text(currentQuestionIndex == testDefinition.questions.count - 1 ? "Tamamla" : "İleri")
                        .font(.system(size: 16, weight: .bold))
                    
                    if currentQuestionIndex < testDefinition.questions.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(height: 54)
                .frame(minWidth: 140)
                .background(
                    LinearGradient(
                        colors: answers[currentQuestion.id] != nil 
                            ? [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")]
                            : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: answers[currentQuestion.id] != nil ? Color(hex: "#C97CF6").opacity(0.4) : .clear, radius: 15, y: 5)
            }
            .disabled(answers[currentQuestion.id] == nil)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated Stars
                ZStack {
                    ForEach(0..<5) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#C97CF6"))
                            .offset(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: -40...40))
                            .opacity(0.8)
                            .animation(
                                .easeInOut(duration: 1)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                                value: isSubmitting
                            )
                    }
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                .frame(width: 80, height: 80)
                
                Text("Sonuçlar hazırlanıyor...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(50)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#10B981").opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(Color(hex: "#10B981"))
                }
                
                Text("Test Tamamlandı!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(resultText)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    Button(action: { showResultScreen = true }) {
                        Text("Sonucu Gör")
                            .font(.system(size: 16, weight: .bold))
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
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Kapat")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.horizontal, 24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // MARK: - Actions
    private func animateIn() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            animateQuestion = true
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.2)) {
            animateQuestion = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animateQuestion = true
            }
        }
    }
    
    private func selectOption(_ option: QuizOption) {
        withAnimation(.spring(response: 0.3)) {
            answers[currentQuestion.id] = option.id
        }
    }
    
    private func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        animateOut {
            currentQuestionIndex -= 1
        }
    }
    
    private func nextOrComplete() {
        if currentQuestionIndex < testDefinition.questions.count - 1 {
            animateOut {
                currentQuestionIndex += 1
            }
        } else {
            submitTest()
        }
    }
    
    private func submitTest() {
        isSubmitting = true
        
        // Simulate AI result generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isSubmitting = false
            
            // Create test result
            let generatedResult = "Cevaplarınız analiz edildi! \(testDefinition.title) sonuçlarınıza göre derin bir iç güce sahipsiniz. Empati yeteneğiniz yüksek ve çevrenize değer veriyorsunuz. Karar verirken hem mantığınızı hem de duygularınızı dengeleyebiliyorsunuz. Bu testte verdiğiniz cevaplar, kişiliğinizin farklı yönlerini ortaya koyuyor."
            
            testResult = QuizTestResult(
                id: UUID().uuidString,
                userId: "current_user",
                testId: testDefinition.id,
                testTitle: testDefinition.title,
                resultText: generatedResult,
                answers: answers,
                createdAt: Date()
            )
            
            resultText = generatedResult
            
            withAnimation(.spring(response: 0.5)) {
                showResult = true
            }
        }
    }
    
    private func navigateToResult() {
        showResultScreen = true
    }
}

// MARK: - Full Screen Cover for Result
extension TestQuestionScreen {
    @ViewBuilder
    func resultScreenDestination() -> some View {
        if let result = testResult {
            TestResultScreen(result: result)
        }
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let option: QuizOption
    let isSelected: Bool
    let index: Int
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Selection Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "#C97CF6") : Color.white.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "#C97CF6"))
                            .frame(width: 14, height: 14)
                    }
                }
                
                // Option Text
                Text(option.text)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isSelected 
                            ? LinearGradient(colors: [Color(hex: "#C97CF6").opacity(0.3), Color(hex: "#7B8CDE").opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color(hex: "#C97CF6").opacity(0.5) : Color.white.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                }
            )
            .scaleEffect(isPressed ? 0.97 : 1)
            .shadow(color: isSelected ? Color(hex: "#C97CF6").opacity(0.2) : .clear, radius: 10)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3)) { isPressed = false }
                }
        )
    }
}

#Preview {
    TestQuestionScreen(testDefinition: QuizTestDefinition.popularTests[0])
}
