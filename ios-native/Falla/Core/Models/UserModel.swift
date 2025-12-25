import Foundation

// MARK: - User Model
struct UserModel: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String
    var photoURL: String?
    var birthDate: Date?
    var zodiacSign: String?
    var gender: String?
    var isPremium: Bool
    var credits: Int
    var createdAt: Date
    var lastLoginAt: Date?
    
    init(
        id: String = UUID().uuidString,
        email: String = "",
        displayName: String = "",
        photoURL: String? = nil,
        birthDate: Date? = nil,
        zodiacSign: String? = nil,
        gender: String? = nil,
        isPremium: Bool = false,
        credits: Int = 0,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.birthDate = birthDate
        self.zodiacSign = zodiacSign
        self.gender = gender
        self.isPremium = isPremium
        self.credits = credits
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
}

// MARK: - User Model Extensions
extension UserModel {
    static var empty: UserModel {
        UserModel()
    }
    
    var isGuest: Bool {
        email.isEmpty
    }
}
