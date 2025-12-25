import Foundation

// MARK: - Test Type
enum TestType: String, CaseIterable, Codable {
    case love = "love"
    case personality = "personality"
    case compatibility = "compatibility"
    case career = "career"
    case friendship = "friendship"
    case family = "family"
    case spiritual = "spiritual"
    
    var displayName: String {
        switch self {
        case .love: return "Aşk Testi"
        case .personality: return "Kişilik Testi"
        case .compatibility: return "Uyumluluk Testi"
        case .career: return "Kariyer Testi"
        case .friendship: return "Arkadaşlık Testi"
        case .family: return "Aile Testi"
        case .spiritual: return "Ruhani Test"
        }
    }
    
    var colorHex: String {
        switch self {
        case .love: return "#E88BC4"
        case .personality: return "#C97CF6"
        case .compatibility: return "#9B8ED0"
        case .career: return "#E6D3A3"
        case .friendship: return "#7CC4A4"
        case .family: return "#82B4D9"
        case .spiritual: return "#FFB366"
        }
    }
}

// MARK: - Test Status
enum TestStatus: String, Codable {
    case available = "available"
    case inProgress = "in_progress"
    case completed = "completed"
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [QuizOption]
    let hint: String?
    
    init(id: String, question: String, options: [QuizOption], hint: String? = nil) {
        self.id = id
        self.question = question
        self.options = options
        self.hint = hint
    }
}

// MARK: - Quiz Option
struct QuizOption: Identifiable, Codable {
    let id: String
    let text: String
    let score: Int
    
    init(id: String, text: String, score: Int = 0) {
        self.id = id
        self.text = text
        self.score = score
    }
}

