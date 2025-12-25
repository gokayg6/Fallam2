import SwiftUI

// MARK: - Tests Screen
struct TestsScreen: View {
    @State private var selectedCategory: TestCategory = .available
    @State private var showingTest: QuizTestDefinition?
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Background - Gold/Teal Theme
            Image("theme_gold")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Overlay
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 16)
                
                // Category Selector
                categorySelector
                    .padding(.vertical, 16)
                
                // Tests List
                ScrollView(showsIndicators: false) {
                    if selectedCategory == .available {
                        availableTestsView
                    } else {
                        completedTestsView
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
        }
        .fullScreenCover(item: $showingTest) { test in
            TestQuestionScreen(testDefinition: test)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Testler")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Shimmer Badge
            Text("✨ YENİ")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#FFD700"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#FFD700").opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        HStack(spacing: 12) {
            CategoryButton(
                title: "Tümü",
                isSelected: selectedCategory == .available,
                color: Color(hex: "#C97CF6")
            ) {
                withAnimation(.spring(response: 0.3)) {
                    selectedCategory = .available
                }
            }
            
            CategoryButton(
                title: "Tamamlananlar",
                isSelected: selectedCategory == .completed,
                color: Color(hex: "#10B981")
            ) {
                withAnimation(.spring(response: 0.3)) {
                    selectedCategory = .completed
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Available Tests View
    private var availableTestsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Popular Tests Section
            VStack(alignment: .leading, spacing: 16) {
                shimmerSectionTitle("Popüler Testler")
                    .padding(.horizontal, 20)
                
                VStack(spacing: 14) {
                    ForEach(Array(QuizTestDefinition.popularTests.enumerated()), id: \.element.id) { index, test in
                        PopularTestCard(test: test, index: index) {
                            showingTest = test
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: appearAnimation)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Other Tests Section
            VStack(alignment: .leading, spacing: 16) {
                shimmerSectionTitle("Diğer Testler")
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    ForEach(Array(QuizTestDefinition.otherTests.enumerated()), id: \.element.id) { index, test in
                        OtherTestCard(test: test, index: index) {
                            showingTest = test
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.spring(response: 0.5).delay(0.3 + Double(index) * 0.06), value: appearAnimation)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Completed Tests View
    private var completedTestsView: some View {
        VStack(spacing: 20) {
            if QuizTestResult.sampleResults.isEmpty {
                emptyCompletedState
            } else {
                shimmerSectionTitle("Test Sonuçları")
                    .padding(.horizontal, 20)
                
                ForEach(QuizTestResult.sampleResults) { result in
                    CompletedTestCard(result: result)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer(minLength: 100)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Empty Completed State
    private var emptyCompletedState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "#C97CF6").opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Text("🧪")
                    .font(.system(size: 56))
            }
            
            Text("Henüz Test Yok")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text("Bir test tamamlayın ve\nsonuçlarınızı burada görün")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(40)
    }
    
    // MARK: - Shimmer Section Title
    private func shimmerSectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: "#C97CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected 
                            ? LinearGradient(colors: [color.opacity(0.5), color.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? color.opacity(0.5) : Color.white.opacity(0.15), lineWidth: isSelected ? 1.5 : 1)
                )
                .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Popular Test Card
struct PopularTestCard: View {
    let test: QuizTestDefinition
    let index: Int
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowAnimation = false
    
    var testColor: Color {
        Color(hex: test.type.colorHex)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(test.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(test.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                    
                    // Karma Badge
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text("\(test.karmaCost) Karma")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                // GIF/Image Icon with Glow
                ZStack {
                    // Animated Glow
                    Circle()
                        .fill(testColor.opacity(glowAnimation ? 0.4 : 0.2))
                        .frame(width: 85, height: 85)
                        .blur(radius: 12)
                    
                    // Glass Background
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .frame(width: 80, height: 80)
                    
                    // Color Overlay
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [testColor.opacity(0.4), testColor.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    // GIF Image or Emoji
                    if let imageName = test.imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else if let emoji = test.emoji {
                        Text(emoji)
                            .font(.system(size: 40))
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(18)
            .background(
                // Liquid Glass Effect
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Inner Glow
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [testColor.opacity(0.5), Color.white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: testColor.opacity(0.2), radius: 15, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.2)) { isPressed = false }
                }
        )
    }
}

// MARK: - Other Test Card
struct OtherTestCard: View {
    let test: QuizTestDefinition
    let index: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .frame(width: 52, height: 52)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "#C97CF6").opacity(0.2))
                        .frame(width: 52, height: 52)
                    
                    if let imageName = test.imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if let emoji = test.emoji {
                        Text(emoji)
                            .font(.system(size: 26))
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(test.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(test.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Completed Test Card
struct CompletedTestCard: View {
    let result: QuizTestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                // Emoji
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#10B981").opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Text(result.emoji)
                        .font(.system(size: 22))
                }
                
                // Title & Date
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.testTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(formatDate(result.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Completed Badge
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Tamamlandı")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#10B981"))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: "#10B981").opacity(0.15))
                .clipShape(Capsule())
            }
            
            // Result Preview
            Text(result.resultText)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(3)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "#10B981").opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Test Category
enum TestCategory {
    case available
    case completed
}

#Preview {
    TestsScreen()
}
