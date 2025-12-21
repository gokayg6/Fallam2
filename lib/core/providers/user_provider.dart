import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../constants/pricing_constants.dart';

final _firestore = FirebaseFirestore.instance;

class UserProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  StreamSubscription<User?>? _authStateSubscription;

  // Getters
  UserModel? get currentUser => _currentUser;
  UserModel? get user => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _currentUser?.email.isEmpty ?? true;
  bool get isPremium => _currentUser?.isPremium ?? false;
  int get karma => _currentUser?.karma ?? 0;
  String get displayName => _currentUser?.name ?? 'Misafir';
  bool get socialVisible => _currentUser?.socialVisible ?? true;

  UserProvider() {
    _init();
  }

  void _init() {
    // Firebase Auth state changes'i dinle
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? user) async {
        if (user != null) {
          // Kullanıcı giriş yapmış veya değişmiş
          await _refreshUserProfile(user.uid);
        } else {
          // Kullanıcı çıkış yapmış
          _currentUser = null;
          _isAuthenticated = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _setError('Kimlik doğrulama hatası: $error');
      },
    );
  }

  // Initialize user provider (ilk yükleme için)
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Mevcut kullanıcıyı kontrol et
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _refreshUserProfile(currentUser.uid);
        // Premium kullanıcılar için haftalık ücretsiz eşleşme kontrolü
        await checkWeeklyAuraMatchReset();
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    } catch (e) {
      _setError('Kullanıcı bilgileri yüklenirken hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı profilini yenile (auth state değişikliğinde çağrılır)
  Future<void> _refreshUserProfile(String userId) async {
    try {
      await _touchLastLogin(userId);
      // Retry mekanizması: Firestore yazma işlemi tamamlanana kadar bekle
      await _loadUserProfileWithRetry(userId);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _setError('Kullanıcı bilgileri yüklenirken hata oluştu: $e');
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<void> updateSocialVisibility(bool visible) async {
    final user = _currentUser;
    if (user == null) return;
    try {
      await _firebaseService.updateUserProfile(user.id, {
        'socialVisible': visible,
        'age': user.age,
        'ageGroup': user.ageGroup,
      });
      _currentUser = user.copyWith(socialVisible: visible);
      notifyListeners();
    } catch (e) {
      _setError('Sosyal görünürlük güncellenemedi: $e');
    }
  }

  // Block user
  Future<bool> blockUser(String userId) async {
    if (_currentUser == null) return false;
    
    try {
      _setLoading(true);
      _clearError();
      
      final currentBlockedUsers = List<String>.from(_currentUser!.blockedUsers);
      if (!currentBlockedUsers.contains(userId)) {
        currentBlockedUsers.add(userId);
        await _firebaseService.updateUserProfile(_currentUser!.id, {
          'blockedUsers': currentBlockedUsers,
        });
        
        _currentUser = _currentUser!.copyWith(blockedUsers: currentBlockedUsers);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Kullanıcı engellenirken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId) async {
    if (_currentUser == null) return false;
    
    try {
      _setLoading(true);
      _clearError();
      
      final currentBlockedUsers = List<String>.from(_currentUser!.blockedUsers);
      if (currentBlockedUsers.contains(userId)) {
        currentBlockedUsers.remove(userId);
        await _firebaseService.updateUserProfile(_currentUser!.id, {
          'blockedUsers': currentBlockedUsers,
        });
        
        _currentUser = _currentUser!.copyWith(blockedUsers: currentBlockedUsers);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Kullanıcı engeli kaldırılırken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in anonymously (guest)
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userCredential = await _firebaseService.signInAnonymously();
      if (userCredential?.user != null) {
        // Create guest user profile
        await _createGuestProfile(userCredential!.user!.uid);
        await _touchLastLogin(userCredential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Misafir girişi yapılırken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final userCredential = await _firebaseService.signInWithEmail(email, password);
      if (userCredential?.user != null) {
        await _touchLastLogin(userCredential!.user!.uid);
        await _loadUserProfile(userCredential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Giriş yapılırken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    
    try {
      final userCredential = await _firebaseService.signUpWithEmail(email, password);
      if (userCredential?.user != null) {
        // Create user profile
        await _createUserProfile(userCredential!.user!.uid, name, email);
        await _touchLastLogin(userCredential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Kayıt olurken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _firebaseService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners(); // AuthGate'in güncellenmesi için
    } catch (e) {
      _setError('Çıkış yapılırken hata oluştu: $e');
    } finally {
      _setLoading(false);
      notifyListeners(); // Loading state güncellemesi için
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    DateTime? birthDate,
    String? gender,
    String? relationshipStatus,
    String? job,
    String? zodiacSign,
    String? birthPlace,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      // copyWith içinde ageGroup otomatik hesaplanacak
      final updatedUser = _currentUser!.copyWith(
        name: name,
        birthDate: birthDate,
        gender: gender,
        relationshipStatus: relationshipStatus,
        job: job,
        zodiacSign: zodiacSign,
        birthPlace: birthPlace,
      );
      
      // toFirestore() içinde age ve ageGroup hesaplanacak
      final firestoreData = updatedUser.toFirestore();
      
      await _firebaseService.updateUserProfile(_currentUser!.id, firestoreData);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Profil güncellenirken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update karma
  Future<bool> updateKarma(int amount, String reason) async {
    if (_currentUser == null) {
      return false;
    }
    
    try {
      await _firebaseService.updateKarma(_currentUser!.id, amount, reason);
      _currentUser = _currentUser!.copyWith(karma: _currentUser!.karma + amount);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Karma güncellenirken hata oluştu: $e');
      return false;
    }
  }

  // Add karma (positive amount)
  Future<bool> addKarma(int amount, String reason) async {
    return await updateKarma(amount.abs(), reason);
  }

  // Spend karma (negative amount)
  Future<bool> spendKarma(int amount, String reason) async {
    // NOT: Debug modunda bile karma kesilmeli, bypass yok
    // Sadece gerçek premium kullanıcılar için özel durumlar olabilir (şimdilik yok)
    
    if (_currentUser == null) {
      _setError('Yetersiz karma puanı');
      return false;
    }
    
    if (_currentUser!.karma < amount) {
      _setError('Yetersiz karma puanı');
      return false;
    }
    
    return await updateKarma(-amount.abs(), reason);
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final userId = _currentUser!.id;
      final currentAuthUser = FirebaseAuth.instance.currentUser;

      // Delete IP address records for this user
      await _firebaseService.unregisterIPAddressForUser(userId);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete user from Firebase Auth
      if (currentAuthUser != null) {
        await currentAuthUser.delete();
      }

      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Hesap silinirken hata oluştu: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check daily login and reward
  Future<void> checkDailyLogin() async {
    if (_currentUser == null) return;
    
    try {
      // İlk gün kontrolü: Kullanıcı bugün kayıt olduysa günlük giriş bonusu verme
      final now = DateTime.now();
      final createdAt = _currentUser!.createdAt;
      final daysSinceCreation = now.difference(createdAt).inDays;
      
      // İlk gün (0. gün) ise bonus verme
      if (daysSinceCreation == 0) {
        return;
      }
      
      final hasLoggedToday = await _firebaseService.checkDailyLogin(_currentUser!.id);
      if (!hasLoggedToday) {
        await _firebaseService.recordDailyLogin(_currentUser!.id);
        
        // Streak sistemini kullan
        final currentStreak = await _firebaseService.getLoginStreak(_currentUser!.id);
        final newStreak = currentStreak + 1;
        await _firebaseService.updateLoginStreak(_currentUser!.id, newStreak);
        
        // Streak'e göre ödül al
        final reward = PricingConstants.getDailyLoginReward(newStreak);
        if (reward != null) {
          final karmaAmount = reward['karma'] as int;
          final reason = 'Günlük giriş ödülü (Gün $newStreak)';
        await addKarma(karmaAmount, reason);
        }
      }
    } catch (e) {
      // Daily login check error - silent fail
    }
  }

  // Update daily fortunes used
  Future<void> incrementDailyFortunes() async {
    if (_currentUser == null) return;
    
    try {
      final updatedUser = _currentUser!.copyWith(
        dailyFortunesUsed: _currentUser!.dailyFortunesUsed + 1,
      );
      
      await _firebaseService.updateUserProfile(_currentUser!.id, {
        'dailyFortunesUsed': updatedUser.dailyFortunesUsed,
      });
      
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      // Error incrementing daily fortunes - silent fail
    }
  }

  // Reset daily fortunes (called daily)
  Future<void> resetDailyFortunes() async {
    if (_currentUser == null) return;
    
    try {
      await _firebaseService.updateUserProfile(_currentUser!.id, {
        'dailyFortunesUsed': 0,
      });
      
      _currentUser = _currentUser!.copyWith(dailyFortunesUsed: 0);
      notifyListeners();
    } catch (e) {
      // Error resetting daily fortunes - silent fail
    }
  }

  // Add favorite fortune type
  Future<void> addFavoriteFortuneType(String fortuneType) async {
    if (_currentUser == null) return;
    
    try {
      final favorites = List<String>.from(_currentUser!.favoriteFortuneTypes);
      if (!favorites.contains(fortuneType)) {
        favorites.add(fortuneType);
        
        await _firebaseService.updateUserProfile(_currentUser!.id, {
          'favoriteFortuneTypes': favorites,
        });
        
        _currentUser = _currentUser!.copyWith(favoriteFortuneTypes: favorites);
        notifyListeners();
      }
    } catch (e) {
      // Error adding favorite fortune type - silent fail
    }
  }

  // Update user preferences
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      await _firebaseService.updateUserProfile(_currentUser!.id, {
        'preferences': preferences,
      });
      
      _currentUser = _currentUser!.copyWith(preferences: preferences);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ayarlar güncellenirken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upgrade to premium
  Future<bool> upgradeToPremium() async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      // İlk premium alındığında 5 ücretsiz eşleşme ver
      final wasPremium = _currentUser!.isPremium;
      final newFreeMatches = wasPremium 
          ? _currentUser!.freeAuraMatches 
          : PricingConstants.premiumFreeAuraMatchesOnUpgrade;
      
      await _firebaseService.updateUserProfile(_currentUser!.id, {
        'isPremium': true,
        'premiumUpgradeDate': FieldValue.serverTimestamp(),
        'freeAuraMatches': newFreeMatches,
      });
      
      // Premium alındığında 25 karma ver
      await addKarma(PricingConstants.premiumDailyKarma, 'Premium satın alma bonusu');
      
      _currentUser = _currentUser!.copyWith(
        isPremium: true,
        freeAuraMatches: newFreeMatches,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Premium üyelik güncellenirken hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check and reset weekly free aura matches for premium users
  Future<void> checkWeeklyAuraMatchReset() async {
    if (_currentUser == null || !_currentUser!.isPremium) return;
    
    try {
      final now = DateTime.now();
      final lastReset = _currentUser!.lastWeeklyAuraMatchReset;
      
      // Eğer hiç reset yapılmamışsa veya son reset'ten 7 gün geçmişse
      if (lastReset == null || now.difference(lastReset).inDays >= 7) {
        await _firebaseService.updateUserProfile(_currentUser!.id, {
          'freeAuraMatches': PricingConstants.premiumWeeklyFreeAuraMatches,
          'lastWeeklyAuraMatchReset': FieldValue.serverTimestamp(),
        });
        
        _currentUser = _currentUser!.copyWith(
          freeAuraMatches: PricingConstants.premiumWeeklyFreeAuraMatches,
          lastWeeklyAuraMatchReset: now,
        );
        notifyListeners();
      }
    } catch (e) {
      // Error resetting weekly aura matches - silent fail
    }
  }

  // Use free aura match
  Future<bool> useFreeAuraMatch() async {
    if (_currentUser == null) return false;
    
    // Önce güncel kullanıcı bilgilerini yeniden yükle
    await _refreshUserProfile(_currentUser!.id);
    
    // Güncel durumu kontrol et
    if (_currentUser == null) return false;
    if (_currentUser!.freeAuraMatches <= 0) {
      _setError('Ücretsiz eşleşme hakkınız kalmadı');
      return false;
    }
    
    try {
      final newCount = _currentUser!.freeAuraMatches - 1;
      await _firebaseService.updateUserProfile(_currentUser!.id, {
        'freeAuraMatches': newCount,
      });
      
      _currentUser = _currentUser!.copyWith(freeAuraMatches: newCount);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ücretsiz eşleşme kullanılırken hata oluştu: $e');
      return false;
    }
  }

  // Private methods
  Future<void> _touchLastLogin(String userId) async {
    try {
      await _firebaseService.updateUserProfile(userId, {
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Error updating lastLoginAt - silent fail
    }
  }
  Future<void> _loadUserProfile(String userId) async {
    try {
      final userDoc = await _firebaseService.getUserProfile(userId);
      if (userDoc != null) {
        _currentUser = UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      // Error loading user profile - silent fail
    }
  }

  // Load user profile with retry mechanism (for registration race condition)
  Future<void> _loadUserProfileWithRetry(String userId, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final userDoc = await _firebaseService.getUserProfile(userId);
        if (userDoc != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          // Eğer birthDate, zodiacSign, gender eksikse ve ilk retry değilse, bekle ve tekrar dene
          if (i < maxRetries - 1 && 
              (data['birthDate'] == null || data['zodiacSign'] == null || data['gender'] == null)) {
            // Kayıt işlemi henüz tamamlanmamış, bekle ve tekrar dene
            await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
            continue;
          }
          _currentUser = UserModel.fromFirestore(userDoc);
          return;
        }
      } catch (e) {
        if (i < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
          continue;
        }
        // Son retry'da hata varsa, sessizce başarısız ol
      }
    }
  }

  Future<void> _createGuestProfile(String userId) async {
    try {
      final guestUser = UserModel(
        id: userId,
        name: 'Misafir',
        email: '',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        karma: 10, // Yeni kayıt bonusu (misafir için de 10 karma)
        ageGroup: 'adult',
      );
      
      await _firebaseService.createUserProfile(userId, guestUser.toFirestore());
      _currentUser = guestUser;
    } catch (e) {
      // Error creating guest profile - silent fail
    }
  }

  Future<void> _createUserProfile(String userId, String name, String email) async {
    try {
      final newUser = UserModel(
        id: userId,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        karma: 10, // Yeni kayıt bonusu
        ageGroup: 'adult',
      );
      
      await _firebaseService.createUserProfile(userId, newUser.toFirestore());
      _currentUser = newUser;
    } catch (e) {
      // Error creating user profile - silent fail
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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
    _authStateSubscription?.cancel();
    super.dispose();
  }
}