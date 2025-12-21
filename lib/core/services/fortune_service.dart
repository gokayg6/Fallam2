import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fortune_result.dart';
import '../models/fortune_type.dart';
import '../models/user_model.dart';
import '../constants/app_strings.dart';
import 'ai_service.dart';

class FortuneService {
  static final FortuneService _instance = FortuneService._internal();
  factory FortuneService() => _instance;
  FortuneService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();

  // Generate fortune based on type and input data
  Future<FortuneResult> generateFortune({
    required FortuneType type,
    required Map<String, dynamic> inputData,
    String? question,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userModel = await _getUserModel(user.uid);
    
    FortuneResult result;
    
    switch (type) {
      case FortuneType.coffee:
        result = await _generateCoffeeFortune(inputData, userModel, question);
        break;
      case FortuneType.tarot:
        result = await _generateTarotFortune(inputData, userModel, question);
        break;
      case FortuneType.dream:
        result = await _generateDreamFortune(inputData, userModel);
        break;
      case FortuneType.palm:
        result = await _generatePalmFortune(inputData, userModel, question);
        break;
      case FortuneType.astrology:
        result = await _generateAstrologyFortune(inputData, userModel, question);
        break;
      case FortuneType.katina:
        result = await _generateKatinaFortune(inputData, userModel, question);
        break;
      case FortuneType.face:
        result = await _generateFaceFortune(inputData, userModel, question);
        break;
    }

    // Attach waiting window (15-25 min) into metadata so UI can gate reveal
    // Debug modda bekleme penceresini tamamen atla
    if (!kDebugMode) {
    final waitMinutes = 15 + (DateTime.now().millisecond % 11); // 15..25
    final availableAt = DateTime.now().add(Duration(minutes: waitMinutes));
    final updatedMeta = Map<String, dynamic>.from(result.metadata)
      ..addAll({
        'availableAt': availableAt.toIso8601String(),
        'waitMinutes': waitMinutes,
      });
    result = result.copyWith(metadata: updatedMeta);
    }

    // Save to Firestore and return result with id
    result = await _saveFortuneResult(result);
    return result;
  }

  Future<FortuneResult> _generateCoffeeFortune(
    Map<String, dynamic> inputData,
    UserModel user,
    String? question,
  ) async {
    final imageUrls = inputData['imageUrls'] as List<String>? ?? [];
    final topics = <String>[];
    if (inputData['topic1'] != null) topics.add(inputData['topic1'].toString());
    if (inputData['topic2'] != null) topics.add(inputData['topic2'].toString());
    
    final interpretation = await _aiService.generateCoffeeReading(
      imageUrls: imageUrls,
      user: user,
      question: question,
      topics: topics.isNotEmpty ? topics : null,
      english: AppStrings.isEnglish,
    );

    final result = FortuneResult(
      id: '',
      type: FortuneType.coffee,
      title: '${AppStrings.coffeeFortune} ${AppStrings.interpretation}',
      interpretation: _cleanInterpretation(interpretation, imageUrls.length),
      question: question,
      imageUrls: imageUrls,
      metadata: {
        'imageCount': imageUrls.length,
        'uploadTime': DateTime.now().toIso8601String(),
        'topics': topics,
      },
      createdAt: DateTime.now(),
      userId: user.id,
    );
    return result;
  }

  Future<FortuneResult> _generateTarotFortune(
    Map<String, dynamic> inputData,
    UserModel user,
    String? question,
  ) async {
    final selectedCards = inputData['selectedCards'] as List<String>? ?? [];
    final cardNames = selectedCards.map(_getTarotCardNameForId).toList();
    
    final interpretation = await _aiService.generateTarotReading(
      cardIds: selectedCards,
      cardNames: cardNames,
      user: user,
      question: question,
      english: AppStrings.isEnglish,
    );

    return FortuneResult(
      id: '',
      type: FortuneType.tarot,
      title: '${AppStrings.tarot} ${AppStrings.interpretation}',
      interpretation: _cleanInterpretation(interpretation, 0), // Tarot doesn't use image placeholders
      question: question,
      selectedCards: selectedCards,
      metadata: {
        'cardCount': selectedCards.length,
        'spreadType': inputData['spreadType'] ?? 'single',
      },
      createdAt: DateTime.now(),
      userId: user.id,
    );
  }

  String _getTarotCardNameForId(String id) {
    const entries = [
      {'id': 'the_fool', 'name': 'Deli'},
      {'id': 'magician', 'name': 'Büyücü'},
      {'id': 'high_priestess', 'name': 'Başrahibe'},
      {'id': 'empress', 'name': 'İmparatoriçe'},
      {'id': 'emperor', 'name': 'İmparator'},
      {'id': 'hierophant', 'name': 'Aziz'},
      {'id': 'lovers', 'name': 'Aşıklar'},
      {'id': 'chariot', 'name': 'Savaş Arabası'},
      {'id': 'strength', 'name': 'Güç'},
      {'id': 'hermit', 'name': 'Ermiş'},
      {'id': 'wheel_of_fortune', 'name': 'Kader Çarkı'},
      {'id': 'justice', 'name': 'Adalet'},
      {'id': 'the_hanged_man', 'name': 'Asılan Adam'},
      {'id': 'death', 'name': 'Ölüm'},
      {'id': 'temperance', 'name': 'Denge'},
      {'id': 'devil', 'name': 'Şeytan'},
      {'id': 'the_tower', 'name': 'Kule'},
      {'id': 'the_moon', 'name': 'Ay'},
      {'id': 'the_sun', 'name': 'Güneş'},
      {'id': 'judgement', 'name': 'Mahkeme'},
      {'id': 'the_world', 'name': 'Dünya'},
      {'id': 'page_of_swords', 'name': 'Vale Kılıç'},
      {'id': 'page_of_cups', 'name': 'Vale Kupalar'},
      {'id': 'page_of_wands', 'name': 'Vale Değnek'},
      {'id': 'page_of_pentacles', 'name': 'Vale Tılsım'},
      {'id': 'knight_of_swords', 'name': 'Şövalye Kılıç'},
      {'id': 'knight_of_wands', 'name': 'Şövalye Değnek'},
      {'id': 'knight_of_pentacles', 'name': 'Şövalye Tılsım'},
      {'id': 'knight_of_cups', 'name': 'Şövalye Kupalar'},
      {'id': 'queen_of_pentacles', 'name': 'Kraliçe Tılsım'},
      {'id': 'queen_of_cups', 'name': 'Kraliçe Kupalar'},
      {'id': 'queen_of_swords', 'name': 'Kraliçe Kılıç'},
      {'id': 'queen_of_wands', 'name': 'Kraliçe Değnek'},
      {'id': 'king_of_pentacles', 'name': 'Kral Tılsım'},
      {'id': 'king_of_cups', 'name': 'Kral Kupalar'},
      {'id': 'king_of_swords', 'name': 'Kral Kılıç'},
      {'id': 'king_of_wands', 'name': 'Kral Değnek'},
    ];
    for (final e in entries) {
      if (e['id'] == id) return e['name']!;
    }
    return id;
  }

  Future<FortuneResult> _generateDreamFortune(
    Map<String, dynamic> inputData,
    UserModel user,
  ) async {
    final dreamDescription = inputData['dreamDescription'] as String? ?? '';
    
    final interpretation = await _aiService.generateDreamInterpretation(
      dreamDescription: dreamDescription,
      user: user,
      english: AppStrings.isEnglish,
    );

    return FortuneResult(
      id: '',
      type: FortuneType.dream,
      title: AppStrings.dreamInterpretation,
      interpretation: _cleanInterpretation(interpretation, 0), // Dream doesn't use image placeholders
      metadata: {
        'dreamLength': dreamDescription.length,
        'hasSymbols': inputData['symbols']?.isNotEmpty ?? false,
        'dreamText': dreamDescription,
      },
      createdAt: DateTime.now(),
      userId: user.id,
    );
  }

  Future<FortuneResult> _generatePalmFortune(
    Map<String, dynamic> inputData,
    UserModel user,
    String? question,
  ) async {
    final palmImageUrl = inputData['palmImageUrl'] as String? ?? '';
    
    final interpretation = await _aiService.generatePalmReading(
      palmImageUrl: palmImageUrl,
      user: user,
      question: question,
      english: AppStrings.isEnglish,
    );

    return FortuneResult(
      id: '',
      type: FortuneType.palm,
      title: '${AppStrings.palm} ${AppStrings.interpretation}',
      interpretation: _cleanInterpretation(interpretation, palmImageUrl.isNotEmpty ? 1 : 0),
      question: question,
      imageUrls: palmImageUrl.isNotEmpty ? [palmImageUrl] : [],
      metadata: {
        'hasImage': palmImageUrl.isNotEmpty,
        'analysisType': 'palm_lines',
      },
      createdAt: DateTime.now(),
      userId: user.id,
    );
  }

  Future<FortuneResult> _generateAstrologyFortune(
    Map<String, dynamic> inputData,
    UserModel user,
    String? question,
  ) async {
    final birthDate = inputData['birthDate'] as DateTime? ?? DateTime.now();
    final birthPlace = inputData['birthPlace'] as String? ?? '';
    
    final interpretation = await _aiService.generateAstrologyReading(
      birthDate: birthDate,
      birthPlace: birthPlace,
      user: user,
      question: question,
      english: AppStrings.isEnglish,
    );

    return FortuneResult(
      id: '',
      type: FortuneType.astrology,
      title: '${AppStrings.astrology} ${AppStrings.interpretation}',
      interpretation: _cleanInterpretation(interpretation, 0), // Astrology doesn't use image placeholders
      question: question,
      metadata: {
        'birthDate': birthDate.toIso8601String(),
        'birthPlace': birthPlace,
        'zodiacSign': _getZodiacSign(birthDate),
      },
      createdAt: DateTime.now(),
      userId: user.id,
    );
  }

  Future<FortuneResult> _generateKatinaFortune(
    Map<String, dynamic> inputData,
    UserModel user,
    String? question,
  ) async {
    // Katina fortune implementation
    final isEnglish = AppStrings.isEnglish;
    final userMessage = isEnglish
        ? 'Read Katina fortune. ${question ?? ''}'
        : 'Katina falı bak. ${question ?? ''}';
    final interpretation = await _aiService.generateMysticReply(
      userMessage: userMessage,
      topic: MysticTopic.fortune,
      extras: {
        'type': 'katina',
        'user': {'name': user.name, 'email': user.email},
        if (question != null) 'question': question,
      },
      english: isEnglish,
    );

    return FortuneResult(
      id: '',
      type: FortuneType.katina,
      title: '${AppStrings.katinaFortune} ${AppStrings.interpretation}',
      interpretation: _cleanInterpretation(interpretation, 0), // Katina doesn't use image placeholders
      question: question,
      metadata: {
        'fortuneType': 'katina',
        'generatedAt': DateTime.now().toIso8601String(),
      },
      createdAt: DateTime.now(),
      userId: user.id,
    );
  }

  Future<FortuneResult> _generateFaceFortune(
    Map<String, dynamic> inputData,
    UserModel user,
    String? question,
  ) async {
    // Face fortune implementation
    final imageUrls = (inputData['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    final isEnglish = AppStrings.isEnglish;
    final imageContext = imageUrls.isNotEmpty 
        ? (isEnglish ? 'Analyze the uploaded face photos. ' : 'Yüklenen yüz fotoğraflarını analiz et. ')
        : '';
    final userMessage = isEnglish
        ? 'Read face fortune. $imageContext Analyze facial features in detail: eye shape, nose structure, lip shape, eyebrow structure, jaw structure and overall facial symmetry. Provide a comprehensive interpretation about personality traits, character analysis, future predictions and life path. Your interpretation should be at least 400-500 words. ${question ?? ''}'
        : 'Yüz falı bak. $imageContext Yüz hatlarını, göz şeklini, burun yapısını, dudak şeklini, kaş yapısını, çene yapısını ve genel yüz simetrisini detaylıca analiz et. Kişilik özellikleri, karakter analizi, gelecek tahminleri ve yaşam yolu hakkında kapsamlı bir yorum yap. Yorumun en az 400-500 kelime olsun. ${question ?? ''}';
    
    final interpretation = await _aiService.generateMysticReply(
      userMessage: userMessage,
      topic: MysticTopic.fortune,
      extras: {
        'type': 'face',
        'user': {'name': user.name, 'email': user.email},
        if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (question != null) 'question': question,
      },
      english: isEnglish,
    );

    return FortuneResult(
      id: '',
      type: FortuneType.face,
      title: '${AppStrings.faceFortune} ${AppStrings.interpretation}',
      interpretation: _cleanInterpretation(interpretation, imageUrls.length),
      question: question,
      imageUrls: imageUrls,
      metadata: {
        'fortuneType': 'face',
        'generatedAt': DateTime.now().toIso8601String(),
      },
      createdAt: DateTime.now(),
      userId: user.id,
    );
  }

  // Clean interpretation text by removing $1, $2, etc. placeholders
  String _cleanInterpretation(String interpretation, int imageCount) {
    // Köşeli parantezleri temizle (kahve falı için)
    interpretation = interpretation.replaceAll(RegExp(r'\[|\]'), '');
    // Remove $1, $2, $3, etc. placeholders that AI might use for image references
    String cleaned = interpretation;
    // Remove any $ followed by digits (e.g., $1, $2, $3)
    cleaned = cleaned.replaceAll(RegExp(r'\$\d+'), '');
    // Remove $1 at start of sentences (e.g., "$1 Kalp" -> "Kalp")
    cleaned = cleaned.replaceAll(RegExp(r'\$\d+\s*([A-ZÇĞIİÖŞÜa-zçğıöşü])'), r'$1');
    // Clean up double spaces and trim
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.trim();
  }

  // Upload images to Firebase Storage
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final List<String> downloadUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      if (!await file.exists()) {
        throw Exception('Image file does not exist: ${file.path}');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'fortune_images/${user.uid}/${timestamp}_${i}.jpg';
      
      try {
        final ref = _storage.ref().child(fileName);
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': timestamp.toString(),
            'userId': user.uid,
          },
        );
        
        // Upload and wait for completion
        final uploadTask = ref.putFile(file, metadata);
        final snapshot = await uploadTask;
        
        // Verify upload succeeded
        if (snapshot.state != TaskState.success) {
          throw Exception('Upload failed: ${snapshot.state}');
        }
        
        // Wait a bit to ensure file is available before getting URL
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Get download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        throw Exception('Failed to upload image $i: $e');
      }
    }
    
    if (downloadUrls.isEmpty) {
      throw Exception('No images were uploaded successfully');
    }
    
    return downloadUrls;
  }

