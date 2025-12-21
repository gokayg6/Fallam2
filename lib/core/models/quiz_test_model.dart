import 'package:cloud_firestore/cloud_firestore.dart';

// Quiz test model for testler.md tests
class QuizTestDefinition {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<QuizSection> sections;
  final Map<String, dynamic> metadata;

  QuizTestDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.sections,
    this.metadata = const {},
  });
}

class QuizSection {
  final String id;
  final String title;
  final QuizSectionType type;
  final List<QuizField> fields;
  final List<QuizQuestion> questions;

  QuizSection({
    required this.id,
    required this.title,
    required this.type,
    this.fields = const [],
    this.questions = const [],
  });
}

enum QuizSectionType {
  form, // İsim, doğum tarihi gibi input alanları
  question, // Çoktan seçmeli sorular
}

class QuizField {
  final String id;
  final String label;
  final QuizFieldType type;
  final String? placeholder;
  final bool required;
  final String? hint;

  QuizField({
    required this.id,
    required this.label,
    required this.type,
    this.placeholder,
    this.required = true,
    this.hint,
  });
}

enum QuizFieldType {
  text, // İsim
  date, // Doğum tarihi
  mood, // Ruh hali (iyi / karışık / yorgun / enerjik)
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;
  final String? hint;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.hint,
  });
}

class QuizOption {
  final String id;
  final String text;
  final String? category;
  final Map<String, dynamic> metadata;

  QuizOption({
    required this.id,
    required this.text,
    this.category,
    this.metadata = const {},
  });
}

// Quiz test sonucu modeli
class QuizTestResult {
  final String id;
  final String userId;
  final String testId;
  final String testTitle;
  final String testDescription;
  final String emoji;
  final String resultText;
  final Map<String, dynamic> formData;
  final Map<String, String> answers;
  final DateTime createdAt;

  QuizTestResult({
    required this.id,
    required this.userId,
    required this.testId,
    required this.testTitle,
    required this.testDescription,
    required this.emoji,
    required this.resultText,
    required this.formData,
    required this.answers,
    required this.createdAt,
  });

  factory QuizTestResult.fromMap(Map<String, dynamic> map, [String? docId]) {
    return QuizTestResult(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      testId: map['testId'] ?? '',
      testTitle: map['testTitle'] ?? '',
      testDescription: map['testDescription'] ?? '',
      emoji: map['emoji'] ?? '🔮',
      resultText: map['resultText'] ?? '',
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
      answers: Map<String, String>.from(map['answers'] ?? {}),
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt']),
    );
  }

  factory QuizTestResult.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizTestResult(
      id: doc.id,
      userId: data['userId'] ?? '',
      testId: data['testId'] ?? '',
      testTitle: data['testTitle'] ?? '',
      testDescription: data['testDescription'] ?? '',
      emoji: data['emoji'] ?? '🔮',
      resultText: data['resultText'] ?? '',
      formData: Map<String, dynamic>.from(data['formData'] ?? {}),
      answers: Map<String, String>.from(data['answers'] ?? {}),
      createdAt: (data['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'testId': testId,
      'testTitle': testTitle,
      'testDescription': testDescription,
      'emoji': emoji,
      'resultText': resultText,
      'formData': formData,
      'answers': answers,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'testId': testId,
      'testTitle': testTitle,
      'testDescription': testDescription,
      'emoji': emoji,
      'resultText': resultText,
      'formData': formData,
      'answers': answers,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  QuizTestResult copyWith({
    String? id,
    String? userId,
    String? testId,
    String? testTitle,
    String? testDescription,
    String? emoji,
    String? resultText,
    Map<String, dynamic>? formData,
    Map<String, String>? answers,
    DateTime? createdAt,
  }) {
    return QuizTestResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      testTitle: testTitle ?? this.testTitle,
      testDescription: testDescription ?? this.testDescription,
      emoji: emoji ?? this.emoji,
      resultText: resultText ?? this.resultText,
      formData: formData ?? this.formData,
      answers: answers ?? this.answers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

