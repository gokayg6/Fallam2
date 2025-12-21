import 'package:flutter/foundation.dart';
import '../models/fortune_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/ai_service.dart';
import '../constants/app_strings.dart';

class FortuneProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AIService _aiService = AIService();
  
  List<FortuneModel> _fortunes = [];
  List<TarotCard> _tarotCards = [];
  List<FortuneTeller> _fortuneTellers = [];
  FortuneModel? _currentFortune;
  bool _isLoading = false;
  String? _error;
  bool _isGeneratingFortune = false;

  // Getters
  List<FortuneModel> get fortunes => _fortunes;
  List<TarotCard> get tarotCards => _tarotCards;
  List<FortuneTeller> get fortuneTellers => _fortuneTellers;
  FortuneModel? get currentFortune => _currentFortune;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGeneratingFortune => _isGeneratingFortune;

  // Get fortunes by type
  List<FortuneModel> getFortunesByType(FortuneType type) {
    return _fortunes.where((fortune) => fortune.type == type).toList();
  }

  // Get completed fortunes
  List<FortuneModel> get completedFortunes {
    return _fortunes.where((fortune) => fortune.isCompleted).toList();
  }

  // Get favorite fortunes
  List<FortuneModel> get favoriteFortunes {
    return _fortunes.where((fortune) => fortune.isFavorite).toList();
  }

  // Initialize fortune provider
  Future<void> initialize(String userId) async {
    _setLoading(true);
    try {
      await Future.wait([
        loadUserFortunes(userId),
        loadTarotCards(),
        loadFortuneTellers(),
      ]);
    } catch (e) {
      _setError('Fal verileri yüklenirken hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user fortunes
  Future<void> loadUserFortunes(String userId) async {
    try {
      final fortuneDocs = await _firebaseService.getUserFortunes(userId);
      _fortunes = fortuneDocs.map((doc) => FortuneModel.fromFirestore(doc)).toList();
      
      // Sort by creation date (newest first)
      _fortunes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
    } catch (e) {
      _setError('Fallar yüklenirken hata oluştu: $e');
    }
  }

  // Load tarot cards
  Future<void> loadTarotCards() async {
    try {
      final cardDocs = await _firebaseService.getTarotCards();
      _tarotCards = cardDocs.map((doc) => TarotCard.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading tarot cards: $e');
      // Use fallback cards if Firebase fails
      _loadFallbackTarotCards();
    }
  }

  // Load fortune tellers
  Future<void> loadFortuneTellers() async {
    try {
      final tellerDocs = await _firebaseService.getFortuneTellers();
      _fortuneTellers = tellerDocs.map((doc) => FortuneTeller.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading fortune tellers: $e');
      // Use fallback fortune tellers if Firebase fails
      _loadFallbackFortuneTellers();
    }
  }

  // Create tarot fortune
  Future<FortuneModel?> createTarotFortune({
    required UserModel user,
    required List<String> selectedCardIds,
    String? question,
    bool isForSelf = true,
    String? targetPersonName,
  }) async {
    _setGeneratingFortune(true);
    _clearError();
    
    try {
      // Create initial fortune record
      final fortune = FortuneModel(
        id: '',
        userId: user.id,
        type: FortuneType.tarot,
        status: FortuneStatus.processing,
        title: AppStrings.tarotFortune,
        selectedCards: selectedCardIds,
        question: question,
        createdAt: DateTime.now(),
        isForSelf: isForSelf,
        targetPersonName: targetPersonName,
        karmaUsed: 20,
      );
      
      // Save to Firebase
      final fortuneId = await _firebaseService.saveFortune(user.id, fortune.toFirestore());
      if (fortuneId == null) {
        throw Exception('Failed to save fortune');
      }
      final savedFortune = fortune.copyWith(id: fortuneId);
      
      // Generate AI interpretation
      final selectedCardNames = _getCardNamesByIds(selectedCardIds);
      final interpretation = await _aiService.generateTarotReading(
        cardIds: selectedCardIds,
        cardNames: selectedCardNames,
        user: user,
        question: question,
      );
      
      // Update fortune with interpretation
      final completedFortune = savedFortune.copyWith(
        interpretation: interpretation,
        status: FortuneStatus.completed,
        completedAt: DateTime.now(),
      );
      
      await _firebaseService.updateFortune(user.id, fortuneId, {
        'interpretation': interpretation,
        'status': 'completed',
        'completedAt': DateTime.now(),
      });
      
      // Add to local list
      _fortunes.insert(0, completedFortune);
      _currentFortune = completedFortune;
      
      notifyListeners();
      return completedFortune;
      
    } catch (e) {
      _setError('Tarot falı oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingFortune(false);
    }
  }

  // Create coffee fortune
  Future<FortuneModel?> createCoffeeFortune({
    required UserModel user,
    required List<String> imageUrls,
    String? question,
    bool isForSelf = true,
    String? targetPersonName,
  }) async {
    _setGeneratingFortune(true);
    _clearError();
    
    try {
      // Create initial fortune record
      final fortune = FortuneModel(
        id: '',
        userId: user.id,
        type: FortuneType.coffee,
        status: FortuneStatus.processing,
        title: AppStrings.coffeeFortune,
        imageUrls: imageUrls,
        question: question,
        createdAt: DateTime.now(),
        isForSelf: isForSelf,
        targetPersonName: targetPersonName,
        karmaUsed: 30,
      );
      
      // Save to Firebase
      final fortuneId = await _firebaseService.saveFortune(user.id, fortune.toFirestore());
      if (fortuneId == null) {
        throw Exception('Failed to save fortune');
      }
      final savedFortune = fortune.copyWith(id: fortuneId);
      
      // Generate AI interpretation
      final interpretation = await _aiService.generateCoffeeReading(
        imageUrls: imageUrls,
        user: user,
        question: question,
      );
      
      // Update fortune with interpretation
      final completedFortune = savedFortune.copyWith(
        interpretation: interpretation,
        status: FortuneStatus.completed,
        completedAt: DateTime.now(),
      );
      
      await _firebaseService.updateFortune(user.id, fortuneId, {
        'interpretation': interpretation,
        'status': 'completed',
        'completedAt': DateTime.now(),
      });
      
      // Add to local list
      _fortunes.insert(0, completedFortune);
      _currentFortune = completedFortune;
      
      notifyListeners();
      return completedFortune;
      
    } catch (e) {
      _setError('Kahve falı oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingFortune(false);
    }
  }

  // Create palm fortune
  Future<FortuneModel?> createPalmFortune({
    required UserModel user,
    required String palmImageUrl,
    String? question,
    bool isForSelf = true,
    String? targetPersonName,
  }) async {
    _setGeneratingFortune(true);
    _clearError();
    
    try {
      final fortune = FortuneModel(
        id: '',
        userId: user.id,
        type: FortuneType.palm,
        status: FortuneStatus.processing,
        title: 'El Falı',
        imageUrls: [palmImageUrl],
        question: question,
        createdAt: DateTime.now(),
        isForSelf: isForSelf,
        targetPersonName: targetPersonName,
        karmaUsed: 25,
      );
      
      final fortuneId = await _firebaseService.saveFortune(user.id, fortune.toFirestore());
      if (fortuneId == null) {
        throw Exception('Failed to save fortune');
      }
      final savedFortune = fortune.copyWith(id: fortuneId);
      
      final interpretation = await _aiService.generatePalmReading(
        palmImageUrl: palmImageUrl,
        user: user,
        question: question,
      );
      
      final completedFortune = savedFortune.copyWith(
        interpretation: interpretation,
        status: FortuneStatus.completed,
        completedAt: DateTime.now(),
      );
      
      await _firebaseService.updateFortune(user.id, fortuneId, {
        'interpretation': interpretation,
        'status': 'completed',
        'completedAt': DateTime.now(),
      });
      
      _fortunes.insert(0, completedFortune);
      _currentFortune = completedFortune;
      
      notifyListeners();
      return completedFortune;
      
    } catch (e) {
      _setError('El falı oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingFortune(false);
    }
  }

  // Create astrology reading
  Future<FortuneModel?> createAstrologyReading({
    required UserModel user,
    required DateTime birthDate,
    required String birthPlace,
    String? question,
    bool isForSelf = true,
    String? targetPersonName,
  }) async {
    _setGeneratingFortune(true);
    _clearError();
    
    try {
      final fortune = FortuneModel(
        id: '',
        userId: user.id,
        type: FortuneType.astrology,
        status: FortuneStatus.processing,
        title: 'Astroloji Yorumu',
        inputData: {
          'birthDate': birthDate.toIso8601String(),
          'birthPlace': birthPlace,
        },
        question: question,
        createdAt: DateTime.now(),
        isForSelf: isForSelf,
        targetPersonName: targetPersonName,
        karmaUsed: 40,
      );
      
      final fortuneId = await _firebaseService.saveFortune(user.id, fortune.toFirestore());
      if (fortuneId == null) {
        throw Exception('Failed to save fortune');
      }
      final savedFortune = fortune.copyWith(id: fortuneId);
      
      final interpretation = await _aiService.generateAstrologyReading(
        birthDate: birthDate,
        birthPlace: birthPlace,
        user: user,
        question: question,
      );
      
      final completedFortune = savedFortune.copyWith(
        interpretation: interpretation,
        status: FortuneStatus.completed,
        completedAt: DateTime.now(),
      );
      
      await _firebaseService.updateFortune(user.id, fortuneId, {
        'interpretation': interpretation,
        'status': 'completed',
        'completedAt': DateTime.now(),
      });
      
      _fortunes.insert(0, completedFortune);
      _currentFortune = completedFortune;
      
      notifyListeners();
      return completedFortune;
      
    } catch (e) {
      _setError('Astroloji yorumu oluşturulurken hata oluştu: $e');
      return null;
    } finally {
      _setGeneratingFortune(false);
    }
  }

  // Generate daily horoscope
  Future<String?> generateDailyHoroscope(String zodiacSign) async {
    try {
      final isEnglish = AppStrings.isEnglish;
      return await _aiService.generateDailyHoroscope(
        zodiacSign: zodiacSign,
        date: DateTime.now(),
        english: isEnglish,
      );
    } catch (e) {
      _setError('Günlük yorum oluşturulurken hata oluştu: $e');
      return null;
    }
  }

  // Generate dream interpretation
  Future<String?> generateDreamInterpretation({
    required UserModel user,
    required String dreamDescription,
  }) async {
    try {
      return await _aiService.generateDreamInterpretation(
        dreamDescription: dreamDescription,
        user: user,
      );
    } catch (e) {
      _setError('Rüya yorumu oluşturulurken hata oluştu: $e');
      return null;
    }
  }

  // Toggle fortune favorite status
  Future<void> toggleFortuneFavorite(String fortuneId, String userId) async {
    try {
      final fortuneIndex = _fortunes.indexWhere((f) => f.id == fortuneId);
      if (fortuneIndex != -1) {
        final fortune = _fortunes[fortuneIndex];
        final updatedFortune = fortune.copyWith(isFavorite: !fortune.isFavorite);
        
        await _firebaseService.updateFortune(userId, fortuneId, {
          'isFavorite': updatedFortune.isFavorite,
        });
        
        _fortunes[fortuneIndex] = updatedFortune;
        notifyListeners();
      }
    } catch (e) {
      _setError('Favori durumu güncellenirken hata oluştu: $e');
    }
  }

  // Rate fortune
  Future<void> rateFortune(String fortuneId, String userId, int rating) async {
    try {
      final fortuneIndex = _fortunes.indexWhere((f) => f.id == fortuneId);
      if (fortuneIndex != -1) {
        final fortune = _fortunes[fortuneIndex];
        final updatedFortune = fortune.copyWith(rating: rating);
        
        await _firebaseService.updateFortune(userId, fortuneId, {
          'rating': rating,
        });
        
        _fortunes[fortuneIndex] = updatedFortune;
        notifyListeners();
      }
    } catch (e) {
      _setError('Değerlendirme kaydedilirken hata oluştu: $e');
    }
  }

  // Delete fortune
  Future<void> deleteFortune(String fortuneId, String userId) async {
    try {
      await _firebaseService.deleteFortune(userId, fortuneId);
      _fortunes.removeWhere((f) => f.id == fortuneId);
      notifyListeners();
    } catch (e) {
      _setError('Fal silinirken hata oluştu: $e');
    }
  }

  // Set current fortune
  void setCurrentFortune(FortuneModel? fortune) {
    _currentFortune = fortune;
    notifyListeners();
  }

  // Get random tarot cards
  List<TarotCard> getRandomTarotCards(int count) {
    if (_tarotCards.isEmpty) return [];
    
    final shuffled = List<TarotCard>.from(_tarotCards)..shuffle();
    return shuffled.take(count).toList();
  }

  // Helper methods
  List<String> _getCardNamesByIds(List<String> cardIds) {
    return cardIds.map((id) {
      final card = _tarotCards.firstWhere(
        (card) => card.id == id,
        orElse: () => TarotCard(
          id: id,
          name: 'Bilinmeyen Kart',
          nameEn: 'Unknown Card',
          description: '',
          imageUrl: '',
          category: '',
          uprightMeaning: '',
          reversedMeaning: '',
        ),
      );
      return card.name;
    }).toList();
  }

  void _loadFallbackTarotCards() {
    // Add some basic tarot cards as fallback
    _tarotCards = [
      TarotCard(
        id: '1',
        name: 'Büyücü',
        nameEn: 'The Magician',
        description: 'Güç ve yaratıcılık kartı',
        imageUrl: 'assets/images/tarot/magician.png',
        category: 'major',
        uprightMeaning: 'Güç, beceri, konsantrasyon',
        reversedMeaning: 'Manipülasyon, zayıf irade',
      ),
      // Add more cards...
    ];
    notifyListeners();
  }

  void _loadFallbackFortuneTellers() {
    _fortuneTellers = [
      FortuneTeller(
        id: '1',
        name: 'Ayşe Hanım',
        description: 'Deneyimli tarot uzmanı',
        imageUrl: 'assets/images/fortune_tellers/ayse.png',
        specialties: [FortuneType.tarot, FortuneType.coffee],
        rating: 4.8,
        totalReadings: 1250,
      ),
      // Add more fortune tellers...
    ];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setGeneratingFortune(bool generating) {
    _isGeneratingFortune = generating;
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