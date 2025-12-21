import 'package:cloud_firestore/cloud_firestore.dart';
import 'fortune_type.dart';

class FortuneResult {
  final String id;
  final FortuneType type;
  final String title;
  final String interpretation;
  final String? question;
  final List<String> selectedCards;
  final List<String> imageUrls;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final double rating;
  final bool isFavorite;
  final String userId;

  FortuneResult({
    required this.id,
    required this.type,
    required this.title,
    required this.interpretation,
    this.question,
    this.selectedCards = const [],
    this.imageUrls = const [],
    this.metadata = const {},
    required this.createdAt,
    this.rating = 0.0,
    this.isFavorite = false,
    required this.userId,
  });

  factory FortuneResult.fromMap(Map<String, dynamic> map, String id) {
    return FortuneResult(
      id: id,
      type: FortuneType.fromKey(map['type'] ?? 'coffee'),
      title: map['title'] ?? '',
      interpretation: map['interpretation'] ?? '',
      question: map['question'],
      selectedCards: List<String>.from(map['selectedCards'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.key,
      'title': title,
      'interpretation': interpretation,
      'question': question,
      'selectedCards': selectedCards,
      'imageUrls': imageUrls,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'rating': rating,
      'isFavorite': isFavorite,
      'userId': userId,
    };
  }

  FortuneResult copyWith({
    String? id,
    FortuneType? type,
    String? title,
    String? interpretation,
    String? question,
    List<String>? selectedCards,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    double? rating,
    bool? isFavorite,
    String? userId,
  }) {
    return FortuneResult(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      interpretation: interpretation ?? this.interpretation,
      question: question ?? this.question,
      selectedCards: selectedCards ?? this.selectedCards,
      imageUrls: imageUrls ?? this.imageUrls,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId ?? this.userId,
    );
  }
}
