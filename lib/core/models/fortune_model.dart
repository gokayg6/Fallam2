import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_strings.dart';

enum FortuneType {
  tarot,
  coffee,
  palm,
  katina,
  face,
  astrology,
  dream,
  daily,
}

enum FortuneStatus {
  pending,
  processing,
  completed,
  failed,
}

class FortuneModel {
  final String id;
  final String userId;
  final FortuneType type;
  final FortuneStatus status;
  final String title;
  final String interpretation;
  final Map<String, dynamic> inputData;
  final List<String> selectedCards;
  final List<String> imageUrls;
  final String? question;
  final String? fortuneTellerId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isFavorite;
  final int rating;
  final String? notes;
  final bool isForSelf;
  final String? targetPersonName;
  final Map<String, dynamic> metadata;
  final int karmaUsed;
  final bool isPremium;

  FortuneModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.title,
    this.interpretation = '',
    this.inputData = const {},
    this.selectedCards = const [],
    this.imageUrls = const [],
    this.question,
    this.fortuneTellerId,
    required this.createdAt,
    this.completedAt,
    this.isFavorite = false,
    this.rating = 0,
    this.notes,
    this.isForSelf = true,
    this.targetPersonName,
    this.metadata = const {},
    this.karmaUsed = 0,
    this.isPremium = false,
  });

  // Get fortune type display name
  String get typeDisplayName {
    switch (type) {
      case FortuneType.tarot:
        return AppStrings.tarot;
      case FortuneType.coffee:
        return AppStrings.coffeeFortune;
      case FortuneType.palm:
        return AppStrings.palmFortune;
      case FortuneType.katina:
        return AppStrings.katinaFortune;
      case FortuneType.face:
        return AppStrings.faceFortune;
      case FortuneType.astrology:
        return AppStrings.astrology;
      case FortuneType.dream:
        return AppStrings.dreamInterpretation;
      case FortuneType.daily:
        return AppStrings.dailyFortune;
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case FortuneStatus.pending:
        return 'Bekliyor';
      case FortuneStatus.processing:
        return 'İşleniyor';
      case FortuneStatus.completed:
        return 'Tamamlandı';
      case FortuneStatus.failed:
        return 'Başarısız';
    }
  }

  // Check if fortune is completed
  bool get isCompleted => status == FortuneStatus.completed;

  // Check if fortune is in progress
  bool get isInProgress => status == FortuneStatus.processing;

  // Get target display name
  String get targetDisplayName {
    return isForSelf ? AppStrings.forMyself : (targetPersonName ?? AppStrings.notSpecified);
  }

  // Get fortune duration
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  // Factory constructor from Firestore document
  factory FortuneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FortuneModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: FortuneType.values.firstWhere(
        (e) => e.toString() == 'FortuneType.${data['type']}',
        orElse: () => FortuneType.tarot,
      ),
      status: FortuneStatus.values.firstWhere(
        (e) => e.toString() == 'FortuneStatus.${data['status']}',
        orElse: () => FortuneStatus.pending,
      ),
      title: data['title'] ?? '',
      interpretation: data['interpretation'] ?? '',
      inputData: Map<String, dynamic>.from(data['inputData'] ?? {}),
      selectedCards: List<String>.from(data['selectedCards'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      question: data['question'],
      fortuneTellerId: data['fortuneTellerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      isFavorite: data['isFavorite'] ?? false,
      rating: data['rating'] ?? 0,
      notes: data['notes'],
      isForSelf: data['isForSelf'] ?? true,
      targetPersonName: data['targetPersonName'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      karmaUsed: data['karmaUsed'] ?? 0,
      isPremium: data['isPremium'] ?? false,
    );
  }

  // Factory constructor from Map
  factory FortuneModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return FortuneModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: FortuneType.values.firstWhere(
        (e) => e.toString() == 'FortuneType.${map['type']}',
        orElse: () => FortuneType.tarot,
      ),
      status: FortuneStatus.values.firstWhere(
        (e) => e.toString() == 'FortuneStatus.${map['status']}',
        orElse: () => FortuneStatus.pending,
      ),
      title: map['title'] ?? '',
      interpretation: map['interpretation'] ?? '',
      inputData: Map<String, dynamic>.from(map['inputData'] ?? {}),
      selectedCards: List<String>.from(map['selectedCards'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      question: map['question'],
      fortuneTellerId: map['fortuneTellerId'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] is Timestamp 
              ? (map['completedAt'] as Timestamp).toDate()
              : DateTime.parse(map['completedAt']))
          : null,
      isFavorite: map['isFavorite'] ?? false,
      rating: map['rating'] ?? 0,
      notes: map['notes'],
      isForSelf: map['isForSelf'] ?? true,
      targetPersonName: map['targetPersonName'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      karmaUsed: map['karmaUsed'] ?? 0,
      isPremium: map['isPremium'] ?? false,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'interpretation': interpretation,
      'inputData': inputData,
      'selectedCards': selectedCards,
      'imageUrls': imageUrls,
      'question': question,
      'fortuneTellerId': fortuneTellerId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'rating': rating,
      'notes': notes,
      'isForSelf': isForSelf,
      'targetPersonName': targetPersonName,
      'metadata': metadata,
      'karmaUsed': karmaUsed,
      'isPremium': isPremium,
    };
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'interpretation': interpretation,
      'inputData': inputData,
      'selectedCards': selectedCards,
      'imageUrls': imageUrls,
      'question': question,
      'fortuneTellerId': fortuneTellerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isFavorite': isFavorite,
      'rating': rating,
      'notes': notes,
      'isForSelf': isForSelf,
      'targetPersonName': targetPersonName,
      'metadata': metadata,
      'karmaUsed': karmaUsed,
      'isPremium': isPremium,
    };
  }

  // Copy with method for updates
  FortuneModel copyWith({
    String? id,
    String? userId,
    FortuneType? type,
    FortuneStatus? status,
    String? title,
    String? interpretation,
    Map<String, dynamic>? inputData,
    List<String>? selectedCards,
    List<String>? imageUrls,
    String? question,
    String? fortuneTellerId,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isFavorite,
    int? rating,
    String? notes,
    bool? isForSelf,
    String? targetPersonName,
    Map<String, dynamic>? metadata,
    int? karmaUsed,
    bool? isPremium,
  }) {
    return FortuneModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      interpretation: interpretation ?? this.interpretation,
      inputData: inputData ?? this.inputData,
      selectedCards: selectedCards ?? this.selectedCards,
      imageUrls: imageUrls ?? this.imageUrls,
      question: question ?? this.question,
      fortuneTellerId: fortuneTellerId ?? this.fortuneTellerId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      isForSelf: isForSelf ?? this.isForSelf,
      targetPersonName: targetPersonName ?? this.targetPersonName,
      metadata: metadata ?? this.metadata,
      karmaUsed: karmaUsed ?? this.karmaUsed,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  String toString() {
    return 'FortuneModel(id: $id, type: $type, status: $status, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FortuneModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Tarot card model
class TarotCard {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String imageUrl;
  final String category; // major, minor
  final String suit; // cups, wands, swords, pentacles (for minor arcana)
  final int? number;
  final List<String> keywords;
  final String uprightMeaning;
  final String reversedMeaning;
  final bool isReversed;

  TarotCard({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.suit = '',
    this.number,
    this.keywords = const [],
    required this.uprightMeaning,
    required this.reversedMeaning,
    this.isReversed = false,
  });

  factory TarotCard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TarotCard(
      id: doc.id,
      name: data['name'] ?? '',
      nameEn: data['nameEn'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      suit: data['suit'] ?? '',
      number: data['number'],
      keywords: List<String>.from(data['keywords'] ?? []),
      uprightMeaning: data['uprightMeaning'] ?? '',
      reversedMeaning: data['reversedMeaning'] ?? '',
      isReversed: data['isReversed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'suit': suit,
      'number': number,
      'keywords': keywords,
      'uprightMeaning': uprightMeaning,
      'reversedMeaning': reversedMeaning,
      'isReversed': isReversed,
    };
  }

  TarotCard copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? imageUrl,
    String? category,
    String? suit,
    int? number,
    List<String>? keywords,
    String? uprightMeaning,
    String? reversedMeaning,
    bool? isReversed,
  }) {
    return TarotCard(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      suit: suit ?? this.suit,
      number: number ?? this.number,
      keywords: keywords ?? this.keywords,
      uprightMeaning: uprightMeaning ?? this.uprightMeaning,
      reversedMeaning: reversedMeaning ?? this.reversedMeaning,
      isReversed: isReversed ?? this.isReversed,
    );
  }
}

// Fortune teller model
class FortuneTeller {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<FortuneType> specialties;
  final double rating;
  final int totalReadings;
  final bool isActive;
  final Map<String, dynamic> metadata;

  FortuneTeller({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.specialties = const [],
    this.rating = 0.0,
    this.totalReadings = 0,
    this.isActive = true,
    this.metadata = const {},
  });

  factory FortuneTeller.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FortuneTeller(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      specialties: (data['specialties'] as List<dynamic>? ?? [])
          .map((e) => FortuneType.values.firstWhere(
                (type) => type.toString() == 'FortuneType.$e',
                orElse: () => FortuneType.tarot,
              ))
          .toList(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReadings: data['totalReadings'] ?? 0,
      isActive: data['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'specialties': specialties.map((e) => e.toString().split('.').last).toList(),
      'rating': rating,
      'totalReadings': totalReadings,
      'isActive': isActive,
      'metadata': metadata,
    };
  }
}