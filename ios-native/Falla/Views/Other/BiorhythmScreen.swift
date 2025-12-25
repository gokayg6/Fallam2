import SwiftUI

// MARK: - Biorhythm Screen
struct BiorhythmScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var animateContent = false
    @State private var showDatePicker = false
    
    private var daysSinceBirth: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: selectedDate).day ?? 0
    }
    
    private var physicalValue: Double {
        sin(2 * .pi * Double(daysSinceBirth) / 23.0)
    }
    
    private var emotionalValue: Double {
        sin(2 * .pi * Double(daysSinceBirth) / 28.0)
    }
    
    private var intellectualValue: Double {
        sin(2 * .pi * Double(daysSinceBirth) / 33.0)
    }
    
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
                        // Date Navigation
                        dateNavigation
                        
                        // Biorhythm Chart
                        biorhythmChart
                        
                        // Values Cards
                        valuesSection
                        
                        // Info Section
                        infoSection
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
            
            Text("Biyoritm")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { showDatePicker = true }) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .sheet(isPresented: $showDatePicker) {
            birthDatePicker
        }
    }
    
    // MARK: - Date Navigation
    private var dateNavigation: some View {
        HStack(spacing: 16) {
            Button(action: previousDay) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(spacing: 4) {
                Text(formatDate(selectedDate))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Gün \(daysSinceBirth)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            
            Button(action: nextDay) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .opacity(animateContent ? 1 : 0)
    }
    
    // MARK: - Biorhythm Chart
    private var biorhythmChart: some View {
        VStack(spacing: 16) {
            Text("Biyoritm Döngüleri")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            // Simple visualization
            ZStack {
                // Grid lines
                ForEach(-2..<3) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                        .offset(y: CGFloat(i) * 30)
                }
                
                // Center line (0)
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 2)
                
                // Physical curve
                WavePath(amplitude: 50, frequency: 23, phase: Double(daysSinceBirth))
                    .stroke(Color(hex: "#EF4444"), lineWidth: 3)
                
                // Emotional curve
                WavePath(amplitude: 50, frequency: 28, phase: Double(daysSinceBirth))
                    .stroke(Color(hex: "#3B82F6"), lineWidth: 3)
                
                // Intellectual curve
                WavePath(amplitude: 50, frequency: 33, phase: Double(daysSinceBirth))
                    .stroke(Color(hex: "#10B981"), lineWidth: 3)
                
                // Current day marker
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 120)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Legend
            HStack(spacing: 20) {
                legendItem(color: "#EF4444", title: "Fiziksel")
                legendItem(color: "#3B82F6", title: "Duygusal")
                legendItem(color: "#10B981", title: "Entelektüel")
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
    
    private func legendItem(color: String, title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 10, height: 10)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // MARK: - Values Section
    private var valuesSection: some View {
        VStack(spacing: 12) {
            biorhythmCard(
                title: "Fiziksel",
                value: physicalValue,
                color: "#EF4444",
                icon: "figure.run",
                description: "Enerji, güç ve dayanıklılık"
            )
            
            biorhythmCard(
                title: "Duygusal",
                value: emotionalValue,
                color: "#3B82F6",
                icon: "heart.fill",
                description: "Duygu durumu ve yaratıcılık"
            )
            
            biorhythmCard(
                title: "Entelektüel",
                value: intellectualValue,
                color: "#10B981",
                icon: "brain.head.profile",
                description: "Zihinsel netlik ve odaklanma"
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
    }
    
    private func biorhythmCard(title: String, value: Double, color: String, icon: String, description: String) -> some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: color))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Value
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(round(value * 100)))%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: color))
                
                Text(valueLabel(value))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: color).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func valueLabel(_ value: Double) -> String {
        if value > 0.5 {
            return "Yüksek"
        } else if value > 0 {
            return "Pozitif"
        } else if value > -0.5 {
            return "Negatif"
        } else {
            return "Düşük"
        }
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "#C97CF6"))
                
                Text("Biyoritm Nedir?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Biyoritm, doğum tarihinizden itibaren düzenli döngüler halinde değişen fiziksel, duygusal ve entelektüel durumunuzu gösterir. Her döngü farklı bir süreye sahiptir: Fiziksel 23 gün, Duygusal 28 gün, Entelektüel 33 gün.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#C97CF6").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#C97CF6").opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
    }
    
    // MARK: - Birth Date Picker
    private var birthDatePicker: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Doğum Tarihinizi Seçin")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    DatePicker("", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                }
                .padding()
            }
            .navigationTitle("Doğum Tarihi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        showDatePicker = false
                    }
                    .foregroundColor(Color(hex: "#C97CF6"))
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func previousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// MARK: - Wave Path
struct WavePath: Shape {
    let amplitude: CGFloat
    let frequency: Double
    let phase: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height / 2
        
        path.move(to: CGPoint(x: 0, y: midY))
        
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = Double(x) / Double(width) * 14 - 7 // Show 7 days before and after
            let dayOffset = phase + relativeX
            let y = midY - CGFloat(sin(2 * .pi * dayOffset / frequency)) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

#Preview {
    BiorhythmScreen()
}