// MARK: - Quiz Test Definition
struct QuizTestDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let imageName: String?
    let emoji: String?
    let type: TestType
    let questions: [QuizQuestion]
    let karmaCost: Int
    
    init(id: String, title: String, description: String, imageName: String? = nil, emoji: String? = nil, type: TestType, questions: [QuizQuestion], karmaCost: Int = 5) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
        self.emoji = emoji
        self.type = type
        self.questions = questions
        self.karmaCost = karmaCost
    }
    
    // MARK: - All 14 Tests from Dart Project
    
    // Popular Tests (5)
    static let popularTests: [QuizTestDefinition] = [
        // 1. Kişilik Testi
        QuizTestDefinition(
            id: "personality",
            title: "Kişilik Testi",
            description: "Gerçek kişiliğini keşfet",
            imageName: "test_personality",
            type: .personality,
            questions: personalityQuestions
        ),
        // 2. Arkadaşlık Testi
        QuizTestDefinition(
            id: "friendship",
            title: "Arkadaşlık Testi",
            description: "Ne tür bir arkadaşsın?",
            imageName: "test_friendship",
            type: .friendship,
            questions: friendshipQuestions
        ),
        // 3. Aşk Testi
        QuizTestDefinition(
            id: "love",
            title: "Aşk Testi",
            description: "Aşk dilin ne?",
            imageName: "test_love",
            type: .love,
            questions: loveQuestions
        ),
        // 4. İlişki Uyum Testi
        QuizTestDefinition(
            id: "compatibility",
            title: "İlişki Uyum Testi",
            description: "Partnerinle ne kadar uyumlusunuz?",
            imageName: "test_compatibility",
            type: .compatibility,
            questions: compatibilityQuestions
        ),
        // 5. İlişkinde Ne İstiyorsun
        QuizTestDefinition(
            id: "love_what_you_want",
            title: "İlişkinde Ne İstiyorsun?",
            description: "Bir ilişkiden gerçekten ne bekliyorsun?",
            imageName: "test_love_want",
            type: .love,
            questions: loveWantQuestions
        )
    ]
    
    // Other Tests (9)
    static let otherTests: [QuizTestDefinition] = [
        // 6. Kırmızı Bayraklar Testi
        QuizTestDefinition(
            id: "red_flags",
            title: "Kırmızı Bayraklar Testi",
            description: "Aşkta kırmızı bayrakları görebiliyor musun?",
            emoji: "🚩",
            type: .love,
            questions: redFlagsQuestions
        ),
        // 7. Ne Kadar Eğlencelisin
        QuizTestDefinition(
            id: "funny",
            title: "Ne Kadar Eğlencelisin?",
            description: "Burcuna göre eğlence seviyeni ölç",
            emoji: "🎭",
            type: .personality,
            questions: funnyQuestions
        ),
        // 8. Ne Kadar Kaotiksin
        QuizTestDefinition(
            id: "chaos",
            title: "Ne Kadar Kaotiksin?",
            description: "Burcuna göre kaos seviyeni öğren",
            emoji: "🌪️",
            type: .personality,
            questions: chaosQuestions
        ),
        // 9. Gizli Süper Gücün Ne
        QuizTestDefinition(
            id: "super_power",
            title: "Gizli Süper Gücün Ne?",
            description: "İçindeki gizli gücü keşfet",
            emoji: "⚡",
            type: .spiritual,
            questions: superPowerQuestions
        ),
        // 10. Hangi Gezegenin Enerjisi Sende Baskın
        QuizTestDefinition(
            id: "planet_energy",
            title: "Hangi Gezegenin Enerjisi Sende?",
            description: "Kozmik enerjini keşfet",
            emoji: "🪐",
            type: .spiritual,
            questions: planetEnergyQuestions
        ),
        // 11. Ruh Eşin Hangi Burçtan
        QuizTestDefinition(
            id: "soulmate_zodiac",
            title: "Ruh Eşin Hangi Burçtan?",
            description: "Kozmik eşini bul",
            emoji: "💞",
            type: .love,
            questions: soulmateZodiacQuestions
        ),
        // 12. Ruh Sağlığını Yansıtan Renk
        QuizTestDefinition(
            id: "mental_health_color",
            title: "Ruh Sağlığını Yansıtan Renk",
            description: "İç dünyanın rengini keşfet",
            emoji: "🎨",
            type: .spiritual,
            questions: mentalHealthColorQuestions
        ),
        // 13. Ruhsal Hayvanın Ne
        QuizTestDefinition(
            id: "spirit_animal",
            title: "Ruhsal Hayvanın Ne?",
            description: "Ruh hayvanını keşfet",
            emoji: "🦋",
            type: .spiritual,
            questions: spiritAnimalQuestions
        ),
        // 14. Şu Anda Enerjin Hangi Aşamada
        QuizTestDefinition(
            id: "energy_stage",
            title: "Enerjin Hangi Aşamada?",
            description: "Şu anki enerji seviyeni ölç",
            emoji: "✨",
            type: .spiritual,
            questions: energyStageQuestions
        )
    ]
    
    // MARK: - Questions for Each Test
    
    // 1. Personality Test Questions (7 questions)
    static let personalityQuestions: [QuizQuestion] = [
        QuizQuestion(id: "p1", question: "Bir partide genellikle ne yaparsın?", options: [
            QuizOption(id: "a1", text: "Herkesin gözdesi olurum", score: 4),
            QuizOption(id: "a2", text: "Yakın arkadaşlarımla sohbet ederim", score: 3),
            QuizOption(id: "a3", text: "Köşede sessizce gözlem yaparım", score: 2),
            QuizOption(id: "a4", text: "Mümkünse evde kalırım", score: 1)
        ]),
        QuizQuestion(id: "p2", question: "Stresle nasıl başa çıkarsın?", options: [
            QuizOption(id: "a1", text: "Spor yaparak", score: 4),
            QuizOption(id: "a2", text: "Müzik dinleyerek", score: 3),
            QuizOption(id: "a3", text: "Arkadaşlarımla konuşarak", score: 2),
            QuizOption(id: "a4", text: "Yalnız kalarak", score: 1)
        ]),
        QuizQuestion(id: "p3", question: "Karar verirken neye güvenirsin?", options: [
            QuizOption(id: "a1", text: "Mantığıma", score: 4),
            QuizOption(id: "a2", text: "Duygularıma", score: 3),
            QuizOption(id: "a3", text: "Başkalarının fikirlerine", score: 2),
            QuizOption(id: "a4", text: "İç sesime", score: 1)
        ]),
        QuizQuestion(id: "p4", question: "Hafta sonu ideal planın ne?", options: [
            QuizOption(id: "a1", text: "Dışarıda macera", score: 4),
            QuizOption(id: "a2", text: "Arkadaşlarla buluşma", score: 3),
            QuizOption(id: "a3", text: "Evde kitap/film", score: 2),
            QuizOption(id: "a4", text: "Yeni bir hobi denemek", score: 1)
        ]),
        QuizQuestion(id: "p5", question: "Bir sorunla karşılaştığında ne yaparsın?", options: [
            QuizOption(id: "a1", text: "Hemen çözüm ararım", score: 4),
            QuizOption(id: "a2", text: "Biraz düşünür sonra harekete geçerim", score: 3),
            QuizOption(id: "a3", text: "Yardım isterim", score: 2),
            QuizOption(id: "a4", text: "Kendiliğinden çözülmesini beklerim", score: 1)
        ]),
        QuizQuestion(id: "p6", question: "Başarı senin için ne demek?", options: [
            QuizOption(id: "a1", text: "Maddi güvence", score: 4),
            QuizOption(id: "a2", text: "Mutlu olmak", score: 3),
            QuizOption(id: "a3", text: "Sevdiklerimle vakit geçirmek", score: 2),
            QuizOption(id: "a4", text: "Kendi kendime yetebilmek", score: 1)
        ]),
        QuizQuestion(id: "p7", question: "Yeni insanlarla tanışırken nasıl hissedersin?", options: [
            QuizOption(id: "a1", text: "Heyecanlı", score: 4),
            QuizOption(id: "a2", text: "Meraklı", score: 3),
            QuizOption(id: "a3", text: "Çekingen", score: 2),
            QuizOption(id: "a4", text: "Tedirgin", score: 1)
        ])
    ]
    
    // 2. Friendship Test Questions (5 questions)
    static let friendshipQuestions: [QuizQuestion] = [
        QuizQuestion(id: "f1", question: "Arkadaşın sıkıntıda olduğunda ne yaparsın?", options: [
            QuizOption(id: "a1", text: "Hemen yanına koşarım", score: 4),
            QuizOption(id: "a2", text: "Telefonla arıyorum", score: 3),
            QuizOption(id: "a3", text: "Mesaj atarım", score: 2),
            QuizOption(id: "a4", text: "Çözüm önerileri sunarım", score: 1)
        ]),
        QuizQuestion(id: "f2", question: "Grup planlarında rolün ne?", options: [
            QuizOption(id: "a1", text: "Organizatör", score: 4),
            QuizOption(id: "a2", text: "Fikir üreticisi", score: 3),
            QuizOption(id: "a3", text: "Akışa bırakan", score: 2),
            QuizOption(id: "a4", text: "Eleştirmen", score: 1)
        ]),
        QuizQuestion(id: "f3", question: "Arkadaşlıkta en önemli şey ne?", options: [
            QuizOption(id: "a1", text: "Güven", score: 4),
            QuizOption(id: "a2", text: "Eğlence", score: 3),
            QuizOption(id: "a3", text: "Destek", score: 2),
            QuizOption(id: "a4", text: "Dürüstlük", score: 1)
        ]),
        QuizQuestion(id: "f4", question: "Arkadaşınla anlaşmazlık yaşadığında?", options: [
            QuizOption(id: "a1", text: "Hemen konuşurum", score: 4),
            QuizOption(id: "a2", text: "Biraz beklerim", score: 3),
            QuizOption(id: "a3", text: "Üstünü örterim", score: 2),
            QuizOption(id: "a4", text: "Mesafe koyarım", score: 1)
        ]),
        QuizQuestion(id: "f5", question: "İdeal arkadaş sayın?", options: [
            QuizOption(id: "a1", text: "Çok sayıda arkadaş", score: 4),
            QuizOption(id: "a2", text: "Orta karar bir grup", score: 3),
            QuizOption(id: "a3", text: "Birkaç yakın arkadaş", score: 2),
            QuizOption(id: "a4", text: "Bir veya iki can dostu", score: 1)
        ])
    ]
    
    // 3. Love Test Questions (6 questions)
    static let loveQuestions: [QuizQuestion] = [
        QuizQuestion(id: "l1", question: "Sevgiyi nasıl gösterirsin?", options: [
            QuizOption(id: "a1", text: "Hediyelerle", score: 4),
            QuizOption(id: "a2", text: "Sözlerle", score: 3),
            QuizOption(id: "a3", text: "Dokunarak", score: 2),
            QuizOption(id: "a4", text: "Zaman harcayarak", score: 1)
        ]),
        QuizQuestion(id: "l2", question: "İdeal ilk buluşma nerede?", options: [
            QuizOption(id: "a1", text: "Romantik bir restoran", score: 4),
            QuizOption(id: "a2", text: "Sinema", score: 3),
            QuizOption(id: "a3", text: "Açık hava aktivitesi", score: 2),
            QuizOption(id: "a4", text: "Kahve dükkanı", score: 1)
        ]),
        QuizQuestion(id: "l3", question: "Partnerde en önemli özellik?", options: [
            QuizOption(id: "a1", text: "Mizah anlayışı", score: 4),
            QuizOption(id: "a2", text: "Zeka", score: 3),
            QuizOption(id: "a3", text: "Sadakat", score: 2),
            QuizOption(id: "a4", text: "Tutkulu olmak", score: 1)
        ]),
        QuizQuestion(id: "l4", question: "Aşkta korkun ne?", options: [
            QuizOption(id: "a1", text: "Terk edilmek", score: 4),
            QuizOption(id: "a2", text: "Aldatılmak", score: 3),
            QuizOption(id: "a3", text: "Yanlış anlaşılmak", score: 2),
            QuizOption(id: "a4", text: "Kaybolmak", score: 1)
        ]),
        QuizQuestion(id: "l5", question: "İlişkide en sevdiğin şey?", options: [
            QuizOption(id: "a1", text: "Birlikte zaman", score: 4),
            QuizOption(id: "a2", text: "Derin sohbetler", score: 3),
            QuizOption(id: "a3", text: "Fiziksel yakınlık", score: 2),
            QuizOption(id: "a4", text: "Birlikte büyümek", score: 1)
        ]),
        QuizQuestion(id: "l6", question: "Aşk senin için?", options: [
            QuizOption(id: "a1", text: "Hayatın anlamı", score: 4),
            QuizOption(id: "a2", text: "Güzel bir his", score: 3),
            QuizOption(id: "a3", text: "Önemli ama tek şey değil", score: 2),
            QuizOption(id: "a4", text: "Karmaşık bir duygu", score: 1)
        ])
    ]
    
    // 4. Compatibility Test Questions
    static let compatibilityQuestions: [QuizQuestion] = [
        QuizQuestion(id: "c1", question: "Tartışmalarda ne yaparsınız?", options: [
            QuizOption(id: "a1", text: "Hemen konuşuruz", score: 4),
            QuizOption(id: "a2", text: "Soğumayı bekleriz", score: 3),
            QuizOption(id: "a3", text: "Yazılı iletişim kurarız", score: 2),
            QuizOption(id: "a4", text: "Üstünü örteriz", score: 1)
        ]),
        QuizQuestion(id: "c2", question: "Birlikte zaman geçirmek?", options: [
            QuizOption(id: "a1", text: "Her an birlikte", score: 4),
            QuizOption(id: "a2", text: "Dengeli", score: 3),
            QuizOption(id: "a3", text: "Özgürlükçü", score: 2),
            QuizOption(id: "a4", text: "Mesafeli", score: 1)
        ])
    ]
    
    // 5. Love What You Want Test Questions (7 questions)
    static let loveWantQuestions: [QuizQuestion] = [
        QuizQuestion(id: "lw1", question: "Aşk senin gözünde...", options: [
            QuizOption(id: "a1", text: "Ruhların birleşimi", score: 4),
            QuizOption(id: "a2", text: "Tutkulu bir deneyim", score: 3),
            QuizOption(id: "a3", text: "Güvenli bir liman", score: 2),
            QuizOption(id: "a4", text: "Keyifli bir paylaşım", score: 1)
        ]),
        QuizQuestion(id: "lw2", question: "Bir partnerde seni etkileyen ilk şey?", options: [
            QuizOption(id: "a1", text: "Enerjisi", score: 4),
            QuizOption(id: "a2", text: "Karizması", score: 3),
            QuizOption(id: "a3", text: "Güven vermesi", score: 2),
            QuizOption(id: "a4", text: "Özgür tavrı", score: 1)
        ]),
        QuizQuestion(id: "lw3", question: "İlişkide asla vazgeçemeyeceğin şey?", options: [
            QuizOption(id: "a1", text: "Duygusal bağlılık", score: 4),
            QuizOption(id: "a2", text: "Fiziksel çekim", score: 3),
            QuizOption(id: "a3", text: "Sadakat", score: 2),
            QuizOption(id: "a4", text: "Alan tanımak", score: 1)
        ]),
        QuizQuestion(id: "lw4", question: "Bir tartışmada ne yaparsın?", options: [
            QuizOption(id: "a1", text: "Hemen konuşurum", score: 4),
            QuizOption(id: "a2", text: "Biraz bekler, sonra patlarım", score: 3),
            QuizOption(id: "a3", text: "Sakin kalmaya çalışırım", score: 2),
            QuizOption(id: "a4", text: "Uzaklaşırım", score: 1)
        ]),
        QuizQuestion(id: "lw5", question: "İlişkide uzun vadede ne beklersin?", options: [
            QuizOption(id: "a1", text: "Ruh eşi bağlantısı", score: 4),
            QuizOption(id: "a2", text: "Aşkın hiç bitmemesi", score: 3),
            QuizOption(id: "a3", text: "Sadakat ve istikrar", score: 2),
            QuizOption(id: "a4", text: "Birlikte büyümek ama özgür kalmak", score: 1)
        ]),
        QuizQuestion(id: "lw6", question: "Kalbini verdiğinde…", options: [
            QuizOption(id: "a1", text: "Tamamen adanırım", score: 4),
            QuizOption(id: "a2", text: "Her şeyimi paylaşırım", score: 3),
            QuizOption(id: "a3", text: "Dengemi korumaya çalışırım", score: 2),
            QuizOption(id: "a4", text: "Hislerimi kontrol ederim", score: 1)
        ]),
        QuizQuestion(id: "lw7", question: "Sevgi senin için...", options: [
            QuizOption(id: "a1", text: "Sessiz bir enerji bağı", score: 4),
            QuizOption(id: "a2", text: "Yakan bir ateş", score: 3),
            QuizOption(id: "a3", text: "Güçlü bir bağ", score: 2),
            QuizOption(id: "a4", text: "Akışta yaşanan bir his", score: 1)
        ])
    ]
    
    // 6. Red Flags Test Questions (8 questions)
    static let redFlagsQuestions: [QuizQuestion] = [
        QuizQuestion(id: "rf1", question: "Partnerin sürekli eski sevgilisinden bahsederse?", options: [
            QuizOption(id: "a1", text: "Kırmızı bayrak!", score: 4),
            QuizOption(id: "a2", text: "Endişe verici", score: 3),
            QuizOption(id: "a3", text: "Normal olabilir", score: 2),
            QuizOption(id: "a4", text: "Önemli değil", score: 1)
        ]),
        QuizQuestion(id: "rf2", question: "Seni arkadaşlarından uzaklaştırırsa?", options: [
            QuizOption(id: "a1", text: "Kesin kırmızı bayrak", score: 4),
            QuizOption(id: "a2", text: "Dikkatli olmalıyım", score: 3),
            QuizOption(id: "a3", text: "Belki kıskançlıktır", score: 2),
            QuizOption(id: "a4", text: "Sevdiğinden yapıyordur", score: 1)
        ]),
        QuizQuestion(id: "rf3", question: "Telefonunu sürekli saklarsa?", options: [
            QuizOption(id: "a1", text: "Şüpheli davranış", score: 4),
            QuizOption(id: "a2", text: "Biraz endişelenirim", score: 3),
            QuizOption(id: "a3", text: "Özel alanına saygı duyarım", score: 2),
            QuizOption(id: "a4", text: "Herkes bunu yapar", score: 1)
        ]),
        QuizQuestion(id: "rf4", question: "Seni sürekli eleştirirse?", options: [
            QuizOption(id: "a1", text: "Kabul edilemez", score: 4),
            QuizOption(id: "a2", text: "Rahatsız edici", score: 3),
            QuizOption(id: "a3", text: "Belki iyiliğim için", score: 2),
            QuizOption(id: "a4", text: "Dikkate almam", score: 1)
        ]),
        QuizQuestion(id: "rf5", question: "Hislerini küçümserse?", options: [
            QuizOption(id: "a1", text: "Büyük kırmızı bayrak", score: 4),
            QuizOption(id: "a2", text: "Saygısızlık", score: 3),
            QuizOption(id: "a3", text: "Belki anlamıyordur", score: 2),
            QuizOption(id: "a4", text: "Alışırım", score: 1)
        ]),
        QuizQuestion(id: "rf6", question: "Planları hep son dakika iptal ederse?", options: [
            QuizOption(id: "a1", text: "Saygısızlık", score: 4),
            QuizOption(id: "a2", text: "Sinir bozucu", score: 3),
            QuizOption(id: "a3", text: "Hayat bazen böyle", score: 2),
            QuizOption(id: "a4", text: "Anlayışla karşılarım", score: 1)
        ]),
        QuizQuestion(id: "rf7", question: "Başkalarıyla flört ederse?", options: [
            QuizOption(id: "a1", text: "İlişki biter", score: 4),
            QuizOption(id: "a2", text: "Ciddi bir sorun", score: 3),
            QuizOption(id: "a3", text: "Sadece arkadaşça olabilir", score: 2),
            QuizOption(id: "a4", text: "Karakteri böyle", score: 1)
        ]),
        QuizQuestion(id: "rf8", question: "Sana yalan söylediğini yakaladın?", options: [
            QuizOption(id: "a1", text: "Güven kalktı", score: 4),
            QuizOption(id: "a2", text: "Çok sinir bozucu", score: 3),
            QuizOption(id: "a3", text: "Herkes bazen yalan söyler", score: 2),
            QuizOption(id: "a4", text: "Bir kere olabilir", score: 1)
        ])
    ]
    
    // 7. Funny Test Questions (6 questions)
    static let funnyQuestions: [QuizQuestion] = [
        QuizQuestion(id: "fn1", question: "Eğlence için ne yaparsın?", options: [
            QuizOption(id: "a1", text: "Parti veririm", score: 4),
            QuizOption(id: "a2", text: "Oyun oynarım", score: 3),
            QuizOption(id: "a3", text: "Film izlerim", score: 2),
            QuizOption(id: "a4", text: "Doğada yürürüm", score: 1)
        ]),
        QuizQuestion(id: "fn2", question: "Arkadaş ortamında?", options: [
            QuizOption(id: "a1", text: "Herkes güldürürüm", score: 4),
            QuizOption(id: "a2", text: "Eğlenceye katılırım", score: 3),
            QuizOption(id: "a3", text: "Gözlemci olurum", score: 2),
            QuizOption(id: "a4", text: "Sakin köşemde otururum", score: 1)
        ]),
        QuizQuestion(id: "fn3", question: "Sıkıldığında ne yaparsın?", options: [
            QuizOption(id: "a1", text: "Hemen bir etkinlik yaratırım", score: 4),
            QuizOption(id: "a2", text: "Arkadaşları ararım", score: 3),
            QuizOption(id: "a3", text: "Netflix açarım", score: 2),
            QuizOption(id: "a4", text: "Uyurum", score: 1)
        ]),
        QuizQuestion(id: "fn4", question: "Spontane plan?", options: [
            QuizOption(id: "a1", text: "Her zaman hazırım!", score: 4),
            QuizOption(id: "a2", text: "Genelde kabul ederim", score: 3),
            QuizOption(id: "a3", text: "Planlı olmayı tercih ederim", score: 2),
            QuizOption(id: "a4", text: "Evde kalmayı tercih ederim", score: 1)
        ]),
        QuizQuestion(id: "fn5", question: "Dans etmeyi sever misin?", options: [
            QuizOption(id: "a1", text: "Dans pistinin yıldızıyım", score: 4),
            QuizOption(id: "a2", text: "Fena değilim", score: 3),
            QuizOption(id: "a3", text: "Sadece köşede sallanırım", score: 2),
            QuizOption(id: "a4", text: "Asla", score: 1)
        ]),
        QuizQuestion(id: "fn6", question: "Komedi filmi mi drama mı?", options: [
            QuizOption(id: "a1", text: "Kesinlikle komedi", score: 4),
            QuizOption(id: "a2", text: "İkisi de olur", score: 3),
            QuizOption(id: "a3", text: "Drama tercih ederim", score: 2),
            QuizOption(id: "a4", text: "Belgesel severim", score: 1)
        ])
    ]
    
    // 8. Chaos Test Questions (7 questions)
    static let chaosQuestions: [QuizQuestion] = [
        QuizQuestion(id: "ch1", question: "Spontane kararlar?", options: [
            QuizOption(id: "a1", text: "Her zaman!", score: 4),
            QuizOption(id: "a2", text: "Bazen", score: 3),
            QuizOption(id: "a3", text: "Nadiren", score: 2),
            QuizOption(id: "a4", text: "Asla", score: 1)
        ]),
        QuizQuestion(id: "ch2", question: "Planlarını son dakika değiştirir misin?", options: [
            QuizOption(id: "a1", text: "Sürekli", score: 4),
            QuizOption(id: "a2", text: "Sık sık", score: 3),
            QuizOption(id: "a3", text: "Nadiren", score: 2),
            QuizOption(id: "a4", text: "Plan kutsal", score: 1)
        ]),
        QuizQuestion(id: "ch3", question: "Odan ne durumda?", options: [
            QuizOption(id: "a1", text: "Yaratıcı kaos", score: 4),
            QuizOption(id: "a2", text: "Biraz dağınık", score: 3),
            QuizOption(id: "a3", text: "Düzenli", score: 2),
            QuizOption(id: "a4", text: "Minimalist ve temiz", score: 1)
        ]),
        QuizQuestion(id: "ch4", question: "Kurallara uyar mısın?", options: [
            QuizOption(id: "a1", text: "Kurallar yıkılmak için var", score: 4),
            QuizOption(id: "a2", text: "Esnetirim", score: 3),
            QuizOption(id: "a3", text: "Genelde uyarım", score: 2),
            QuizOption(id: "a4", text: "Her zaman uyarım", score: 1)
        ]),
        QuizQuestion(id: "ch5", question: "Riskli kararlar?", options: [
            QuizOption(id: "a1", text: "Adrenalin bağımlısıyım", score: 4),
            QuizOption(id: "a2", text: "Hesaplı riskler alırım", score: 3),
            QuizOption(id: "a3", text: "Güvenli oynamayı severim", score: 2),
            QuizOption(id: "a4", text: "Riskten kaçınırım", score: 1)
        ]),
        QuizQuestion(id: "ch6", question: "Sabah rutinin?", options: [
            QuizOption(id: "a1", text: "Her gün farklı", score: 4),
            QuizOption(id: "a2", text: "Esnek bir düzen", score: 3),
            QuizOption(id: "a3", text: "Belirli bir rutin", score: 2),
            QuizOption(id: "a4", text: "Dakika dakika planlanmış", score: 1)
        ]),
        QuizQuestion(id: "ch7", question: "Yolculuk yaparken?", options: [
            QuizOption(id: "a1", text: "Sadece bilet, gerisine bakarız", score: 4),
            QuizOption(id: "a2", text: "Kaba bir plan", score: 3),
            QuizOption(id: "a3", text: "Detaylı plan", score: 2),
            QuizOption(id: "a4", text: "Her dakika planlanmış", score: 1)
        ])
    ]
    
    // 9. Super Power Test Questions (8 questions)
    static let superPowerQuestions: [QuizQuestion] = [
        QuizQuestion(id: "sp1", question: "Bir süper gücün olsaydı hangisi olurdu?", options: [
            QuizOption(id: "a1", text: "Zihin okumak", score: 4),
            QuizOption(id: "a2", text: "Görünmezlik", score: 3),
            QuizOption(id: "a3", text: "Uçmak", score: 2),
            QuizOption(id: "a4", text: "Şifa vermek", score: 1)
        ]),
        QuizQuestion(id: "sp2", question: "Stresli bir durumda ne yaparsın?", options: [
            QuizOption(id: "a1", text: "Soğukkanlı kalırım", score: 4),
            QuizOption(id: "a2", text: "Durumu analiz ederim", score: 3),
            QuizOption(id: "a3", text: "Başkalarına danışırım", score: 2),
            QuizOption(id: "a4", text: "İçgüdülerime güvenirim", score: 1)
        ]),
        QuizQuestion(id: "sp3", question: "Başkalarını nasıl etkilersin?", options: [
            QuizOption(id: "a1", text: "Karizmayla", score: 4),
            QuizOption(id: "a2", text: "Mantıkla", score: 3),
            QuizOption(id: "a3", text: "Empatiyle", score: 2),
            QuizOption(id: "a4", text: "Sessizce ama güçlü", score: 1)
        ]),
        QuizQuestion(id: "sp4", question: "Takım çalışmasında rolün?", options: [
            QuizOption(id: "a1", text: "Lider", score: 4),
            QuizOption(id: "a2", text: "Stratejist", score: 3),
            QuizOption(id: "a3", text: "Koordinatör", score: 2),
            QuizOption(id: "a4", text: "Destekçi", score: 1)
        ]),
        QuizQuestion(id: "sp5", question: "En güçlü yönün?", options: [
            QuizOption(id: "a1", text: "İrade gücü", score: 4),
            QuizOption(id: "a2", text: "Yaratıcılık", score: 3),
            QuizOption(id: "a3", text: "Sabır", score: 2),
            QuizOption(id: "a4", text: "Sezgiler", score: 1)
        ]),
        QuizQuestion(id: "sp6", question: "Dünyayı değiştirmek için?", options: [
            QuizOption(id: "a1", text: "Liderlik ederim", score: 4),
            QuizOption(id: "a2", text: "Bir şeyler icat ederim", score: 3),
            QuizOption(id: "a3", text: "İnsanları iyileştiririm", score: 2),
            QuizOption(id: "a4", text: "Bilgelik paylaşırım", score: 1)
        ]),
        QuizQuestion(id: "sp7", question: "Zor anlarda seni ne ayakta tutar?", options: [
            QuizOption(id: "a1", text: "Azim ve kararlılık", score: 4),
            QuizOption(id: "a2", text: "Umut", score: 3),
            QuizOption(id: "a3", text: "Sevdiklerim", score: 2),
            QuizOption(id: "a4", text: "İnançlarım", score: 1)
        ]),
        QuizQuestion(id: "sp8", question: "Hangi element seni tanımlar?", options: [
            QuizOption(id: "a1", text: "Ateş - Tutku", score: 4),
            QuizOption(id: "a2", text: "Hava - Özgürlük", score: 3),
            QuizOption(id: "a3", text: "Su - Akış", score: 2),
            QuizOption(id: "a4", text: "Toprak - Dayanıklılık", score: 1)
        ])
    ]
    
    // 10. Planet Energy Test Questions (6 questions)
    static let planetEnergyQuestions: [QuizQuestion] = [
        QuizQuestion(id: "pe1", question: "Hangi zaman dilimini tercih edersin?", options: [
            QuizOption(id: "a1", text: "Gündüz - Güneş", score: 4),
            QuizOption(id: "a2", text: "Gece - Ay", score: 3),
            QuizOption(id: "a3", text: "Gün batımı - Venüs", score: 2),
            QuizOption(id: "a4", text: "Şafak - Merkür", score: 1)
        ]),
        QuizQuestion(id: "pe2", question: "Enerji düzeyin?", options: [
            QuizOption(id: "a1", text: "Yüksek ve patlayıcı", score: 4),
            QuizOption(id: "a2", text: "Dengeli ve istikrarlı", score: 3),
            QuizOption(id: "a3", text: "Dalgalı", score: 2),
            QuizOption(id: "a4", text: "Sakin ve derin", score: 1)
        ]),
        QuizQuestion(id: "pe3", question: "Karar verirken?", options: [
            QuizOption(id: "a1", text: "Cesur ve hızlı", score: 4),
            QuizOption(id: "a2", text: "Mantıklı ve planlı", score: 3),
            QuizOption(id: "a3", text: "Duygusal", score: 2),
            QuizOption(id: "a4", text: "Sezgisel", score: 1)
        ]),
        QuizQuestion(id: "pe4", question: "İlişkilerde?", options: [
            QuizOption(id: "a1", text: "Tutkulu ve yoğun", score: 4),
            QuizOption(id: "a2", text: "Sadık ve güvenilir", score: 3),
            QuizOption(id: "a3", text: "Romantik ve duygusal", score: 2),
            QuizOption(id: "a4", text: "Özgür ve bağımsız", score: 1)
        ]),
        QuizQuestion(id: "pe5", question: "Yaşam amacın?", options: [
            QuizOption(id: "a1", text: "Başarı ve güç", score: 4),
            QuizOption(id: "a2", text: "Bilgi ve öğrenme", score: 3),
            QuizOption(id: "a3", text: "Aşk ve bağlantı", score: 2),
            QuizOption(id: "a4", text: "Huzur ve anlam", score: 1)
        ]),
        QuizQuestion(id: "pe6", question: "Gökyüzünde neye bakarsın?", options: [
            QuizOption(id: "a1", text: "Güneş - Parlaklık", score: 4),
            QuizOption(id: "a2", text: "Mars - Cesarret", score: 3),
            QuizOption(id: "a3", text: "Venüs - Güzellik", score: 2),
            QuizOption(id: "a4", text: "Satürn - Zaman", score: 1)
        ])
    ]
    
    // 11. Soulmate Zodiac Test Questions (5 questions)
    static let soulmateZodiacQuestions: [QuizQuestion] = [
        QuizQuestion(id: "sz1", question: "Ruh eşinde en önemli özellik?", options: [
            QuizOption(id: "a1", text: "Anlayış", score: 4),
            QuizOption(id: "a2", text: "Tutku", score: 3),
            QuizOption(id: "a3", text: "Sadakat", score: 2),
            QuizOption(id: "a4", text: "Macera ruhu", score: 1)
        ]),
        QuizQuestion(id: "sz2", question: "İlişkide iletişim?", options: [
            QuizOption(id: "a1", text: "Derin ve anlamlı sohbetler", score: 4),
            QuizOption(id: "a2", text: "Eğlenceli ve neşeli", score: 3),
            QuizOption(id: "a3", text: "Sakin ve huzurlu", score: 2),
            QuizOption(id: "a4", text: "Minimal ama anlamlı", score: 1)
        ]),
        QuizQuestion(id: "sz3", question: "Çatışmada?", options: [
            QuizOption(id: "a1", text: "Hemen çözeriz", score: 4),
            QuizOption(id: "a2", text: "Biraz zaman veririz", score: 3),
            QuizOption(id: "a3", text: "Uzlaşma ararız", score: 2),
            QuizOption(id: "a4", text: "Her şeyin geçmesini bekleriz", score: 1)
        ]),
        QuizQuestion(id: "sz4", question: "Birliktelikte?", options: [
            QuizOption(id: "a1", text: "Her an beraber", score: 4),
            QuizOption(id: "a2", text: "Kaliteli zaman", score: 3),
            QuizOption(id: "a3", text: "Bağımsızlık önemli", score: 2),
            QuizOption(id: "a4", text: "Özgürlük her şeyden önce", score: 1)
        ]),
        QuizQuestion(id: "sz5", question: "Gelecek hayallerin?", options: [
            QuizOption(id: "a1", text: "Birlikte büyük hayaller", score: 4),
            QuizOption(id: "a2", text: "Mutlu bir yuva", score: 3),
            QuizOption(id: "a3", text: "Maceralı bir yaşam", score: 2),
            QuizOption(id: "a4", text: "Huzurlu ve sakin", score: 1)
        ])
    ]
    
    // 12. Mental Health Color Test Questions (6 questions)
    static let mentalHealthColorQuestions: [QuizQuestion] = [
        QuizQuestion(id: "mh1", question: "Sabah uyandığında nasıl hissedersin?", options: [
            QuizOption(id: "a1", text: "Enerjik ve heyecanlı", score: 4),
            QuizOption(id: "a2", text: "Huzurlu ve sakin", score: 3),
            QuizOption(id: "a3", text: "Nötr", score: 2),
            QuizOption(id: "a4", text: "Yorgun ve motivasyonsuz", score: 1)
        ]),
        QuizQuestion(id: "mh2", question: "Stresle nasıl başa çıkarsın?", options: [
            QuizOption(id: "a1", text: "Spor veya aktivite", score: 4),
            QuizOption(id: "a2", text: "Meditasyon veya nefes", score: 3),
            QuizOption(id: "a3", text: "Sosyal destek", score: 2),
            QuizOption(id: "a4", text: "İçime kapanırım", score: 1)
        ]),
        QuizQuestion(id: "mh3", question: "En çok hangi renk seni çeker?", options: [
            QuizOption(id: "a1", text: "Mavi - Huzur", score: 4),
            QuizOption(id: "a2", text: "Yeşil - Denge", score: 3),
            QuizOption(id: "a3", text: "Mor - Dönüşüm", score: 2),
            QuizOption(id: "a4", text: "Gri - Belirsizlik", score: 1)
        ]),
        QuizQuestion(id: "mh4", question: "Düşüncelerini nasıl tanımlarsın?", options: [
            QuizOption(id: "a1", text: "Pozitif ve umutlu", score: 4),
            QuizOption(id: "a2", text: "Gerçekçi", score: 3),
            QuizOption(id: "a3", text: "Dalgalı", score: 2),
            QuizOption(id: "a4", text: "Kaygılı veya endişeli", score: 1)
        ]),
        QuizQuestion(id: "mh5", question: "Gece uyumadan önce?", options: [
            QuizOption(id: "a1", text: "Minnetle uyurum", score: 4),
            QuizOption(id: "a2", text: "Kitap/müzik ile rahatlarım", score: 3),
            QuizOption(id: "a3", text: "Telefona bakarım", score: 2),
            QuizOption(id: "a4", text: "Düşüncelerle boğuşurum", score: 1)
        ]),
        QuizQuestion(id: "mh6", question: "Kendine nasıl davranırsın?", options: [
            QuizOption(id: "a1", text: "Şefkatli ve anlayışlı", score: 4),
            QuizOption(id: "a2", text: "Makul", score: 3),
            QuizOption(id: "a3", text: "Bazen eleştirel", score: 2),
            QuizOption(id: "a4", text: "Çok sert", score: 1)
        ])
    ]
    
    // 13. Spirit Animal Test Questions (6 questions)
    static let spiritAnimalQuestions: [QuizQuestion] = [
        QuizQuestion(id: "sa1", question: "Doğada nereyi tercih edersin?", options: [
            QuizOption(id: "a1", text: "Orman - Gizemli", score: 4),
            QuizOption(id: "a2", text: "Deniz - Özgür", score: 3),
            QuizOption(id: "a3", text: "Dağ - Güçlü", score: 2),
            QuizOption(id: "a4", text: "Çöl - Dayanıklı", score: 1)
        ]),
        QuizQuestion(id: "sa2", question: "Sosyal ortamlarda?", options: [
            QuizOption(id: "a1", text: "Liderlik yaparım", score: 4),
            QuizOption(id: "a2", text: "Akışa bırakırım", score: 3),
            QuizOption(id: "a3", text: "Gözlem yaparım", score: 2),
            QuizOption(id: "a4", text: "Yalnız kalmayı tercih ederim", score: 1)
        ]),
        QuizQuestion(id: "sa3", question: "Tehlike anında?", options: [
            QuizOption(id: "a1", text: "Savaşırım", score: 4),
            QuizOption(id: "a2", text: "Stratejik hareket ederim", score: 3),
            QuizOption(id: "a3", text: "Kaçarım ve beklerim", score: 2),
            QuizOption(id: "a4", text: "Gizlenirim", score: 1)
        ]),
        QuizQuestion(id: "sa4", question: "Yaşam felsefe?", options: [
            QuizOption(id: "a1", text: "Güç ve hakimiyet", score: 4),
            QuizOption(id: "a2", text: "Özgürlük ve macera", score: 3),
            QuizOption(id: "a3", text: "Bilgelik ve sabır", score: 2),
            QuizOption(id: "a4", text: "Uyum ve denege", score: 1)
        ]),
        QuizQuestion(id: "sa5", question: "En güçlü duyun?", options: [
            QuizOption(id: "a1", text: "Görme - Kartal gibi", score: 4),
            QuizOption(id: "a2", text: "Koklama - Kurt gibi", score: 3),
            QuizOption(id: "a3", text: "Sezgi - Kedi gibi", score: 2),
            QuizOption(id: "a4", text: "Duyma - Yarasa gibi", score: 1)
        ]),
        QuizQuestion(id: "sa6", question: "Ruhunun ihtiyacı?", options: [
            QuizOption(id: "a1", text: "Macera ve keşif", score: 4),
            QuizOption(id: "a2", text: "Bağlantı ve topluluk", score: 3),
            QuizOption(id: "a3", text: "Huzur ve sessizlik", score: 2),
            QuizOption(id: "a4", text: "Koruma ve güvenlik", score: 1)
        ])
    ]
    
    // 14. Energy Stage Test Questions (5 questions)
    static let energyStageQuestions: [QuizQuestion] = [
        QuizQuestion(id: "es1", question: "Şu an genel enerji düzeyin?", options: [
            QuizOption(id: "a1", text: "Yüksek ve patlayıcı", score: 4),
            QuizOption(id: "a2", text: "Stabil ve dengeli", score: 3),
            QuizOption(id: "a3", text: "Dalgalı", score: 2),
            QuizOption(id: "a4", text: "Düşük ve yorgun", score: 1)
        ]),
        QuizQuestion(id: "es2", question: "Günün hangi saatinde en iyisin?", options: [
            QuizOption(id: "a1", text: "Sabah erken", score: 4),
            QuizOption(id: "a2", text: "Öğlen", score: 3),
            QuizOption(id: "a3", text: "Akşam", score: 2),
            QuizOption(id: "a4", text: "Gece geç", score: 1)
        ]),
        QuizQuestion(id: "es3", question: "Son 1 haftada uyku kalitten?", options: [
            QuizOption(id: "a1", text: "Mükemmel", score: 4),
            QuizOption(id: "a2", text: "İyi", score: 3),
            QuizOption(id: "a3", text: "Bozuk", score: 2),
            QuizOption(id: "a4", text: "Çok kötü", score: 1)
        ]),
        QuizQuestion(id: "es4", question: "Motivasyon seviyeni?", options: [
            QuizOption(id: "a1", text: "Zirvede", score: 4),
            QuizOption(id: "a2", text: "Yeterli", score: 3),
            QuizOption(id: "a3", text: "Düşük", score: 2),
            QuizOption(id: "a4", text: "Yok denecek kadar az", score: 1)
        ]),
        QuizQuestion(id: "es5", question: "Odaklanma yeteneğin?", options: [
            QuizOption(id: "a1", text: "Lazer gibi keskin", score: 4),
            QuizOption(id: "a2", text: "İyi", score: 3),
            QuizOption(id: "a3", text: "Dağınık", score: 2),
            QuizOption(id: "a4", text: "Zor odaklanıyorum", score: 1)
        ])
    ]
}

// MARK: - Quiz Test Result
struct QuizTestResult: Identifiable, Codable {
    let id: String
    let userId: String
    let testId: String
    let testTitle: String
    let resultText: String
    let answers: [String: String]
    let createdAt: Date
    
    init(id: String, userId: String, testId: String, testTitle: String, resultText: String, answers: [String: String], createdAt: Date) {
        self.id = id
        self.userId = userId
        self.testId = testId
        self.testTitle = testTitle
        self.resultText = resultText
        self.answers = answers
        self.createdAt = createdAt
    }
    
    static let sampleResults: [QuizTestResult] = [
        QuizTestResult(
            id: "r1",
            userId: "user1",
            testId: "personality",
            testTitle: "Kişilik Testi",
            resultText: "Analiz sonuçlarına göre sen içsel bir güce sahip, derin düşünen bir kişiliğe sahipsin...",
            answers: ["p1": "a2", "p2": "a3"],
            createdAt: Date().addingTimeInterval(-86400)
        )
    ]
}
