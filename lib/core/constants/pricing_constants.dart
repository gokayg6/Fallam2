class PricingConstants {
  // Yeni kayıt bonusu
  static const int newUserKarma = 10;

  // Premium fiyatları
  static const double weeklyPremiumPrice = 39.99;
  static const double monthlyPremiumPrice = 89.99;
  static const double yearlyPremiumPrice = 499.99;

  // Karma satış fiyatları
  static const Map<int, double> karmaPrices = {
    10: 19.99,
    25: 44.99,
    50: 79.99,
  };

  // Paket satışları
  static const List<Map<String, dynamic>> packages = [
    {
      'karma': 75,
      'adFreeDays': 7,
      'auraMatches': 1,
      'price': 119.99,
      'productId': 'package_75',
    },
    {
      'karma': 100,
      'adFreeDays': 7,
      'auraMatches': 2,
      'price': 149.99,
      'productId': 'package_100',
    },
    {
      'karma': 250,
      'adFreeDays': 7,
      'auraMatches': 3,
      'price': 299.99,
      'productId': 'package_250',
    },
  ];

  // Product ID mapping
  static const Map<int, String> karmaProductIds = {
    10: 'karma_10',
    25: 'karma_25',
    50: 'karma_50',
  };

  static const Map<String, String> premiumProductIds = {
    'weekly': 'premium_weekly',
    'monthly': 'premium_monthly',
    'yearly': 'premium_yearly',
  };

  // Fal ücretleri (karma cinsinden)
  static const Map<String, int> fortuneCosts = {
    'coffee': 10,    // Kahve Falı: 10 karma
    'tarot': 10,     // Tarot: 10 karma
    'palm': 15,      // El Falı: 15 karma
    'katina': 20,    // Katina: 20 karma
    'face': 20,     // Yüz Falı: 20 karma
    'dream': 10,     // Rüya yorumu: 10 karma
    'astrology': 10, // Astroloji: 10 karma
  };

  // Testler
  static const int testCost = 5;

  // Kader Çarkı ödül dağılımı
  static const List<Map<String, dynamic>> spinWheelRewards = [
    {'karma': 5, 'probability': 0.97995, 'label': '+5 Karma'},
    {'karma': 10, 'probability': 0.016, 'label': '+10 Karma'},
    {'karma': 15, 'probability': 0.0035, 'label': '+15 Karma'},
    {'karma': 25, 'probability': 0.0003, 'label': '+25 Karma'},
    {'karma': 50, 'probability': 0.00015, 'label': '+50 Karma'},
    {'karma': 75, 'probability': 0.00005, 'label': '+75 Karma'},
    {'karma': 100, 'probability': 0.00005, 'label': '+100 Karma'},
  ];

  // Kader Çarkı günlük limitleri
  static const int dailyFreeSpins = 1;
  static const int dailyAdSpins = 1;
  static const bool allow2xReward = true;

  // Aura eşleşmesi
  static const int auraMatchCost = 40;
  static const int auraMatchGenderSelectCost = 10;
  static const int premiumAuraMatchGenderSelectCost = 0; // Premium'da ücretsiz
  static const int premiumDailyAuraMatches = 1;
  static const int premiumFreeAuraMatchesOnUpgrade = 5; // İlk premium alındığında
  static const int premiumWeeklyFreeAuraMatches = 5; // Her hafta premium kullanıcılara

  // Reklam izleyerek kazan
  static const int videoKarmaReward = 3;
  static const int dailyVideoLimit = 5;
  static const int maxDailyKarmaFromAds = videoKarmaReward * dailyVideoLimit; // 15 karma

  // Premium özellikleri
  static const int premiumDailyKarma = 25;

  // Günlük Giriş Ödül Tablosu (Streak Sistemi)
  // Gün: (Karma, Ekstra Aksiyon)
  static const List<Map<String, dynamic>> dailyLoginRewards = [
    {'day': 1, 'karma': 3, 'extraAction': null},
    {'day': 2, 'karma': 4, 'extraAction': null},
    {'day': 3, 'karma': 5, 'extraAction': null},
    {'day': 4, 'karma': 6, 'extraAction': 'watch_ad_for_2_karma'},
    {'day': 5, 'karma': 7, 'extraAction': 'premium_cta'},
    {'day': 6, 'karma': 8, 'extraAction': null},
    {'day': 7, 'karma': 10, 'extraAction': 'watch_ad_for_5_karma_or_free_aura_match'},
  ];
  
  static const int maxStreakDays = 7; // 7 gün sonra tekrar başlar

  // Fal ücreti alma yardımcı fonksiyonu
  static int getFortuneCost(String fortuneType) {
    return fortuneCosts[fortuneType.toLowerCase()] ?? 10;
  }
  
  // Günlük giriş ödülü alma
  static Map<String, dynamic>? getDailyLoginReward(int streakDay) {
    final day = ((streakDay - 1) % maxStreakDays) + 1;
    return dailyLoginRewards.firstWhere(
      (reward) => reward['day'] == day,
      orElse: () => dailyLoginRewards[0],
    );
  }

  // Günlük Görevler (Quest Sistemi)
  // Note: Titles are now retrieved from AppStrings dynamically
  static List<Map<String, dynamic>> getDailyQuests() {
    // Import AppStrings dynamically to avoid circular dependency
    // Titles will be set in the UI layer
    return [
      {
        'id': 'coffee_fortune',
        'karma': 3,
        'icon': '☕',
      },
      {
        'id': 'love_test',
        'karma': 2,
        'icon': '💕',
      },
      {
        'id': 'aura_match',
        'karma': 2,
        'icon': '✨',
      },
    ];
  }
  
  // Legacy support - kept for backward compatibility
  static const List<Map<String, dynamic>> dailyQuests = [
    {
      'id': 'coffee_fortune',
      'karma': 3,
      'icon': '☕',
    },
    {
      'id': 'love_test',
      'karma': 2,
      'icon': '💕',
    },
    {
      'id': 'aura_match',
      'karma': 2,
      'icon': '✨',
    },
  ];

  static Map<String, dynamic>? getQuestById(String questId) {
    try {
      return dailyQuests.firstWhere((q) => q['id'] == questId);
    } catch (e) {
      return null;
    }
  }
}

