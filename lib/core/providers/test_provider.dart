import 'package:flutter/foundation.dart';
import '../models/test_model.dart';
import '../models/user_model.dart';
import '../models/quiz_test_model.dart';
import '../services/firebase_service.dart';
import '../services/ai_service.dart';

class TestProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AIService _aiService = AIService();
  
  List<TestModel> _tests = [];
  List<TestResult> _testResults = [];
  List<QuizTestResult> _quizTestResults = [];
  TestModel? _currentTest;
  Map<String, dynamic> _currentAnswers = {};
  bool _isLoading = false;
  String? _error;
  bool _isGeneratingTest = false;
  bool _isGeneratingResult = false;

  // Getters
  List<TestModel> get tests => _tests;
  List<TestResult> get testResults => _testResults;
  List<QuizTestResult> get quizTestResults => _quizTestResults;
  TestModel? get currentTest => _currentTest;
  Map<String, dynamic> get currentAnswers => _currentAnswers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGeneratingTest => _isGeneratingTest;
  bool get isGeneratingResult => _isGeneratingResult;

  // Get tests by type
  List<TestModel> getTestsByType(TestType type) {
    return _tests.where((test) => test.type == type).toList();
  }

  // Get completed tests
  List<TestModel> get completedTests {
    return _tests.where((test) => test.isCompleted).toList();
  }

  // Get favorite tests
  List<TestModel> get favoriteTests {
    return _tests.where((test) => test.isFavorite).toList();
  }
  
  // Get user tests
  List<TestModel> get userTests {
    return _tests;
  }

  // Get test results by type
  List<TestResult> getResultsByType(TestType type) {
    return _testResults.where((result) => result.testType == type).toList();
  }

  // Initialize test provider
  Future<void> initialize(String userId) async {
    _setLoading(true);
    try {
      await Future.wait([
        loadUserTests(userId),
        loadUserTestResults(userId),
        loadUserQuizTestResults(userId),
      ]);
    } catch (e) {
      _setError('Test verileri yüklenirken hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user tests
  Future<void> loadUserTests(String userId) async {
    try {
      final testDocs = await _firebaseService.getUserTests(userId);
      _tests = testDocs.map((doc) => TestModel.fromFirestore(doc)).toList();
      
      // Sort by creation date (newest first)
      _tests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
    } catch (e) {
      _setError('Testler yüklenirken hata oluştu: $e');
    }
  }

  // Load user test results
  Future<void> loadUserTestResults(String userId) async {
    try {
      final resultDocs = await _firebaseService.getUserTestResults(userId);
      _testResults = resultDocs.map((doc) => TestResult.fromFirestore(doc)).toList();
      
      // Sort by creation date (newest first)
      _testResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
    } catch (e) {
      _setError('Test sonuçları yüklenirken hata oluştu: $e');
    }
  }

  // Load user quiz test results
  Future<void> loadUserQuizTestResults(String userId) async {
    try {
      final resultDocs = await _firebaseService.getUserQuizTestResults(userId);
      _quizTestResults = resultDocs.map((doc) => QuizTestResult.fromFirestore(doc)).toList();
      
      // Sort by creation date (newest first)
      _quizTestResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
    } catch (e) {
      _setError('Quiz test sonuçları yüklenirken hata oluştu: $e');
    }
  }

  // Generate love test
  Future<TestModel?> generateLoveTest(UserModel user) async {
    _setGeneratingTest(true);
    _clearError();
    
    try {
      // Generate test questions using AI
      final testData = await _aiService.generateLoveTest();
      
      final questions = (testData['questions'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((entry) {
        final index = entry.key;
        final questionData = entry.value as Map<String, dynamic>;
        
        return TestQuestion(
          id: 'q_$index',
          question: questionData['question'] ?? '',
          options: (questionData['options'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map((optEntry) {
            final optIndex = optEntry.key;
            final optText = optEntry.value as String;
            
            return TestOption(
              id: 'opt_${index}_$optIndex',
              text: optText,
              points: optIndex + 1,
            );
          }).toList(),
        );
      }).toList();
      
      final test = TestModel(
        id: '',
        userId: user.id,
        type: TestType.love,
        status: TestStatus.notStarted,
        title: 'Aşk Testi',
        description: 'Aşk hayatınız hakkında bilgi edinin',
        questions: questions,
        createdAt: DateTime.now(),
        karmaReward: 15,
      );
      
      // Save to Firebase
      final testId = await _firebaseService.saveTest(user.id, test.toFirestore());
      final savedTest = test.copyWith(id: testId);
      
      // Add to local list
      _tests.insert(0, savedTest);
      _currentTest = savedTest;
      _currentAnswers = {};
      
      notifyListeners();
      return savedTest;
      
    } catch (e) {
      _setError('Aşk testi oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingTest(false);
    }
  }

  // Generate personality test
  Future<TestModel?> generatePersonalityTest(UserModel user) async {
    _setGeneratingTest(true);
    _clearError();
    
    try {
      // Generate test questions using AI
      final testData = await _aiService.generatePersonalityTest();
      
      final questions = (testData['questions'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((entry) {
        final index = entry.key;
        final questionData = entry.value as Map<String, dynamic>;
        
        return TestQuestion(
          id: 'q_$index',
          question: questionData['question'] ?? '',
          options: (questionData['options'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map((optEntry) {
            final optIndex = optEntry.key;
            final optText = optEntry.value as String;
            
            return TestOption(
              id: 'opt_${index}_$optIndex',
              text: optText,
              points: optIndex + 1,
            );
          }).toList(),
        );
      }).toList();
      
      final test = TestModel(
        id: '',
        userId: user.id,
        type: TestType.personality,
        status: TestStatus.notStarted,
        title: 'Kişilik Testi',
        description: 'Kişiliğinizi keşfedin',
        questions: questions,
        createdAt: DateTime.now(),
        karmaReward: 20,
      );
      
      // Save to Firebase
      final testId = await _firebaseService.saveTest(user.id, test.toFirestore());
      final savedTest = test.copyWith(id: testId);
      
      // Add to local list
      _tests.insert(0, savedTest);
      _currentTest = savedTest;
      _currentAnswers = {};
      
      notifyListeners();
      return savedTest;
      
    } catch (e) {
      _setError('Kişilik testi oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingTest(false);
    }
  }

  // Generate compatibility test
  Future<TestModel?> generateCompatibilityTest(UserModel user, {
    String? partnerName,
    DateTime? partnerBirthDate,
    String? partnerZodiacSign,
  }) async {
    _setGeneratingTest(true);
    _clearError();
    
    try {
      // Generate test questions using AI
      final testData = await _aiService.generateCompatibilityTest(
        partnerName: partnerName,
        partnerBirthDate: partnerBirthDate,
        partnerZodiacSign: partnerZodiacSign,
      );
      
      // Create test model
      final test = TestModel(
        id: '',
        userId: user.id,
        type: TestType.compatibility,
        status: TestStatus.notStarted,
        title: partnerName != null 
            ? '$partnerName ile Uyumluluk Testi'
            : 'Uyumluluk Testi',
        description: 'Bu test, sizin ve partnerinizin uyumluluğunu analiz eder.',
        questions: testData['questions'] ?? [],
        createdAt: DateTime.now(),
        karmaReward: 5,
        metadata: {
          'partnerName': partnerName,
          'partnerBirthDate': partnerBirthDate?.toIso8601String(),
          'partnerZodiacSign': partnerZodiacSign,
        },
      );
      
      // Save to Firebase
      final testId = await _firebaseService.saveTest(user.id, test.toFirestore());
      final savedTest = test.copyWith(id: testId);
      
      // Add to local list
      _tests.insert(0, savedTest);
      _currentTest = savedTest;
      _currentAnswers = {};
      
      notifyListeners();
      return savedTest;
      
    } catch (e) {
      _setError('Uyumluluk testi oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingTest(false);
    }
  }

  // Generate career test
  Future<TestModel?> generateCareerTest(UserModel user) async {
    _setGeneratingTest(true);
    _clearError();
    
    try {
      // Generate test questions using AI
      final testData = await _aiService.generateCareerTest(user);
      
      final questions = (testData['questions'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((entry) {
        final index = entry.key;
        final questionData = entry.value as Map<String, dynamic>;
        
        return TestQuestion(
          id: 'q_$index',
          question: questionData['question'] ?? '',
          options: (questionData['options'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map((optEntry) {
            final optIndex = optEntry.key;
            final optText = optEntry.value as String;
            
            return TestOption(
              id: 'opt_${index}_$optIndex',
              text: optText,
              points: optIndex + 1,
            );
          }).toList(),
        );
      }).toList();
      
      final test = TestModel(
        id: '',
        userId: user.id,
        type: TestType.career,
        status: TestStatus.notStarted,
        title: 'Kariyer Rehberlik Testi',
        description: 'Kariyer yolculuğunuzda size rehberlik edecek test',
        questions: questions,
        createdAt: DateTime.now(),
        karmaReward: 20,
      );
      
      // Save to Firebase
      final testId = await _firebaseService.saveTest(user.id, test.toFirestore());
      final savedTest = test.copyWith(id: testId);
      
      // Add to local list
      _tests.insert(0, savedTest);
      _currentTest = savedTest;
      _currentAnswers = {};
      
      notifyListeners();
      return savedTest;
      
    } catch (e) {
      _setError('Kariyer testi oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingTest(false);
    }
  }

  // Generate friendship test
  Future<TestModel?> generateFriendshipTest(UserModel user) async {
    _setGeneratingTest(true);
    _clearError();
    
    try {
      // Generate test questions using AI
      final testData = await _aiService.generateFriendshipTest(user);
      
      final questions = (testData['questions'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((entry) {
        final index = entry.key;
        final questionData = entry.value as Map<String, dynamic>;
        
        return TestQuestion(
          id: 'q_$index',
          question: questionData['question'] ?? '',
          options: (questionData['options'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map((optEntry) {
            final optIndex = optEntry.key;
            final optText = optEntry.value as String;
            
            return TestOption(
              id: 'opt_${index}_$optIndex',
              text: optText,
              points: optIndex + 1,
            );
          }).toList(),
        );
      }).toList();
      
      final test = TestModel(
        id: '',
        userId: user.id,
        type: TestType.friendship,
        status: TestStatus.notStarted,
        title: 'Arkadaşlık Uyumluluk Testi',
        description: 'Arkadaşlık ilişkilerinizi analiz edin',
        questions: questions,
        createdAt: DateTime.now(),
        karmaReward: 15,
      );
      
      // Save to Firebase
      final testId = await _firebaseService.saveTest(user.id, test.toFirestore());
      final savedTest = test.copyWith(id: testId);
      
      // Add to local list
      _tests.insert(0, savedTest);
      _currentTest = savedTest;
      _currentAnswers = {};
      
      notifyListeners();
      return savedTest;
      
    } catch (e) {
      _setError('Arkadaşlık testi oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingTest(false);
    }
  }

  // Generate family test
  Future<TestModel?> generateFamilyTest(UserModel user) async {
    _setGeneratingTest(true);
    _clearError();
    
    try {
      // Generate test questions using AI
      final testData = await _aiService.generateFamilyTest(user);
      
      final questions = (testData['questions'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((entry) {
        final index = entry.key;
        final questionData = entry.value as Map<String, dynamic>;
        
        return TestQuestion(
          id: 'q_$index',
          question: questionData['question'] ?? '',
          options: (questionData['options'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map((optEntry) {
            final optIndex = optEntry.key;
            final optText = optEntry.value as String;
            
            return TestOption(
              id: 'opt_${index}_$optIndex',
              text: optText,
              points: optIndex + 1,
            );
          }).toList(),
        );
      }).toList();
      
      final test = TestModel(
        id: '',
        userId: user.id,
        type: TestType.family,
        status: TestStatus.notStarted,
        title: 'Aile Uyumluluk Testi',
        description: 'Aile ilişkilerinizi analiz edin',
        questions: questions,
        createdAt: DateTime.now(),
        karmaReward: 15,
      );
      
      // Save to Firebase
      final testId = await _firebaseService.saveTest(user.id, test.toFirestore());
      final savedTest = test.copyWith(id: testId);
      
      // Add to local list
      _tests.insert(0, savedTest);
      _currentTest = savedTest;
      _currentAnswers = {};
      
      notifyListeners();
      return savedTest;
      
    } catch (e) {
      _setError('Aile testi oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingTest(false);
    }
  }

  // Start test
  Future<void> startTest(String testId, String userId) async {
    try {
      final testIndex = _tests.indexWhere((t) => t.id == testId);
      if (testIndex != -1) {
        final test = _tests[testIndex];
        final updatedTest = test.copyWith(status: TestStatus.inProgress);
        
        await _firebaseService.updateTest(userId, testId, {
          'status': 'inProgress',
        });
        
        _tests[testIndex] = updatedTest;
        _currentTest = updatedTest;
        _currentAnswers = {};
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Test başlatılırken hata oluştu: $e');
    }
  }

  // Answer question
  void answerQuestion(String questionId, String optionId) {
    _currentAnswers[questionId] = optionId;
    notifyListeners();
  }

  // Submit test and generate result
  Future<TestResult?> submitTest(UserModel user) async {
    if (_currentTest == null) return null;
    
    _setGeneratingResult(true);
    _clearError();
    
    try {
      // Update test status
      final completedTest = _currentTest!.copyWith(
        status: TestStatus.completed,
        answers: _currentAnswers,
        completedAt: DateTime.now(),
      );
      
      await _firebaseService.updateTest(user.id, _currentTest!.id, {
        'status': 'completed',
        'answers': _currentAnswers,
        'completedAt': DateTime.now(),
      });
      
      // Update local test
      final testIndex = _tests.indexWhere((t) => t.id == _currentTest!.id);
      if (testIndex != -1) {
        _tests[testIndex] = completedTest;
      }
      
      // Generate result using AI
      final resultText = await _aiService.generateTestResult(
        testType: _currentTest!.type.toString().split('.').last,
        answers: _currentAnswers,
        user: user,
      );
      
      // Calculate score
      final totalScore = _calculateTestScore();
      
      // Create test result
      final testResult = TestResult(
        id: '',
        testId: _currentTest!.id,
        userId: user.id,
        testType: _currentTest!.type,
        title: '${_currentTest!.title} Sonucu',
        description: resultText,
        totalScore: totalScore,
        category: _getResultCategory(totalScore, _currentTest!.type),
        traits: _getResultTraits(totalScore, _currentTest!.type),
        createdAt: DateTime.now(),
      );
      
      // Save result to Firebase
      final resultId = await _firebaseService.saveTestResult(user.id, testResult.toFirestore());
      final savedResult = testResult.copyWith(id: resultId);
      
      // Add to local list
      _testResults.insert(0, savedResult);
      
      notifyListeners();
      return savedResult;
      
    } catch (e) {
      _setError('Test sonucu oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingResult(false);
    }
  }

  // Set current test
  void setCurrentTest(TestModel? test) {
    _currentTest = test;
    _currentAnswers = test?.answers ?? {};
    notifyListeners();
  }

  // Clear current test
  void clearCurrentTest() {
    _currentTest = null;
    _currentAnswers = {};
    notifyListeners();
  }

  // Toggle test favorite status
  Future<void> toggleTestFavorite(String testId, String userId) async {
    try {
      final testIndex = _tests.indexWhere((t) => t.id == testId);
      if (testIndex != -1) {
        final test = _tests[testIndex];
        final updatedTest = test.copyWith(isFavorite: !test.isFavorite);
        
        await _firebaseService.updateTest(userId, testId, {
          'isFavorite': updatedTest.isFavorite,
        });
        
        _tests[testIndex] = updatedTest;
        notifyListeners();
      }
    } catch (e) {
      _setError('Favori durumu güncellenirken hata oluştu: $e');
    }
  }

  // Delete test
  Future<void> deleteTest(String testId, String userId) async {
    try {
      await _firebaseService.deleteTest(userId, testId);
      _tests.removeWhere((t) => t.id == testId);
      
      // Also remove related results
      _testResults.removeWhere((r) => r.testId == testId);
      
      notifyListeners();
    } catch (e) {
      _setError('Test silinirken hata oluştu: $e');
    }
  }

  // Share test result
  Future<void> shareTestResult(String resultId, String userId) async {
    try {
      final resultIndex = _testResults.indexWhere((r) => r.id == resultId);
      if (resultIndex != -1) {
        final result = _testResults[resultIndex];
        final updatedResult = result.copyWith(isShared: true);
        
        await _firebaseService.updateTestResult(userId, resultId, {
          'isShared': true,
        });
        
        _testResults[resultIndex] = updatedResult;
        notifyListeners();
      }
    } catch (e) {
      _setError('Test sonucu paylaşılırken hata oluştu: $e');
    }
  }

  // Helper methods
  int _calculateTestScore() {
    int totalScore = 0;
    
    for (final _ in _currentAnswers.values) {
      // Extract points from option ID or use a default scoring system
      totalScore += 1; // Simplified scoring
    }
    
    return totalScore;
  }

  String _getResultCategory(int score, TestType type) {
    switch (type) {
      case TestType.love:
        if (score <= 5) return 'Romantik';
        if (score <= 10) return 'Tutkulu';
        return 'Dengeli';
      case TestType.personality:
        if (score <= 5) return 'İçe Dönük';
        if (score <= 10) return 'Dengeli';
        return 'Dışa Dönük';
      case TestType.compatibility:
        if (score <= 15) return 'Düşük Uyum';
        if (score <= 25) return 'Orta Uyum';
        if (score <= 35) return 'Yüksek Uyum';
        return 'Mükemmel Uyum';
      case TestType.career:
        if (score <= 10) return 'Araştırmacı';
        if (score <= 20) return 'Analitik';
        if (score <= 30) return 'Yaratıcı';
        return 'Lider';
      case TestType.friendship:
        if (score <= 10) return 'Sadık Arkadaş';
        if (score <= 20) return 'Sosyal Arkadaş';
        if (score <= 30) return 'Destekleyici Arkadaş';
        return 'Mükemmel Arkadaş';
      case TestType.family:
        if (score <= 25) return 'Uzak Aile';
        if (score <= 50) return 'Yakın Aile';
        if (score <= 75) return 'Destekleyici Aile';
        return 'Mükemmel Aile';
    }
  }

  List<String> _getResultTraits(int score, TestType type) {
    switch (type) {
      case TestType.love:
        return ['Sadık', 'Anlayışlı', 'Romantik'];
      case TestType.personality:
        return ['Yaratıcı', 'Analitik', 'Sosyal'];
      case TestType.compatibility:
        if (score <= 15) return ['Farklı Bakış Açıları', 'Gelişim Alanları'];
        if (score <= 25) return ['Ortak Noktalar', 'Uyumlu Yanlar'];
        if (score <= 35) return ['Güçlü Bağ', 'Tamamlayıcı', 'Uyumlu'];
        return ['Mükemmel Eşleşme', 'Ruh Eşi', 'Tam Uyum'];
      case TestType.career:
        if (score <= 10) return ['Detaycı', 'Sabırlı', 'Metodical'];
        if (score <= 20) return ['Mantıklı', 'Sistematik', 'Güvenilir'];
        if (score <= 30) return ['Yaratıcı', 'Yenilikçi', 'Esnek'];
        return ['Lider', 'Vizyoner', 'Kararlı'];
      case TestType.friendship:
        if (score <= 10) return ['Sadık', 'Güvenilir', 'Destekleyici'];
        if (score <= 20) return ['Eğlenceli', 'Anlayışlı', 'Paylaşımcı'];
        if (score <= 30) return ['Sosyal', 'Empatik', 'Koruyucu'];
        return ['Mükemmel Arkadaş', 'Güvenilir', 'Sırdaş'];
      case TestType.family:
        if (score <= 10) return ['Bağımsız', 'Mesafeli', 'Bireysel'];
        if (score <= 20) return ['Destekleyici', 'Anlayışlı', 'Saygılı'];
        if (score <= 30) return ['Yakın', 'Koruyucu', 'Paylaşımcı'];
        return ['Mükemmel Aile', 'Birlik', 'Sevgi Dolu'];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setGeneratingTest(bool generating) {
    _isGeneratingTest = generating;
    notifyListeners();
  }

  void _setGeneratingResult(bool generating) {
    _isGeneratingResult = generating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}