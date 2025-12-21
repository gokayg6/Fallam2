import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime? birthDate;
  final String? gender;
  final String? relationshipStatus;
  final String? job;
  final int karma;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int dailyFortunesUsed;
  final List<String> favoriteFortuneTypes;
  final String? profileImageUrl;
  String? get photoUrl => profileImageUrl;
  final Map<String, dynamic> preferences;
  final int totalFortunes;
  final int totalTests;
  final String? zodiacSign;
  final String? birthPlace;
  final int freeAuraMatches;
  final DateTime? lastWeeklyAuraMatchReset;
  final bool socialVisible;
  final String ageGroup; // 'under18' or 'adult'
  final List<String> blockedUsers; // Engellenen kullanıcı ID'leri

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.birthDate,
    this.gender,
    this.relationshipStatus,
    this.job,
    this.karma = 0,
    this.isPremium = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.dailyFortunesUsed = 0,
    this.favoriteFortuneTypes = const [],
    this.profileImageUrl,
    this.preferences = const {},
    this.totalFortunes = 0,
    this.totalTests = 0,
    this.zodiacSign,
    this.birthPlace,
    this.freeAuraMatches = 0,
    this.lastWeeklyAuraMatchReset,
    this.socialVisible = true,
    required this.ageGroup,
    this.blockedUsers = const [],
  });

  // Age calculation
  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  bool get isUnder18 => age < 18;

  // Check if user can use daily fortune
  bool get canUseDailyFortune {
    return dailyFortunesUsed < (isPremium ? 10 : 3);
  }

  // Check if user has enough karma for action
  bool hasEnoughKarma(int requiredKarma) {
    return karma >= requiredKarma;
  }

  // Factory constructor from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? birth;
    if (data['birthDate'] != null && data['birthDate'] is Timestamp) {
      birth = (data['birthDate'] as Timestamp).toDate();
    }
    // Compute ageGroup safely on client; prefer stored value if backend already sets it
    String computedAgeGroup = 'adult';
    if (birth != null) {
      final now = DateTime.now();
      int a = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        a--;
      }
      computedAgeGroup = a < 18 ? 'under18' : 'adult';
    } else {
      // No birthdate -> treat as adult by default to avoid underage misclassification
      computedAgeGroup = 'adult';
    }
    
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      birthDate: birth,
      gender: data['gender'],
      relationshipStatus: data['relationshipStatus'],
      job: data['job'],
      karma: data['karma'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      lastLoginAt: data['lastLoginAt'] is Timestamp 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : DateTime.now(),
      dailyFortunesUsed: data['dailyFortunesUsed'] ?? 0,
      favoriteFortuneTypes: List<String>.from(data['favoriteFortuneTypes'] ?? []),
      profileImageUrl: data['profileImageUrl'],
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      totalFortunes: data['totalFortunes'] ?? 0,
      totalTests: data['totalTests'] ?? 0,
      zodiacSign: data['zodiacSign'],
      birthPlace: data['birthPlace'],
      freeAuraMatches: (data['freeAuraMatches'] as num?)?.toInt() ?? 0,
      lastWeeklyAuraMatchReset: data['lastWeeklyAuraMatchReset'] != null
          ? (data['lastWeeklyAuraMatchReset'] as Timestamp).toDate()
          : null,
      socialVisible: data['socialVisible'] as bool? ?? true,
      ageGroup: (data['ageGroup'] as String?) ?? computedAgeGroup,
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
    );
  }

  // Factory constructor from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime? birth;
    if (map['birthDate'] != null) {
      if (map['birthDate'] is Timestamp) {
        birth = (map['birthDate'] as Timestamp).toDate();
      } else {
        birth = DateTime.tryParse(map['birthDate'].toString());
      }
    }
    String computedAgeGroup = 'adult';
    if (birth != null) {
      final now = DateTime.now();
      int a = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        a--;
      }
      computedAgeGroup = a < 18 ? 'under18' : 'adult';
    }
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      birthDate: birth,
      gender: map['gender'],
      relationshipStatus: map['relationshipStatus'],
      job: map['job'],
      karma: map['karma'] ?? 0,
      isPremium: map['isPremium'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      lastLoginAt: map['lastLoginAt'] is Timestamp 
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : DateTime.parse(map['lastLoginAt']),
      dailyFortunesUsed: map['dailyFortunesUsed'] ?? 0,
      favoriteFortuneTypes: List<String>.from(map['favoriteFortuneTypes'] ?? []),
      profileImageUrl: map['profileImageUrl'],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      totalFortunes: map['totalFortunes'] ?? 0,
      totalTests: map['totalTests'] ?? 0,
      zodiacSign: map['zodiacSign'],
      birthPlace: map['birthPlace'],
      freeAuraMatches: (map['freeAuraMatches'] as num?)?.toInt() ?? 0,
      lastWeeklyAuraMatchReset: map['lastWeeklyAuraMatchReset'] != null
          ? (map['lastWeeklyAuraMatchReset'] is Timestamp
              ? (map['lastWeeklyAuraMatchReset'] as Timestamp).toDate()
              : DateTime.parse(map['lastWeeklyAuraMatchReset']))
          : null,
      socialVisible: map['socialVisible'] as bool? ?? true,
      ageGroup: (map['ageGroup'] as String?) ?? computedAgeGroup,
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'relationshipStatus': relationshipStatus,
      'job': job,
      'karma': karma,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'dailyFortunesUsed': dailyFortunesUsed,
      'favoriteFortuneTypes': favoriteFortuneTypes,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
      'totalFortunes': totalFortunes,
      'totalTests': totalTests,
      'zodiacSign': zodiacSign,
      'birthPlace': birthPlace,
      'freeAuraMatches': freeAuraMatches,
      'lastWeeklyAuraMatchReset': lastWeeklyAuraMatchReset?.toIso8601String(),
      'socialVisible': socialVisible,
      'age': age,
      'ageGroup': ageGroup,
      'blockedUsers': blockedUsers,
    };
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender,
      'relationshipStatus': relationshipStatus,
      'job': job,
      'karma': karma,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'dailyFortunesUsed': dailyFortunesUsed,
      'favoriteFortuneTypes': favoriteFortuneTypes,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
      'totalFortunes': totalFortunes,
      'totalTests': totalTests,
      'zodiacSign': zodiacSign,
      'birthPlace': birthPlace,
      'freeAuraMatches': freeAuraMatches,
      'lastWeeklyAuraMatchReset': lastWeeklyAuraMatchReset != null
          ? Timestamp.fromDate(lastWeeklyAuraMatchReset!)
          : null,
      'socialVisible': socialVisible,
      'age': age,
      'ageGroup': ageGroup,
      'blockedUsers': blockedUsers,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? birthDate,
    String? gender,
    String? relationshipStatus,
    String? job,
    int? karma,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? dailyFortunesUsed,
    List<String>? favoriteFortuneTypes,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    int? totalFortunes,
    int? totalTests,
    String? zodiacSign,
    String? birthPlace,
    int? freeAuraMatches,
    DateTime? lastWeeklyAuraMatchReset,
    bool? socialVisible,
    String? ageGroup,
    List<String>? blockedUsers,
  }) {
    // Eğer birthDate değiştiyse ageGroup'u otomatik hesapla
    final newBirthDate = birthDate ?? this.birthDate;
    String computedAgeGroup;
    if (ageGroup != null) {
      computedAgeGroup = ageGroup;
    } else if (newBirthDate != null) {
      final now = DateTime.now();
      int a = now.year - newBirthDate.year;
      if (now.month < newBirthDate.month ||
          (now.month == newBirthDate.month && now.day < newBirthDate.day)) {
        a--;
      }
      computedAgeGroup = a < 18 ? 'under18' : 'adult';
    } else {
      computedAgeGroup = this.ageGroup;
    }
    
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: newBirthDate,
      gender: gender ?? this.gender,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      job: job ?? this.job,
      karma: karma ?? this.karma,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      dailyFortunesUsed: dailyFortunesUsed ?? this.dailyFortunesUsed,
      favoriteFortuneTypes: favoriteFortuneTypes ?? this.favoriteFortuneTypes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      totalFortunes: totalFortunes ?? this.totalFortunes,
      totalTests: totalTests ?? this.totalTests,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      birthPlace: birthPlace ?? this.birthPlace,
      freeAuraMatches: freeAuraMatches ?? this.freeAuraMatches,
      lastWeeklyAuraMatchReset: lastWeeklyAuraMatchReset ?? this.lastWeeklyAuraMatchReset,
      socialVisible: socialVisible ?? this.socialVisible,
      ageGroup: computedAgeGroup,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, karma: $karma, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// User preferences model
class UserPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String language;
  final String theme; // 'light', 'dark', 'auto'
  final bool analyticsEnabled;
  final bool adsPersonalizationEnabled;

  UserPreferences({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'tr',
    this.theme = 'auto',
    this.analyticsEnabled = true,
    this.adsPersonalizationEnabled = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      language: map['language'] ?? 'tr',
      theme: map['theme'] ?? 'auto',
      analyticsEnabled: map['analyticsEnabled'] ?? true,
      adsPersonalizationEnabled: map['adsPersonalizationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'language': language,
      'theme': theme,
      'analyticsEnabled': analyticsEnabled,
      'adsPersonalizationEnabled': adsPersonalizationEnabled,
    };
  }

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? language,
    String? theme,
    bool? analyticsEnabled,
    bool? adsPersonalizationEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      adsPersonalizationEnabled: adsPersonalizationEnabled ?? this.adsPersonalizationEnabled,
    );
  }
}