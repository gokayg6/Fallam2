import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/ip_service.dart';
import '../core/services/firebase_service.dart';
import '../core/utils/helpers.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IPService _ipService = IPService();
  final FirebaseService _firebaseService = FirebaseService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Firebase Auth persistence'ı ayarla
    _auth.setPersistence(Persistence.LOCAL);
    
    // Auth state changes'i dinle
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      
      if (user != null) {
       
        // Kullanıcı giriş yapmış, Firestore profilini kontrol et
        await _ensureUserProfile();
      } else {
       
      }
      
      notifyListeners();
    });
  }

  // Loading state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error state management
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = result.user;
      print('Login successful: ${_user?.email}');
      
      if (_user != null) {
        // Check if user exists in Firestore, if not create profile
        await _ensureUserProfile();
        notifyListeners();
        print('User state updated, notifying listeners');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
    DateTime birthDate,
    String zodiacSign,
    String gender,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      // Check IP address before registration
      final ipAddress = await _ipService.getPublicIP();
      if (ipAddress != null) {
        final isIPUsed = await _firebaseService.isIPAddressUsedForAccountType(ipAddress, 'registered');
        if (isIPUsed) {
          _setError('Bu IP adresinden zaten bir kayıtlı hesap oluşturulmuş. Her IP adresi için sadece bir kayıtlı hesap oluşturulabilir.');
          return false;
        }
      } else {
        // If we can't get IP, warn but allow (fail open for better UX)
        print('Warning: Could not retrieve IP address, proceeding with registration');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = result.user;
      
      if (_user != null) {
        // Update display name
        await _user!.updateDisplayName(displayName);
        
        // Register IP address
        if (ipAddress != null) {
          await _firebaseService.registerIPAddress(ipAddress, _user!.uid, accountType: 'registered');
        }
        
        // Create user profile in Firestore FIRST (before authStateChanges listener triggers)
        // This ensures birthDate, zodiacSign, gender are saved before _ensureUserProfile runs
        await _createUserProfile(displayName, birthDate, zodiacSign, gender);
        
        // Small delay to ensure Firestore write completes before listener triggers
        await Future.delayed(const Duration(milliseconds: 100));
        
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in anonymously (Guest)
  Future<bool> signInAnonymously({DateTime? birthDate}) async {
    try {
      _setLoading(true);
      _setError(null);

      // Check IP address before anonymous sign in
      final ipAddress = await _ipService.getPublicIP();
      if (ipAddress != null) {
        final isIPUsed = await _firebaseService.isIPAddressUsedForAccountType(ipAddress, 'guest');
        if (isIPUsed) {
          _setError('Bu IP adresinden zaten bir misafir hesabı oluşturulmuş. Her IP adresi için sadece bir misafir hesabı oluşturulabilir.');
          return false;
        }
      } else {
        // If we can't get IP, warn but allow (fail open for better UX)
        print('Warning: Could not retrieve IP address, proceeding with guest login');
      }

      final UserCredential result = await _auth.signInAnonymously();
      _user = result.user;
      
      if (_user != null) {
        // Register IP address
        if (ipAddress != null) {
          await _firebaseService.registerIPAddress(ipAddress, _user!.uid, accountType: 'guest');
        }
        
        // Create guest user profile (optional birthDate for better personalization)
        await _createGuestProfile(birthDate: birthDate);
        notifyListeners();
        print('Guest login successful: ${_user?.uid}');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Misafir girişi başarısız: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Çıkış yapılırken hata oluştu: ${e.toString()}');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔄 Şifre sıfırlama başlatılıyor: $email');
      
      // Email formatını kontrol et
      if (!email.contains('@') || !email.contains('.')) {
        _setError('📮 Geçersiz e-posta adresi.\nLütfen doğru formatta bir e-posta girin (örn: ornek@email.com)');
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ Şifre sıfırlama e-postası gönderildi: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      print('❌ Genel Hata: ${e.toString()}');
      _setError('Şifre sıfırlama hatası: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (_user == null) return false;

      _setLoading(true);
      _setError(null);

      if (displayName != null) {
        await _user!.updateDisplayName(displayName);
      }
      
      if (photoURL != null) {
        await _user!.updatePhotoURL(photoURL);
      }

      // Update in Firestore
      await _firestore.collection('users').doc(_user!.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Profil güncellenirken hata oluştu: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Ensure user profile exists in Firestore
  Future<void> _ensureUserProfile() async {
    if (_user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      
      if (!userDoc.exists) {
        // Create basic user profile for existing auth user
        // Sadece eğer document yoksa oluştur (kayıt sırasında _createUserProfile zaten oluşturacak)
        await _createBasicUserProfile();
      } else {
        final data = userDoc.data() ?? {};
        final currentName = (data['name'] ?? '').toString();
        final displayName = (_user!.displayName ?? '').trim();
        final Map<String, dynamic> updates = {
          'lastLoginAt': FieldValue.serverTimestamp(),
        };
        // If Firestore name is placeholder or empty but auth has a displayName, fix it
        if ((currentName.isEmpty || currentName.toLowerCase() == 'kullanıcı') && displayName.isNotEmpty) {
          updates['name'] = displayName;
        }
        // Eğer birthDate, zodiacSign, gender eksikse ve auth'ta varsa, ekle
        // (kayıt sırasında _createUserProfile çağrılmışsa zaten var, ama emin olmak için)
        if (data['birthDate'] == null || data['zodiacSign'] == null || data['gender'] == null) {
          // Bu alanlar eksik, ama _createUserProfile zaten çağrılmış olmalı
          // Bu durumda sadece lastLoginAt güncelle
        }
        if (updates.isNotEmpty) {
          await _firestore.collection('users').doc(_user!.uid).set(updates, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
    }
  }

  // Create basic user profile for existing auth user
  Future<void> _createBasicUserProfile() async {
    if (_user == null) return;

    final userData = {
      'id': _user!.uid,
      'name': (_user!.displayName ?? _user!.email?.split('@').first ?? 'Kullanıcı'),
      'email': _user!.email ?? '',
      'karma': 10, // Yeni kayıt bonusu
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'dailyFortunesUsed': 0,
      'favoriteFortuneTypes': [],
      'totalFortunes': 0,
      'totalTests': 0,
      'preferences': {
        'notifications': true,
        'sound': true,
        'vibration': true,
        'language': 'tr',
        'theme': 'mystical',
        'autoSaveFortunes': true,
        'showKarmaNotifications': true,
        'premiumNotifications': false,
      },
    };

    // Merge kullanarak mevcut verileri koru (birthDate, zodiacSign, gender gibi)
    await _firestore.collection('users').doc(_user!.uid).set(userData, SetOptions(merge: true));
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(
    String displayName, 
    DateTime birthDate, 
    String zodiacSign,
    String gender,
  ) async {
    if (_user == null) return;

    // Calculate age and ageGroup from birthDate
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    final ageGroup = age < 18 ? 'under18' : 'adult';

    final userData = {
      'id': _user!.uid,
      'name': displayName,
      'email': _user!.email ?? '',
      'birthDate': Timestamp.fromDate(birthDate),
      'zodiacSign': zodiacSign,
      'gender': gender,
      'age': age,
      'ageGroup': ageGroup,
      'karma': 10, // Yeni kayıt bonusu
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'dailyFortunesUsed': 0,
      'favoriteFortuneTypes': [],
      'totalFortunes': 0,
      'totalTests': 0,
      'socialVisible': true,
      'blockedUsers': [],
      'preferences': {
        'notifications': true,
        'sound': true,
        'vibration': true,
        'language': 'tr',
        'theme': 'mystical',
        'autoSaveFortunes': true,
        'showKarmaNotifications': true,
        'premiumNotifications': false,
      },
    };

    // Use set with merge to ensure all fields are saved, even if document already exists
    await _firestore.collection('users').doc(_user!.uid).set(userData, SetOptions(merge: true));
  }

  // Create guest profile
  Future<void> _createGuestProfile({DateTime? birthDate}) async {
    if (_user == null) return;

    final guestData = {
      'id': _user!.uid,
      'name': 'Misafir',
      'email': '',
      'karma': 10, // Yeni kayıt bonusu (misafir için de 10 karma)
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'dailyFortunesUsed': 0,
      'favoriteFortuneTypes': [],
      'totalFortunes': 0,
      'totalTests': 0,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
      if (birthDate != null) 'zodiacSign': Helpers.calculateZodiacSign(birthDate),
      'preferences': {
        'notifications': true,
        'sound': true,
        'vibration': true,
        'language': 'tr',
        'theme': 'mystical',
        'autoSaveFortunes': true,
        'showKarmaNotifications': true,
        'premiumNotifications': false,
      },
    };

    await _firestore.collection('users').doc(_user!.uid).set(guestData);
    print('Guest profile created for: ${_user!.uid}');
  }


  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.data();
    } catch (e) {
      _setError('Profil bilgileri alınırken hata oluştu: ${e.toString()}');
      return null;
    }
  }

  // Check if user is premium
  Future<bool> isPremium() async {
    final profile = await getUserProfile();
    return profile?['premium'] ?? false;
  }

  // Get user karma
  Future<int> getUserKarma() async {
    final profile = await getUserProfile();
    return profile?['karma'] ?? 0;
  }

  // Add karma to user
  Future<bool> addKarma(int amount) async {
    if (_user == null) return false;

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'karma': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _setError('Karma eklenirken hata oluştu: ${e.toString()}');
      return false;
    }
  }

  // Firebase Auth error messages - Güzel ve anlaşılabilir Türkçe mesajlar
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '🔍 Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.\nLütfen e-posta adresinizi kontrol edin veya kayıt olun.';
      case 'wrong-password':
        return '🔐 Hatalı şifre girdiniz.\nŞifrenizi kontrol edip tekrar deneyin.';
      case 'email-already-in-use':
        return '📧 Bu e-posta adresi zaten kullanımda.\nGiriş yapmayı deneyin veya farklı bir e-posta kullanın.';
      case 'weak-password':
        return '🛡️ Şifre çok zayıf.\nEn az 6 karakter, büyük harf ve rakam içermelidir.';
      case 'invalid-email':
        return '📮 Geçersiz e-posta adresi.\nLütfen doğru formatta bir e-posta girin (örn: ornek@email.com)';
      case 'user-disabled':
        return '🚫 Bu hesap devre dışı bırakılmış.\nLütfen destek ekibi ile iletişime geçin.';
      case 'too-many-requests':
        return '⏰ Çok fazla deneme yapıldı.\nGüvenlik nedeniyle 15 dakika bekleyin.';
      case 'operation-not-allowed':
        return '🔒 Bu işlem şu anda izin verilmiyor.\nLütfen daha sonra tekrar deneyin.';
      case 'network-request-failed':
        return '🌐 İnternet bağlantınızı kontrol edin.\nWi-Fi veya mobil veri bağlantınızı kontrol edin.';
      case 'invalid-credential':
        return '❌ Geçersiz kimlik bilgileri.\nE-posta ve şifrenizi kontrol edin.';
      case 'user-mismatch':
        return '👤 Kullanıcı uyumsuzluğu.\nLütfen doğru hesap bilgileri ile giriş yapın.';
      case 'requires-recent-login':
        return '🔑 Güvenlik için tekrar giriş yapın.\nHesabınızı güncellemek için tekrar giriş yapmanız gerekiyor.';
      case 'account-exists-with-different-credential':
        return '🔄 Bu e-posta farklı bir yöntemle kayıtlı.\nLütfen doğru giriş yöntemini kullanın.';
      default:
        return '⚠️ Kimlik doğrulama hatası oluştu.\nLütfen bilgilerinizi kontrol edip tekrar deneyin.';
    }
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      // Delete IP address records for this user
      await _firebaseService.unregisterIPAddressForUser(_user!.uid);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(_user!.uid).delete();
      
      // Delete user from Firebase Auth
      await _user!.delete();
      
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Hesap silinirken hata oluştu: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Re-authenticate user (for sensitive operations)
  Future<bool> reAuthenticate(String password) async {
    if (_user == null || _user!.email == null) return false;

    try {
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );
      
      await _user!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      _setError('Kimlik doğrulama başarısız: ${e.toString()}');
      return false;
    }
  }
}
