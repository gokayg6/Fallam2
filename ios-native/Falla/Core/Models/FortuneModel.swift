import Foundation

// MARK: - Fortune Model
struct FortuneModel: Codable, Identifiable {
    let id: String
    let type: FortuneType
    let title: String
    let description: String
    let result: String?
    let createdAt: Date
    let userId: String?
    
    init(
        id: String = UUID().uuidString,
        type: FortuneType,
        title: String,
        description: String = "",
        result: String? = nil,
        createdAt: Date = Date(),
        userId: String? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.result = result
        self.createdAt = createdAt
        self.userId = userId
    }
}

// MARK: - Fortune Type
enum FortuneType: String, Codable, CaseIterable {
    case tarot = "tarot"
    case coffee = "coffee"
    case astrology = "astrology"
    case love = "love"
    case daily = "daily"
    case dream = "dream"
    case palm = "palm"
    case face = "face"
    
    var displayName: String {
        switch self {
        case .tarot: return "Tarot Falı"
        case .coffee: return "Kahve Falı"
        case .astrology: return "Astroloji"
        case .love: return "Aşk Falı"
        case .daily: return "Günlük Fal"
        case .dream: return "Rüya Yorumu"
        case .palm: return "El Falı"
        case .face: return "Yüz Analizi"
        }
    }
    
    var iconName: String {
        switch self {
        case .tarot: return "rectangle.stack"
        case .coffee: return "cup.and.saucer"
        case .astrology: return "star"
        case .love: return "heart"
        case .daily: return "sun.max"
        case .dream: return "moon.stars"
        case .palm: return "hand.raised"
        case .face: return "face.smiling"
        }
    }
}