  // Save fortune result to Firestore
  Future<FortuneResult> _saveFortuneResult(FortuneResult result) async {
    final docRef = _firestore.collection('readings').doc();
    final resultWithId = result.copyWith(id: docRef.id);
    await docRef.set(resultWithId.toMap());
    return resultWithId;
  }

  // Get user fortunes
  Future<List<FortuneResult>> getUserFortunes(String userId) async {
    final snapshot = await _firestore
        .collection('readings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FortuneResult.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get user model
  Future<UserModel> _getUserModel(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return UserModel.fromFirestore(doc);
  }

  // Helper method to get zodiac sign
  String _getZodiacSign(DateTime birthDate) {
    const signs = [
      'Capricorn', 'Aquarius', 'Pisces', 'Aries', 'Taurus', 'Gemini',
      'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius'
    ];
    
    const dates = [
      [22, 12], [20, 1], [19, 2], [21, 3], [21, 4], [21, 5],
      [21, 6], [23, 7], [23, 8], [23, 9], [23, 10], [22, 11]
    ];
    
    for (int i = 0; i < signs.length; i++) {
      final [day, month] = dates[i];
      if (birthDate.month == month && birthDate.day >= day) {
        return signs[i];
      }
    }
    return 'Capricorn';
  }

  // Update fortune rating
  Future<void> updateFortuneRating(String fortuneId, double rating) async {
    await _firestore.collection('readings').doc(fortuneId).update({
      'rating': rating,
    });
  }

  // Toggle fortune favorite status
  Future<void> toggleFortuneFavorite(String fortuneId, bool isFavorite) async {
    await _firestore.collection('readings').doc(fortuneId).update({
      'isFavorite': isFavorite,
    });
  }
}
