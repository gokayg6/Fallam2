import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/love_candidate_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Sign out error - silent fail
    }
  }

  // User Profile Methods
  Future<void> createUserProfile(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).set(userData);
    } catch (e) {
      // Create user profile error - silent fail
    }
  }

  Future<DocumentSnapshot?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      // Fallback: doc yoksa merge ile oluştur
      try {
        await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
      } catch (e2) {
        // Update user profile error - silent fail
      }
    }
  }

  Stream<UserModel?> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  // Karma Methods
  Future<void> updateKarma(String userId, int amount, String reason) async {
    try {
      // Use transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('Kullanıcı bulunamadı');
        }
        
        final currentKarma = (userDoc.data()?['karma'] as int?) ?? 0;
        final newKarma = currentKarma + amount;
        
        // Check if karma would go negative (for spending)
        if (newKarma < 0) {
          throw Exception('Yetersiz karma puanı');
        }
        
        transaction.update(userRef, {
          'karma': newKarma,
          'lastKarmaUpdate': FieldValue.serverTimestamp(),
        });
      });
      
      // Add karma transaction record (after successful update)
      await addKarmaTransaction(userId, amount, reason);
    } catch (e) {
      rethrow; // Re-throw to let caller handle the error
    }
  }

  Future<void> addKarmaTransaction(String userId, int amount, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).collection('karma_transactions').add({
        'amount': amount,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Add karma transaction error - silent fail
    }
  }

  // Fortune Methods
  Future<String?> saveFortune(String userId, Map<String, dynamic> fortuneData) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('fortunes')
          .add(fortuneData);
      return docRef.id;
    } catch (e) {
      // Save fortune error - silent fail
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getUserFortunes(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('fortunes')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      // Get user fortunes error - silent fail
      return [];
    }
  }

  Future<DocumentSnapshot?> getFortune(String userId, String fortuneId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('fortunes')
          .doc(fortuneId)
          .get();
      return doc.exists ? doc : null;
    } catch (e) {
      // Get fortune error - silent fail
      return null;
    }
  }

  Future<void> updateFortune(String userId, String fortuneId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fortunes')
          .doc(fortuneId)
          .update(data);
    } catch (e) {
      // Update fortune error - silent fail
    }
  }

  Future<void> deleteFortune(String userId, String fortuneId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fortunes')
          .doc(fortuneId)
          .delete();
    } catch (e) {
      // Delete fortune error - silent fail
    }
  }

  // Storage Methods
  Future<String?> uploadImage(String path, List<int> imageBytes) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      final uploadTask = ref.putData(Uint8List.fromList(imageBytes), metadata);
      final snapshot = await uploadTask;
      
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed: ${snapshot.state}');
      }
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // Re-throw with better error message
      throw Exception('Resim yüklenemedi: ${e.toString()}');
    }
  }

  // Dream Draw Methods
  Future<String?> saveDreamDraw(String userId, Map<String, dynamic> data) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).collection('dream_draws').add(data);
      return doc.id;
    } catch (e) {
      // Save dream draw error - silent fail
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getDreamDraws(String userId) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dream_draws')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs;
    } catch (e) {
      // Get dream draws error - silent fail
      return [];
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Delete image error - silent fail
    }
  }

  // Analytics Methods
  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      // Firebase Analytics event logging will be implemented here
      // Event logged - silent
    } catch (e) {
      // Log event error - silent fail
    }
  }

  // Spins (Kader Çarkı)
  Future<DocumentSnapshot<Map<String, dynamic>>?> getSpinDoc(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spins')
          .doc('state')
          .get();
      return doc;
    } catch (e) {
      // Get spin doc error - silent fail
      return null;
    }
  }

  Future<bool> canSpin(String userId, {Duration cooldown = const Duration(hours: 24)}) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spins')
          .doc('state')
          .get();
      if (!doc.exists) return true;
      final data = doc.data();
      if (data == null || data['lastSpinAt'] == null) return true;
      final Timestamp ts = data['lastSpinAt'] as Timestamp;
      final last = ts.toDate();
      return DateTime.now().difference(last) >= cooldown;
    } catch (e) {
      // Can spin check error - silent fail
      return false;
    }
  }

  // Check if user can do an extra spin via ad
  // User must have used free spin today and not used ad spin today
  Future<bool> canSpinWithAd(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spins')
          .doc('state')
          .get();
      
      if (!doc.exists) return false; // Can't use ad spin if never spun before
      
      final data = doc.data();
      if (data == null) return false;
      
      // Check if user has used free spin today (required for ad spin)
      final lastSpinAt = data['lastSpinAt'] as Timestamp?;
      if (lastSpinAt == null) return false; // Must use free spin first
      
      final lastSpinDate = lastSpinAt.toDate();
      if (lastSpinDate.isBefore(startOfDay)) return false; // Free spin not used today
      
      // Check if user has used ad spin today
      final adSpinAt = data['adSpinAt'] as Timestamp?;
      if (adSpinAt == null) return true; // Ad spin not used, can use it
      
      final adSpinDate = adSpinAt.toDate();
      return adSpinDate.isBefore(startOfDay); // Can use if last ad spin was before today
    } catch (e) {
      // Can spin with ad check error - silent fail
      return false;
    }
  }

  // Check if user can use 2x reward feature
  Future<bool> canUse2xReward(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spins')
          .doc('state')
          .get();
      
      if (!doc.exists) return true;
      
      final data = doc.data();
      if (data == null) return true;
      
      final used2xAt = data['used2xRewardAt'] as Timestamp?;
      if (used2xAt == null) return true;
      
      final used2xDate = used2xAt.toDate();
      return used2xDate.isBefore(startOfDay);
    } catch (e) {
      // Can use 2x reward check error - silent fail
      return false;
    }
  }

  Future<void> recordSpin(String userId, Map<String, dynamic> reward, {bool isAdSpin = false, bool doubledReward = false}) async {
    try {
      final updateData = <String, dynamic>{
        'userId': userId,
        'lastReward': reward,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Only update lastSpinAt for free spins (not ad spins)
      if (!isAdSpin) {
        updateData['lastSpinAt'] = FieldValue.serverTimestamp();
      }
      
      if (isAdSpin) {
        updateData['adSpinAt'] = FieldValue.serverTimestamp();
      }
      
      if (doubledReward) {
        updateData['used2xRewardAt'] = FieldValue.serverTimestamp();
      }
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('spins')
          .doc('state')
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      // Record spin error - silent fail
    }
  }

  // Daily Check Methods
  Future<bool> checkDailyLogin(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_activities')
          .doc(todayString)
          .get();
      
      return doc.exists;
    } catch (e) {
      // Check daily login error - silent fail
      return false;
    }
  }

  Future<void> recordDailyLogin(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_activities')
          .doc(todayString)
          .set({
        'login': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Record daily login error - silent fail
    }
  }

  // Get login streak (consecutive days)
  Future<int> getLoginStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;
      
      final data = userDoc.data();
      final lastLoginDate = data?['lastLoginDate'] as Timestamp?;
      final currentStreak = data?['loginStreak'] as int? ?? 0;
      
      if (lastLoginDate == null) return 0;
      
      final lastLogin = lastLoginDate.toDate();
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      
      // Check if last login was today or yesterday
      final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      final todayDay = DateTime(today.year, today.month, today.day);
      final yesterdayDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
      
      if (lastLoginDay == todayDay) {
        // Already logged in today
        return currentStreak;
      } else if (lastLoginDay == yesterdayDay) {
        // Continuing streak
        return currentStreak + 1;
      } else {
        // Streak broken, reset to 1
        return 1;
      }
    } catch (e) {
      return 0;
    }
  }

  // Update login streak
  Future<void> updateLoginStreak(String userId, int streak) async {
    try {
      final today = DateTime.now();
      await _firestore.collection('users').doc(userId).update({
        'loginStreak': streak,
        'lastLoginDate': Timestamp.fromDate(today),
      });
    } catch (e) {
      // Update streak error - silent fail
    }
  }

  // Quest/Task tracking methods
  Future<void> recordQuestCompletion(String userId, String questType) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_activities')
          .doc(todayString)
          .set({
        'quests': FieldValue.arrayUnion([questType]),
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Record quest error - silent fail
    }
  }

  Future<List<String>> getCompletedQuests(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_activities')
          .doc(todayString)
          .get();
      
      if (!doc.exists) return [];
      final data = doc.data();
      final quests = data?['quests'] as List<dynamic>?;
      return quests?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  // Love Candidates Methods
  Future<String> createLoveCandidate(String userId, Map<String, dynamic> candidateData) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('love_candidates')
          .add({
        ...candidateData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LoveCandidateModel>> getLoveCandidates(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('love_candidates')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => LoveCandidateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateLoveCandidate(String userId, String candidateId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('love_candidates')
          .doc(candidateId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLoveCandidate(String userId, String candidateId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('love_candidates')
          .doc(candidateId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveCompatibilityResult(
    String userId,
    String candidateId,
    Map<String, dynamic> result,
  ) async {
    try {
      // Safely convert overallScore to double
      final overallScore = result['overallScore'];
      double scoreValue = 0.0;
      if (overallScore != null) {
        if (overallScore is double) {
          scoreValue = overallScore;
        } else if (overallScore is int) {
          scoreValue = overallScore.toDouble();
        } else if (overallScore is num) {
          scoreValue = overallScore.toDouble();
        } else {
          scoreValue = double.tryParse(overallScore.toString()) ?? 0.0;
        }
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('love_candidates')
          .doc(candidateId)
          .update({
        'lastCompatibilityCheck': FieldValue.serverTimestamp(),
        'lastCompatibilityScore': scoreValue,
        'lastCompatibilityResult': result,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Test Methods
  Future<String?> saveTest(String userId, Map<String, dynamic> testData) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tests')
          .add(testData);
      return docRef.id;
    } catch (e) {
      // Save test error - silent fail
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getUserTests(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tests')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      // Get user tests error - silent fail
      return [];
    }
  }

  Future<void> updateTest(String userId, String testId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tests')
          .doc(testId)
          .update(data);
    } catch (e) {
      // Update test error - silent fail
    }
  }

  Future<void> deleteTest(String userId, String testId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tests')
          .doc(testId)
          .delete();
    } catch (e) {
      // Delete test error - silent fail
    }
  }

  // Test Result Methods
  Future<String?> saveTestResult(String userId, Map<String, dynamic> resultData) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('test_results')
          .add(resultData);
      return docRef.id;
    } catch (e) {
      // Save test result error - silent fail
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getUserTestResults(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('test_results')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      // Get user test results error - silent fail
      return [];
    }
  }

  Future<void> updateTestResult(String userId, String resultId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('test_results')
          .doc(resultId)
          .update(data);
    } catch (e) {
      // Update test result error - silent fail
    }
  }

  // Quiz Test Result Methods
  Future<String?> saveQuizTestResult(String userId, Map<String, dynamic> resultData) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_test_results')
          .add(resultData);
      return docRef.id;
    } catch (e) {
      // Save quiz test result error - silent fail
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getUserQuizTestResults(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_test_results')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      // Get user quiz test results error - silent fail
      return [];
    }
  }

  // Tarot Cards Methods
  Future<List<DocumentSnapshot>> getTarotCards() async {
    try {
      final querySnapshot = await _firestore
          .collection('tarot_cards')
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      // Get tarot cards error - silent fail
      return [];
    }
  }

  // Fortune Tellers Methods
  Future<List<DocumentSnapshot>> getFortuneTellers() async {
    try {
      final querySnapshot = await _firestore
          .collection('fortune_tellers')
          .get();
      
      return querySnapshot.docs;
    } catch (e) {
      // Get fortune tellers error - silent fail
      return [];
    }
  }

  // User's fortunes from `readings` root collection (correct, production path)
  Future<List<DocumentSnapshot>> getUserFortunesFromReadings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('readings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      // Get user fortunes from readings error - silent fail
      return [];
    }
  }

  // IP Address Control Methods
  /// Check if an IP address has already been used for a specific account type
  /// accountType: 'guest' or 'registered'
  /// Returns true if IP is already used for this account type, false if available
  Future<bool> isIPAddressUsedForAccountType(String ipAddress, String accountType) async {
    try {
      final doc = await _firestore
          .collection('ip_addresses')
          .doc(ipAddress)
          .get();
      
      if (!doc.exists) {
        return false; // IP hiç kullanılmamış
      }
      
      final data = doc.data();
      final existingAccountType = data?['accountType'] as String?;
      
      // Eğer aynı tip hesap varsa, tekrar oluşturulamaz
      if (existingAccountType == accountType) {
        return true;
      }
      
      // Farklı tip hesap varsa, oluşturulabilir
      return false;
    } catch (e) {
      // Error checking IP address - silent fail
      // On error, allow registration to proceed (fail open for better UX)
      return false;
    }
  }

  /// Check if an IP address has already been used for any registration
  /// (Legacy method, kept for backward compatibility)
  Future<bool> isIPAddressUsed(String ipAddress) async {
    try {
      final doc = await _firestore
          .collection('ip_addresses')
          .doc(ipAddress)
          .get();
      return doc.exists;
    } catch (e) {
      // Error checking IP address - silent fail
      // On error, allow registration to proceed (fail open for better UX)
      return false;
    }
  }

  /// Register an IP address as used for a user registration
  /// accountType: 'guest' or 'registered'
  Future<void> registerIPAddress(String ipAddress, String userId, {String accountType = 'registered'}) async {
    try {
      await _firestore.collection('ip_addresses').doc(ipAddress).set({
        'userId': userId,
        'accountType': accountType, // 'guest' or 'registered'
        'registeredAt': FieldValue.serverTimestamp(),
        'ipAddress': ipAddress,
      }, SetOptions(merge: true));
    } catch (e) {
      // Error registering IP address - silent fail
      // Don't throw - IP registration failure shouldn't block user creation
    }
  }

  /// Unregister IP address for a user (called when account is deleted)
  Future<void> unregisterIPAddressForUser(String userId) async {
    try {
      // Find all IP address records for this user
      final querySnapshot = await _firestore
          .collection('ip_addresses')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete each IP address record
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // IP addresses unregistered for user
    } catch (e) {
      // Error unregistering IP address for user - silent fail
      // Don't throw - IP unregistration failure shouldn't block account deletion
    }
  }
}