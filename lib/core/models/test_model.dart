import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_strings.dart';

enum TestType {
  love,
  personality,
  compatibility,
  career,
  friendship,
  family,
}

enum TestStatus {
  notStarted,
  inProgress,
  completed,
}

class TestModel {
  final String id;
  final String userId;
  final TestType type;
  final TestStatus status;
  final String title;
  final String description;
  final List<TestQuestion> questions;
  final Map<String, dynamic> answers;
  final String? result;
  final int score;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isFavorite;
  final int karmaReward;
  final Map<String, dynamic> metadata;

  TestModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    this.questions = const [],
    this.answers = const {},
    this.result,
    this.score = 0,
    required this.createdAt,
    this.completedAt,
    this.isFavorite = false,
    this.karmaReward = 0,
    this.metadata = const {},
  });

  // Get test display name
  String getDisplayName() {
    return typeDisplayName;
  }
  
  // Get test type display name
  String get typeDisplayName {
    switch (type) {
      case TestType.love:
        return AppStrings.loveTest;
      case TestType.personality:
        return AppStrings.personalityTest;
      case TestType.compatibility:
        return AppStrings.compatibilityTest;
      case TestType.career:
        return AppStrings.careerTest;
      case TestType.friendship:
        return AppStrings.friendshipTest;
      case TestType.family:
        return AppStrings.familyTest;
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case TestStatus.notStarted:
        return 'Başlanmadı';
      case TestStatus.inProgress:
        return 'Devam Ediyor';
      case TestStatus.completed:
        return 'Tamamlandı';
    }
  }

  // Check if test is completed
  bool get isCompleted => status == TestStatus.completed;

  // Get completion percentage
  double get completionPercentage {
    if (questions.isEmpty) return 0.0;
    return answers.length / questions.length;
  }

  // Get test duration
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  // Factory constructor from Map
  factory TestModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TestModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: TestType.values.firstWhere(
        (e) => e.toString() == 'TestType.${map['type']}',
        orElse: () => TestType.personality,
      ),
      status: TestStatus.values.firstWhere(
        (e) => e.toString() == 'TestStatus.${map['status']}',
        orElse: () => TestStatus.notStarted,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions: (map['questions'] as List<dynamic>? ?? [])
          .map((q) => TestQuestion.fromMap(q as Map<String, dynamic>))
          .toList(),
      answers: Map<String, dynamic>.from(map['answers'] ?? {}),
      result: map['result'],
      score: map['score'] ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] is Timestamp 
              ? (map['completedAt'] as Timestamp).toDate()
              : DateTime.parse(map['completedAt']))
          : null,
      isFavorite: map['isFavorite'] ?? false,
      karmaReward: map['karmaReward'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
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
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'answers': answers,
      'result': result,
      'score': score,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'karmaReward': karmaReward,
      'metadata': metadata,
    };
  }

  // Factory constructor from Firestore document
  factory TestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: TestType.values.firstWhere(
        (e) => e.toString() == 'TestType.${data['type']}',
        orElse: () => TestType.personality,
      ),
      status: TestStatus.values.firstWhere(
        (e) => e.toString() == 'TestStatus.${data['status']}',
        orElse: () => TestStatus.notStarted,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>? ?? [])
          .map((q) => TestQuestion.fromMap(q as Map<String, dynamic>))
          .toList(),
      answers: Map<String, dynamic>.from(data['answers'] ?? {}),
      result: data['result'],
      score: data['score'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      isFavorite: data['isFavorite'] ?? false,
      karmaReward: data['karmaReward'] ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'answers': answers,
      'result': result,
      'score': score,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isFavorite': isFavorite,
      'karmaReward': karmaReward,
      'metadata': metadata,
    };
  }

  // Copy with method for updates
  TestModel copyWith({
    String? id,
    String? userId,
    TestType? type,
    TestStatus? status,
    String? title,
    String? description,
    List<TestQuestion>? questions,
    Map<String, dynamic>? answers,
    String? result,
    int? score,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isFavorite,
    int? karmaReward,
    Map<String, dynamic>? metadata,
  }) {
    return TestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      karmaReward: karmaReward ?? this.karmaReward,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'TestModel(id: $id, type: $type, status: $status, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Test question model
class TestQuestion {
  final String id;
  final String question;
  final List<TestOption> options;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  TestQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.imageUrl,
    this.metadata = const {},
  });

  factory TestQuestion.fromMap(Map<String, dynamic> map) {
    return TestQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: (map['options'] as List<dynamic>? ?? [])
          .map((o) => TestOption.fromMap(o as Map<String, dynamic>))
          .toList(),
      imageUrl: map['imageUrl'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options.map((o) => o.toMap()).toList(),
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  TestQuestion copyWith({
    String? id,
    String? question,
    List<TestOption>? options,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return TestQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Test option model
class TestOption {
  final String id;
  final String text;
  final int points;
  final String? category;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  TestOption({
    required this.id,
    required this.text,
    this.points = 0,
    this.category,
    this.imageUrl,
    this.metadata = const {},
  });

  factory TestOption.fromMap(Map<String, dynamic> map) {
    return TestOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      points: map['points'] ?? 0,
      category: map['category'],
      imageUrl: map['imageUrl'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'points': points,
      'category': category,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  TestOption copyWith({
    String? id,
    String? text,
    int? points,
    String? category,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return TestOption(
      id: id ?? this.id,
      text: text ?? this.text,
      points: points ?? this.points,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Test result model
class TestResult {
  final String id;
  final String testId;
  final String userId;
  final TestType testType;
  final String title;
  final String description;
  final int totalScore;
  final String category;
  final List<String> traits;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final bool isShared;
  final Map<String, dynamic> metadata;

  TestResult({
    required this.id,
    required this.testId,
    required this.userId,
    required this.testType,
    required this.title,
    required this.description,
    required this.totalScore,
    required this.category,
    this.traits = const [],
    this.details = const {},
    required this.createdAt,
    this.isShared = false,
    this.metadata = const {},
  });

  factory TestResult.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TestResult(
      id: docId ?? map['id'] ?? '',
      testId: map['testId'] ?? '',
      userId: map['userId'] ?? '',
      testType: TestType.values.firstWhere(
        (e) => e.toString() == 'TestType.${map['testType']}',
        orElse: () => TestType.personality,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      totalScore: map['totalScore'] ?? 0,
      category: map['category'] ?? '',
      traits: List<String>.from(map['traits'] ?? []),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      isShared: map['isShared'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  factory TestResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TestResult(
      id: doc.id,
      testId: data['testId'] ?? '',
      userId: data['userId'] ?? '',
      testType: TestType.values.firstWhere(
        (e) => e.toString() == 'TestType.${data['testType']}',
        orElse: () => TestType.personality,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      totalScore: data['totalScore'] ?? 0,
      category: data['category'] ?? '',
      traits: List<String>.from(data['traits'] ?? []),
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isShared: data['isShared'] ?? false,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'userId': userId,
      'testType': testType.toString().split('.').last,
      'title': title,
      'description': description,
      'totalScore': totalScore,
      'category': category,
      'traits': traits,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
      'isShared': isShared,
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'testId': testId,
      'userId': userId,
      'testType': testType.toString().split('.').last,
      'title': title,
      'description': description,
      'totalScore': totalScore,
      'category': category,
      'traits': traits,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
      'isShared': isShared,
      'metadata': metadata,
    };
  }

  TestResult copyWith({
    String? id,
    String? testId,
    String? userId,
    TestType? testType,
    String? title,
    String? description,
    int? totalScore,
    String? category,
    List<String>? traits,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    bool? isShared,
    Map<String, dynamic>? metadata,
  }) {
    return TestResult(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      userId: userId ?? this.userId,
      testType: testType ?? this.testType,
      title: title ?? this.title,
      description: description ?? this.description,
      totalScore: totalScore ?? this.totalScore,
      category: category ?? this.category,
      traits: traits ?? this.traits,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      isShared: isShared ?? this.isShared,
      metadata: metadata ?? this.metadata,
    );
  }
}