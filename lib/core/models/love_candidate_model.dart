import 'package:cloud_firestore/cloud_firestore.dart';

class LoveCandidateModel {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final DateTime birthDate;
  final String zodiacSign;
  final String? relationshipType; // "crush", "partner", "ex"
  final DateTime createdAt;
  final DateTime? lastCompatibilityCheck;
  final double? lastCompatibilityScore;

  LoveCandidateModel({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.birthDate,
    required this.zodiacSign,
    this.relationshipType,
    required this.createdAt,
    this.lastCompatibilityCheck,
    this.lastCompatibilityScore,
  });

  factory LoveCandidateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoveCandidateModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      zodiacSign: data['zodiacSign'] as String,
      relationshipType: data['relationshipType'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastCompatibilityCheck: data['lastCompatibilityCheck'] != null
          ? (data['lastCompatibilityCheck'] as Timestamp).toDate()
          : null,
      lastCompatibilityScore: (data['lastCompatibilityScore'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'birthDate': Timestamp.fromDate(birthDate),
      'zodiacSign': zodiacSign,
      'relationshipType': relationshipType,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastCompatibilityCheck': lastCompatibilityCheck != null
          ? Timestamp.fromDate(lastCompatibilityCheck!)
          : null,
      'lastCompatibilityScore': lastCompatibilityScore,
    };
  }

  LoveCandidateModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatarUrl,
    DateTime? birthDate,
    String? zodiacSign,
    String? relationshipType,
    DateTime? createdAt,
    DateTime? lastCompatibilityCheck,
    double? lastCompatibilityScore,
  }) {
    return LoveCandidateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      relationshipType: relationshipType ?? this.relationshipType,
      createdAt: createdAt ?? this.createdAt,
      lastCompatibilityCheck: lastCompatibilityCheck ?? this.lastCompatibilityCheck,
      lastCompatibilityScore: lastCompatibilityScore ?? this.lastCompatibilityScore,
    );
  }
}

