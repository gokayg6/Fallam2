import SwiftUI

// MARK: - Astrology Calendar Screen
struct AstrologyCalendarScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var animateContent = false
    @State private var selectedEvent: AstrologyEvent?
    
    private let calendar = Calendar.current
    
    private var events: [AstrologyEvent] {
        [
            AstrologyEvent(id: "1", title: "Yeni Ay", date: getDateInMonth(day: 5), type: .newMoon, description: "Yeni başlangıçlar için ideal"),
            AstrologyEvent(id: "2", title: "Dolunay", date: getDateInMonth(day: 19), type: .fullMoon, description: "Enerji dorukta"),
            AstrologyEvent(id: "3", title: "Merkür Retrosu Başlangıç", date: getDateInMonth(day: 12), type: .retrograde, description: "İletişimde dikkatli ol"),
            AstrologyEvent(id: "4", title: "Venüs-Mars Kavuşumu", date: getDateInMonth(day: 25), type: .conjunction, description: "Aşk enerjisi yüksek")
        ]
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
                        // Calendar
                        calendarSection
                        
                        // Events for selected date
                        eventsSection
                        
                        // Moon Phase
                        moonPhaseSection
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
            
            Text("Astroloji Takvimi")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { selectedDate = Date(); currentMonth = Date() }) {
                Text("Bugün")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#C97CF6"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            // Weekday Headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvent: hasEvent(on: date),
                            onTap: { selectedDate = date }
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
    }
    
    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Astrolojik Olaylar")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            let dayEvents = events.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            
            if dayEvents.isEmpty {
                HStack {
                    Image(systemName: "calendar.badge.minus")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Bu tarihte özel bir olay yok")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
            } else {
                ForEach(dayEvents) { event in
                    EventCard(event: event)
                }
            }
            
            // Upcoming Events
            if !dayEvents.isEmpty || events.isEmpty {
                Text("Yaklaşan Olaylar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 8)
                
                ForEach(upcomingEvents.prefix(3)) { event in
                    EventCard(event: event)
                }
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    private var upcomingEvents: [AstrologyEvent] {
        events.filter { $0.date > selectedDate }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Moon Phase Section
    private var moonPhaseSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text("🌙")
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ay Fazı")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(currentMoonPhase)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#C97CF6"))
                }
                
                Spacer()
                
                // Moon phase visualization
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .mask(
                            Rectangle()
                                .frame(width: 25)
                                .offset(x: -12.5)
                        )
                }
            }
            
            Text("Ay fazı enerjinin akışını etkiler. Şu an \(currentMoonPhase.lowercased()) döneminde olduğun için \(moonPhaseAdvice).")
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
                        .stroke(Color(hex: "#C97CF6").opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
    }
    
    private var currentMoonPhase: String {
        let day = calendar.component(.day, from: selectedDate)
        switch day % 30 {
        case 0...3: return "Yeni Ay"
        case 4...10: return "Hilal (Büyüyen)"
        case 11...14: return "İlk Dördün"
        case 15...17: return "Dolunay"
        case 18...21: return "Küçülen Ay"
        case 22...28: return "Son Dördün"
        default: return "Yeni Ay'a Doğru"
        }
    }
    
    private var moonPhaseAdvice: String {
        switch currentMoonPhase {
        case "Yeni Ay": return "yeni başlangıçlar için ideal bir zaman"
        case "Dolunay": return "enerjin dorukta, tamamlama zamanı"
        default: return "içsel çalışmalar için uygun"
        }
    }
    
    // MARK: - Helpers
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: currentMonth)
    }
    
    private func daysInMonth() -> [Date?] {
        var days: [Date?] = []
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        // Adjust for Monday start (1 = Sunday in Calendar)
        let startOffset = (firstWeekday + 5) % 7
        
        for _ in 0..<startOffset {
            days.append(nil)
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasEvent(on date: Date) -> Bool {
        events.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func getDateInMonth(day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

// MARK: - Models
struct AstrologyEvent: Identifiable {
    let id: String
    let title: String
    let date: Date
    let type: AstrologyEventType
    let description: String
}

enum AstrologyEventType {
    case newMoon, fullMoon, retrograde, conjunction, eclipse
    
    var icon: String {
        switch self {
        case .newMoon: return "moon.fill"
        case .fullMoon: return "moon.circle.fill"
        case .retrograde: return "arrow.uturn.backward.circle"
        case .conjunction: return "star.fill"
        case .eclipse: return "circle.lefthalf.filled"
        }
    }
    
    var color: String {
        switch self {
        case .newMoon: return "#7B8CDE"
        case .fullMoon: return "#F59E0B"
        case .retrograde: return "#EF4444"
        case .conjunction: return "#10B981"
        case .eclipse: return "#8B5CF6"
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvent: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isSelected || isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? Color(hex: "#C97CF6") : .white.opacity(0.8)))
                
                if hasEvent {
                    Circle()
                        .fill(Color(hex: "#C97CF6"))
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                    ? Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#C97CF6"), Color(hex: "#7B8CDE")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    : nil
            )
        }
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: AstrologyEvent
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: event.type.color).opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: event.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: event.type.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(event.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(formatEventDate(event.date))
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: event.type.color).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

#Preview {
    AstrologyCalendarScreen()
}
