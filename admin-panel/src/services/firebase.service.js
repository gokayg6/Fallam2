/**
 * Firebase Service - Admin Panel (Web)
 * 
 * Tüm Firebase işlemleri için merkezi servis
 */

import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
} from 'firebase/auth';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  updateDoc,
  deleteDoc,
  runTransaction,
  serverTimestamp,
  increment,
  addDoc,
  setDoc,
  collectionGroup,
  Timestamp,
} from 'firebase/firestore';
import { auth, db } from '../config/firebase.config';
import { COLLECTIONS, SUBCOLLECTIONS } from '../config/firebase.config';

class FirebaseService {
  // ==================== AUTH ====================

  /**
   * İlk kayıt olan kullanıcıyı otomatik admin yap
   */
  async createAdminUser(email, password) {
    try {
      // Kullanıcı oluştur
      const userCredential = await createUserWithEmailAndPassword(
        auth,
        email,
        password,
      );
      
      // Admins collection'ını kontrol et
      const adminsSnapshot = await getDocs(collection(db, COLLECTIONS.ADMINS));
      const isFirstAdmin = adminsSnapshot.empty;
      
      // Otomatik olarak admin yap
      await setDoc(
        doc(db, COLLECTIONS.ADMINS, userCredential.user.uid),
        {
          isAdmin: true,
          email: userCredential.user.email || email,
          createdAt: serverTimestamp(),
          isFirstAdmin: isFirstAdmin,
        },
      );
      
      console.log('Kullanıcı oluşturuldu ve otomatik admin yapıldı:', email);
      return userCredential.user;
    } catch (error) {
      console.error('Create admin user error:', error);
      throw error;
    }
  }

  /**
   * Admin girişi
   * İlk giriş yapan kullanıcıyı otomatik olarak admin yapar
   */
  async signInAdmin(email, password) {
    try {
      const userCredential = await signInWithEmailAndPassword(
        auth,
        email,
        password,
      );
      
      // Admins collection'ını kontrol et
      const adminsSnapshot = await getDocs(collection(db, COLLECTIONS.ADMINS));
      const isFirstAdmin = adminsSnapshot.empty;
      
      // Kullanıcının admin dokümanını kontrol et
      const adminDoc = await getDoc(
        doc(db, COLLECTIONS.ADMINS, userCredential.user.uid),
      );

      // Eğer ilk admin ise veya admin dokümanı yoksa, otomatik olarak admin yap
      if (isFirstAdmin || !adminDoc.exists()) {
        await setDoc(
          doc(db, COLLECTIONS.ADMINS, userCredential.user.uid),
          {
            isAdmin: true,
            email: userCredential.user.email || email,
            createdAt: serverTimestamp(),
            isFirstAdmin: isFirstAdmin,
          },
        );
        console.log('Kullanıcı otomatik olarak admin yapıldı:', email);
        return userCredential.user;
      }

      // Mevcut admin kontrolü
      if (!adminDoc.data().isAdmin) {
        await signOut(auth);
        throw new Error('Yetkisiz erişim');
      }

      return userCredential.user;
    } catch (error) {
      // Eğer kullanıcı bulunamadıysa, kayıt olmayı öner
      if (error.code === 'auth/invalid-credential' || error.code === 'auth/user-not-found') {
        throw new Error('Kullanıcı bulunamadı. İlk giriş için "Kayıt Ol" butonunu kullanın.');
      }
      console.error('Admin sign in error:', error);
      throw error;
    }
  }

  /**
   * Çıkış yap
   */
  async signOut() {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Sign out error:', error);
      throw error;
    }
  }

  /**
   * Mevcut kullanıcıyı al
   */
  getCurrentUser() {
    return auth.currentUser;
  }

  /**
   * Auth state değişikliklerini dinle
   */
  onAuthStateChanged(callback) {
    return onAuthStateChanged(auth, callback);
  }

  // ==================== USERS ====================

  /**
   * Tüm kullanıcıları getir
   */
  async getAllUsers(limitCount = 50, lastDoc = null) {
    try {
      let q = query(
        collection(db, COLLECTIONS.USERS),
        orderBy('createdAt', 'desc'),
        limit(limitCount),
      );

      if (lastDoc) {
        q = query(q, startAfter(lastDoc));
      }

      try {
        const snapshot = await getDocs(q);
        return snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        }));
      } catch (orderByError) {
        // OrderBy başarısız olursa, orderBy olmadan dene
        console.warn('GetAllUsers orderBy failed, trying without orderBy:', orderByError);
        q = query(
          collection(db, COLLECTIONS.USERS),
          limit(limitCount),
        );

        if (lastDoc) {
          // lastDoc ile pagination orderBy olmadan çalışmaz, bu yüzden sadece limit kullan
          q = query(
            collection(db, COLLECTIONS.USERS),
            limit(limitCount),
          );
        }

        const snapshot = await getDocs(q);
        const users = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        }));
        
        // Client-side sort
        return users.sort((a, b) => {
          const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
          const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
          return bDate - aDate;
        });
      }
    } catch (error) {
      console.error('Get all users error:', error);
      throw error;
    }
  }

  /**
   * Kullanıcı ara
   */
  async searchUsers(searchTerm) {
    try {
      const usersSnapshot = await getDocs(collection(db, COLLECTIONS.USERS));

      const users = usersSnapshot.docs
        .map(doc => ({
          id: doc.id,
          ...doc.data(),
        }))
        .filter(user => {
          const name = (user.name || '').toLowerCase();
          const email = (user.email || '').toLowerCase();
          const search = searchTerm.toLowerCase();
          return name.includes(search) || email.includes(search);
        });

      return users;
    } catch (error) {
      console.error('Search users error:', error);
      throw error;
    }
  }

  /**
   * Kullanıcı detaylarını getir
   */
  async getUserById(userId) {
    try {
      const docRef = doc(db, COLLECTIONS.USERS, userId);
      const docSnap = await getDoc(docRef);

      if (!docSnap.exists()) {
        throw new Error('Kullanıcı bulunamadı');
      }

      return {
        id: docSnap.id,
        ...docSnap.data(),
      };
    } catch (error) {
      console.error('Get user by id error:', error);
      throw error;
    }
  }

  /**
   * Kullanıcıyı güncelle
   */
  async updateUser(userId, data) {
    try {
      await updateDoc(doc(db, COLLECTIONS.USERS, userId), data);
    } catch (error) {
      console.error('Update user error:', error);
      throw error;
    }
  }

  /**
   * Kullanıcıyı sil
   */
  async deleteUser(userId) {
    try {
      await deleteDoc(doc(db, COLLECTIONS.USERS, userId));
    } catch (error) {
      console.error('Delete user error:', error);
      throw error;
    }
  }

  /**
   * Kullanıcı karma puanını güncelle
   */
  async updateUserKarma(userId, amount, reason) {
    try {
      await runTransaction(db, async transaction => {
        const userRef = doc(db, COLLECTIONS.USERS, userId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists()) {
          throw new Error('Kullanıcı bulunamadı');
        }

        const currentKarma = userDoc.data().karma || 0;
        const newKarma = currentKarma + amount;

        transaction.update(userRef, {
          karma: newKarma,
          lastKarmaUpdate: serverTimestamp(),
        });

        // Karma transaction kaydı ekle
        const karmaTransactionsRef = collection(
          db,
          COLLECTIONS.USERS,
          userId,
          SUBCOLLECTIONS.KARMA_TRANSACTIONS,
        );
        const transactionRef = doc(karmaTransactionsRef);

        transaction.set(transactionRef, {
          amount,
          reason,
          timestamp: serverTimestamp(),
          adminId: auth.currentUser?.uid,
        });
      });
    } catch (error) {
      console.error('Update user karma error:', error);
      if (error.code === 'permission-denied') {
        throw new Error('Firestore Security Rules güncellenmemiş. FIRESTORE_RULES.md dosyasındaki kuralları Firebase Console\'a ekleyin.');
      }
      throw error;
    }
  }

  // ==================== FORTUNES ====================

  /**
   * Tüm fal kayıtlarını getir
   */
  async getAllFortunes(limitCount = 50, lastDoc = null) {
    try {
      // Önce orderBy ile deneyelim
      let q = query(
        collection(db, COLLECTIONS.READINGS),
        orderBy('createdAt', 'desc'),
        limit(limitCount),
      );

      if (lastDoc) {
        q = query(q, startAfter(lastDoc));
      }

      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));
    } catch (error) {
      console.error('Get all fortunes error:', error);
      // Eğer index yoksa veya permission hatası varsa, sadece limit ile getir
      try {
        const snapshot = await getDocs(
          query(collection(db, COLLECTIONS.READINGS), limit(limitCount)),
        );
        // Client-side sorting
        const docs = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        }));
        // Tarihe göre sırala (en yeni önce)
        docs.sort((a, b) => {
          const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
          const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
          return bDate.getTime() - aDate.getTime();
        });
        return docs;
      } catch (fallbackError) {
        console.error('Fallback get all fortunes error:', fallbackError);
        // Hata durumunda boş array döndür
        return [];
      }
    }
  }

  /**
   * Kullanıcının fal kayıtlarını getir
   */
  async getUserFortunes(userId, limitCount = 50) {
    try {
      const q = query(
        collection(db, COLLECTIONS.READINGS),
        where('userId', '==', userId),
        orderBy('createdAt', 'desc'),
        limit(limitCount),
      );

      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));
    } catch (error) {
      console.error('Get user fortunes error:', error);
      throw error;
    }
  }

  /**
   * Fal kaydını sil
   */
  async deleteFortune(fortuneId) {
    try {
      await deleteDoc(doc(db, COLLECTIONS.READINGS, fortuneId));
    } catch (error) {
      console.error('Delete fortune error:', error);
      throw error;
    }
  }

  /**
   * Fal detayını getir
   */
  async getFortuneById(fortuneId) {
    try {
      const docRef = doc(db, COLLECTIONS.READINGS, fortuneId);
      const docSnap = await getDoc(docRef);

      if (!docSnap.exists()) {
        throw new Error('Fal kaydı bulunamadı');
      }

      return {
        id: docSnap.id,
        ...docSnap.data(),
      };
    } catch (error) {
      console.error('Get fortune by id error:', error);
      throw error;
    }
  }

  // ==================== TESTS ====================

  /**
   * Tüm test sonuçlarını getir
   * Not: CollectionGroup query'leri permission sorunlarına yol açabilir
   * Bu yüzden tüm users'ı iterate edip test_results'ları topluyoruz
   */
  async getAllTestResults(limitCount = 50, lastDoc = null) {
    try {
      // Admin kontrolü yap
      const isAdmin = await this.checkAdminStatus();
      console.log('getAllTestResults - Is admin:', isAdmin);
      
      if (!isAdmin) {
        console.warn('User is not admin, cannot list test results');
        return [];
      }

      // CollectionGroup yerine, tüm users'ı al ve her birinin test_results'unu getir
      console.log('Getting users...');
      const usersSnapshot = await getDocs(
        query(collection(db, COLLECTIONS.USERS), limit(100)), // İlk 100 kullanıcı
      );
      console.log(`Found ${usersSnapshot.size} users`);

      const allTestResults = [];
      
      // Her kullanıcı için test_results ve quiz_test_results'ları al
      // Paralel olarak çalıştır (performans için)
      const userPromises = usersSnapshot.docs.map(async userDoc => {
        const userResults = [];
        
        // test_results için
        try {
          let testResultsSnapshot;
          try {
            testResultsSnapshot = await getDocs(
              query(
                collection(db, COLLECTIONS.USERS, userDoc.id, SUBCOLLECTIONS.TEST_RESULTS),
                orderBy('createdAt', 'desc'),
                limit(10),
              ),
            );
          } catch (orderByError) {
            // orderBy hatası varsa, orderBy olmadan dene
            testResultsSnapshot = await getDocs(
              query(
                collection(db, COLLECTIONS.USERS, userDoc.id, SUBCOLLECTIONS.TEST_RESULTS),
                limit(10),
              ),
            );
          }

          testResultsSnapshot.docs.forEach(doc => {
            userResults.push({
              id: doc.id,
              userId: userDoc.id,
              collectionType: 'test_results',
              ...doc.data(),
            });
          });
        } catch (error) {
          // Sessizce devam et
        }

        // quiz_test_results için
        try {
          let quizResultsSnapshot;
          try {
            quizResultsSnapshot = await getDocs(
              query(
                collection(db, COLLECTIONS.USERS, userDoc.id, SUBCOLLECTIONS.QUIZ_TEST_RESULTS),
                orderBy('createdAt', 'desc'),
                limit(10),
              ),
            );
          } catch (orderByError) {
            // orderBy hatası varsa, orderBy olmadan dene
            quizResultsSnapshot = await getDocs(
              query(
                collection(db, COLLECTIONS.USERS, userDoc.id, SUBCOLLECTIONS.QUIZ_TEST_RESULTS),
                limit(10),
              ),
            );
          }

          quizResultsSnapshot.docs.forEach(doc => {
            userResults.push({
              id: doc.id,
              userId: userDoc.id,
              collectionType: 'quiz_test_results',
              ...doc.data(),
            });
          });
        } catch (error) {
          // Sessizce devam et
        }

        return userResults;
      });

      // Tüm promise'leri bekleyip sonuçları birleştir
      const allUserResults = await Promise.all(userPromises);
      allUserResults.forEach(userResults => {
        allTestResults.push(...userResults);
      });
      
      // Debug log'ları kaldırıldı (performans için)

      // Tarihe göre sırala ve limit uygula
      allTestResults.sort((a, b) => {
        const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
        const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
        return bDate.getTime() - aDate.getTime();
      });

      return allTestResults.slice(0, limitCount);
    } catch (error) {
      console.error('Get all test results error:', error);
      // Hata durumunda boş array döndür
      return [];
    }
  }

  /**
   * Test sonucunu getir
   */
  async getTestResult(userId, collectionType, testResultId) {
    try {
      const collection = collectionType === 'quiz_test_results' 
        ? SUBCOLLECTIONS.QUIZ_TEST_RESULTS 
        : SUBCOLLECTIONS.TEST_RESULTS;
      
      const testDoc = await getDoc(
        doc(db, COLLECTIONS.USERS, userId, collection, testResultId),
      );
      
      if (!testDoc.exists()) {
        throw new Error('Test sonucu bulunamadı');
      }
      
      return { id: testDoc.id, userId, collectionType, ...testDoc.data() };
    } catch (error) {
      console.error('Get test result error:', error);
      throw error;
    }
  }

  /**
   * Test sonucunu sil
   */
  async deleteTestResult(userId, collectionType, testResultId) {
    try {
      const collection = collectionType === 'quiz_test_results' 
        ? SUBCOLLECTIONS.QUIZ_TEST_RESULTS 
        : SUBCOLLECTIONS.TEST_RESULTS;
      
      await deleteDoc(
        doc(db, COLLECTIONS.USERS, userId, collection, testResultId),
      );
    } catch (error) {
      console.error('Delete test result error:', error);
      throw error;
    }
  }

  // ==================== STATISTICS ====================

  /**
   * Toplam kullanıcı sayısı
   */
  async getTotalUsers() {
    try {
      // getCountFromServer yerine normal query kullan (security rules daha kolay)
      const snapshot = await getDocs(collection(db, COLLECTIONS.USERS));
      return snapshot.size;
    } catch (error) {
      console.error('Get total users error:', error);
      throw error;
    }
  }

  /**
   * Aktif kullanıcı sayısı (son 30 gün)
   */
  async getActiveUsers() {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const q = query(
        collection(db, COLLECTIONS.USERS),
        where('lastLoginAt', '>=', Timestamp.fromDate(thirtyDaysAgo)),
      );

      // getCountFromServer yerine normal query kullan
      const snapshot = await getDocs(q);
      return snapshot.size;
    } catch (error) {
      console.error('Get active users error:', error);
      throw error;
    }
  }

  /**
   * Premium kullanıcı sayısı
   */
  async getPremiumUsersCount() {
    try {
      // Önce isPremium == true ile dene
      let q = query(
        collection(db, COLLECTIONS.USERS),
        where('isPremium', '==', true),
      );

      try {
        const snapshot = await getDocs(q);
        return snapshot.size;
      } catch (queryError) {
        // Query başarısız olursa, tüm kullanıcıları al ve client-side say
        console.warn('Premium count query failed, using fallback:', queryError);
        const allUsers = await this.getAllUsers(1000);
        return allUsers.filter(user => {
          const isPremium = user.isPremium;
          return isPremium === true || isPremium === 'true' || isPremium === 1;
        }).length;
      }
    } catch (error) {
      console.error('Get premium users count error:', error);
      // Permission hatası durumunda 0 döndür
      if (error.code === 'permission-denied') {
        return 0;
      }
      return 0; // Hata durumunda 0 döndür
    }
  }

  /**
   * Premium kullanıcıları getir
   */
  async getPremiumUsers(limitCount = 100) {
    try {
      // Önce orderBy ile dene (index varsa)
      let q = query(
        collection(db, COLLECTIONS.USERS),
        where('isPremium', '==', true),
        orderBy('createdAt', 'desc'),
        limit(limitCount),
      );

      try {
        const snapshot = await getDocs(q);
        const users = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        }));
        
        console.log('Premium users from query:', users.length);
        
        // createdAt'e göre client-side sort (bazı dokümanlarda createdAt olmayabilir)
        return users.sort((a, b) => {
          const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
          const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
          return bDate - aDate;
        });
      } catch (orderByError) {
        // Index yoksa orderBy olmadan dene
        console.warn('OrderBy query failed, trying without orderBy:', orderByError);
        q = query(
          collection(db, COLLECTIONS.USERS),
          where('isPremium', '==', true),
          limit(limitCount),
        );
        
        const snapshot = await getDocs(q);
        const users = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        }));
        
        console.log('Premium users from query (no orderBy):', users.length);
        
        // Client-side sort
        return users.sort((a, b) => {
          const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
          const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
          return bDate - aDate;
        });
      }
    } catch (error) {
      console.error('Get premium users error:', error);
      if (error.code === 'permission-denied') {
        return [];
      }
        // Son çare: Tüm kullanıcıları al ve client-side filtrele
      try {
        console.warn('Trying fallback: fetching all users and filtering client-side');
        const allUsers = await this.getAllUsers(limitCount * 2); // Biraz fazla al
        console.log('All users fetched for premium filter:', allUsers.length);
        const premiumUsers = allUsers
          .filter(user => {
            const isPremium = user.isPremium;
            // Boolean true, string "true", veya 1 değerlerini kabul et
            return isPremium === true || isPremium === 'true' || isPremium === 1;
          })
          .slice(0, limitCount)
          .sort((a, b) => {
            const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
            const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
            return bDate - aDate;
          });
        console.log('Premium users after filter:', premiumUsers.length);
        return premiumUsers;
      } catch (fallbackError) {
        console.error('Fallback also failed:', fallbackError);
        return [];
      }
    }
  }

  /**
   * Günlük fal sayısı
   */
  async getDailyFortunesCount(date) {
    try {
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);

      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);

      const q = query(
        collection(db, COLLECTIONS.READINGS),
        where('createdAt', '>=', Timestamp.fromDate(startOfDay)),
        where('createdAt', '<=', Timestamp.fromDate(endOfDay)),
      );

      // getCountFromServer yerine normal query kullan (security rules daha kolay)
      const snapshot = await getDocs(q);
      return snapshot.size;
    } catch (error) {
      console.error('Get daily fortunes count error:', error);
      // Hata durumunda 0 döndür (dashboard çalışmaya devam etsin)
      return 0;
    }
  }

  /**
   * Fal türüne göre sayılar
   */
  async getFortunesByType() {
    try {
      // Admin için: limit ile tüm falları al (list izni gerekiyor)
      const snapshot = await getDocs(
        query(collection(db, COLLECTIONS.READINGS), limit(1000)), // Max 1000 fal
      );

      const counts = {};
      snapshot.docs.forEach(doc => {
        const type = doc.data().type || 'unknown';
        counts[type] = (counts[type] || 0) + 1;
      });

      return counts;
    } catch (error) {
      console.error('Get fortunes by type error:', error);
      // Hata durumunda boş obje döndür
      return {};
    }
  }

  // ==================== CHATS ====================

  /**
   * Admin kontrolü yap
   */
  async checkAdminStatus() {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        console.log('No current user');
        return false;
      }
      
      const adminDoc = await getDoc(doc(db, COLLECTIONS.ADMINS, currentUser.uid));
      const isAdmin = adminDoc.exists() && adminDoc.data().isAdmin === true;
      console.log('Admin check:', {
        uid: currentUser.uid,
        exists: adminDoc.exists(),
        isAdmin: isAdmin,
        data: adminDoc.data(),
      });
      return isAdmin;
    } catch (error) {
      console.error('Check admin status error:', error);
      return false;
    }
  }

  /**
   * Tüm sohbetleri getir
   */
  async getAllChats(limitCount = 50, lastDoc = null) {
    try {
      // Admin kontrolü yap
      const isAdmin = await this.checkAdminStatus();
      console.log('Is admin:', isAdmin);
      
      if (!isAdmin) {
        console.warn('User is not admin, cannot list chats');
        return [];
      }

      // Test: Bir chat document'ini direkt oku (get izni testi)
      // Görselden gördüğüm chat ID: "2OjyR0J5xbMsc2lynEGQqgkoWjj1_9..."
      // Önce tüm chat ID'lerini bulmak için collection'ı oku
      console.log('Attempting to list chats collection...');
      
      // Önce orderBy olmadan dene (index gerektirmez)
      let q = query(
        collection(db, COLLECTIONS.CHATS),
        limit(limitCount),
      );

      if (lastDoc) {
        q = query(q, startAfter(lastDoc));
      }

      const snapshot = await getDocs(q);
      console.log('Chats snapshot size:', snapshot.size); // Debug
      console.log('Chats snapshot empty:', snapshot.empty); // Debug
      console.log('Chats query metadata:', {
        fromCache: snapshot.metadata.fromCache,
        hasPendingWrites: snapshot.metadata.hasPendingWrites,
      });
      
      // Eğer 0 dönüyorsa, belki de gerçekten chat yok veya rules çalışmıyor
      // Test için: Bir chat document'ini direkt oku (get izni testi)
      if (snapshot.empty) {
        console.warn('Chats collection is empty or rules blocking access');
        console.warn('Testing direct document read...');
        
        // Chat ID formatı: userId1_userId2 (alfabetik sıralı)
        // Tüm users'ları okuyup chat ID'lerini oluşturmayı dene
        try {
          console.log('Attempting to find chats by reading users...');
          const usersSnapshot = await getDocs(query(collection(db, COLLECTIONS.USERS), limit(10)));
          console.log('Users found:', usersSnapshot.size);
          
          const userIds = usersSnapshot.docs.map(doc => doc.id);
          console.log('User IDs:', userIds);
          
          // Tüm user çiftlerini test et (chat ID formatı: userId1_userId2)
          const foundChats = [];
          for (let i = 0; i < userIds.length; i++) {
            for (let j = i + 1; j < userIds.length; j++) {
              const sortedIds = [userIds[i], userIds[j]].sort();
              const testChatId = `${sortedIds[0]}_${sortedIds[1]}`;
              
              try {
                const testChatDoc = await getDoc(doc(db, COLLECTIONS.CHATS, testChatId));
                if (testChatDoc.exists()) {
                  console.log(`Found chat: ${testChatId}`, testChatDoc.data());
                  foundChats.push({
                    id: testChatDoc.id,
                    ...testChatDoc.data(),
                  });
                }
              } catch (err) {
                // Ignore individual errors
              }
            }
          }
          
          if (foundChats.length > 0) {
            console.log(`Found ${foundChats.length} chats by testing user pairs`);
            // Tarihe göre sırala
            foundChats.sort((a, b) => {
              const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : (a.lastMessageAt?.toDate ? a.lastMessageAt.toDate() : new Date(0));
              const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : (b.lastMessageAt?.toDate ? b.lastMessageAt.toDate() : new Date(0));
              return bDate.getTime() - aDate.getTime();
            });
            return foundChats.slice(0, limitCount);
          } else {
            console.warn('No chats found by testing user pairs. Collection might be empty.');
          }
        } catch (testError) {
          console.error('Test chat read error:', testError);
          console.error('Error code:', testError.code);
          console.error('Error message:', testError.message);
        }
        
        // Alternatif: Collection'ı direkt oku (limit olmadan)
        try {
          const allSnapshot = await getDocs(collection(db, COLLECTIONS.CHATS));
          console.log('All chats snapshot size (no limit):', allSnapshot.size);
          console.log('All chats snapshot empty:', allSnapshot.empty);
          
          if (allSnapshot.size > 0) {
            const chats = allSnapshot.docs.map(doc => {
              const data = doc.data();
              console.log('Chat doc (no limit):', doc.id, data);
              return {
                id: doc.id,
                ...data,
              };
            });
            
            // Tarihe göre sırala
            chats.sort((a, b) => {
              const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : (a.lastMessageAt?.toDate ? a.lastMessageAt.toDate() : new Date(0));
              const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : (b.lastMessageAt?.toDate ? b.lastMessageAt.toDate() : new Date(0));
              return bDate.getTime() - aDate.getTime();
            });
            
            return chats.slice(0, limitCount);
          } else {
            console.warn('No chats found in collection. Please check:');
            console.warn('1. Firestore rules are published');
            console.warn('2. Chats collection exists in Firestore');
            console.warn('3. Admin user has isAdmin: true in admins collection');
            console.warn('4. Firestore rules allow list for admins');
          }
        } catch (altError) {
          console.error('Alternative query error:', altError);
          console.error('Error code:', altError.code);
          console.error('Error message:', altError.message);
        }
      }
      
      const chats = snapshot.docs.map(doc => {
        const data = doc.data();
        console.log('Chat doc:', doc.id, data); // Debug
        return {
          id: doc.id,
          ...data,
        };
      });
      
      // Tarihe göre sırala (client-side) - createdAt varsa
      chats.sort((a, b) => {
        const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : (a.lastMessageAt?.toDate ? a.lastMessageAt.toDate() : new Date(0));
        const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : (b.lastMessageAt?.toDate ? b.lastMessageAt.toDate() : new Date(0));
        return bDate.getTime() - aDate.getTime();
      });
      
      console.log('Processed chats:', chats); // Debug
      return chats;
    } catch (error) {
      console.error('Get all chats error:', error);
      console.error('Error code:', error.code);
      console.error('Error message:', error.message);
      // Hata durumunda boş array döndür
      return [];
    }
  }

  /**
   * Sohbet detaylarını getir
   */
  async getChatDetail(chatId) {
    try {
      const chatDoc = await getDoc(doc(db, COLLECTIONS.CHATS, chatId));
      if (!chatDoc.exists()) {
        throw new Error('Sohbet bulunamadı');
      }

      // Mesajları getir - orderBy hatası olursa fallback kullan
      let messagesSnapshot;
      try {
        messagesSnapshot = await getDocs(
          query(
            collection(db, COLLECTIONS.CHATS, chatId, 'messages'),
            orderBy('timestamp', 'desc'),
            limit(100),
          ),
        );
      } catch (orderByError) {
        console.warn('OrderBy error, trying without orderBy:', orderByError);
        // Index yoksa orderBy olmadan dene
        messagesSnapshot = await getDocs(
          query(
            collection(db, COLLECTIONS.CHATS, chatId, 'messages'),
            limit(100),
          ),
        );
      }

      const messages = messagesSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));

      // Eğer orderBy olmadan çekildiyse, client-side sırala
      if (messages.length > 0 && messages[0].timestamp) {
        messages.sort((a, b) => {
          const aTime = a.timestamp?.toDate ? a.timestamp.toDate() : new Date(a.timestamp);
          const bTime = b.timestamp?.toDate ? b.timestamp.toDate() : new Date(b.timestamp);
          return bTime - aTime; // Descending order
        });
      }

      console.log(`Loaded ${messages.length} messages for chat ${chatId}`);
      console.log('Messages:', messages);

      return {
        id: chatDoc.id,
        ...chatDoc.data(),
        messages: messages,
      };
    } catch (error) {
      console.error('Get chat detail error:', error);
      throw error;
    }
  }

  // ==================== REPORTS ====================

  /**
   * Kullanıcı bildirimlerini (raporları) getir
   */
  async getReports(limitCount = 100) {
    try {
      const q = query(
        collection(db, COLLECTIONS.REPORTS),
        orderBy('reportedAt', 'desc'),
        limit(limitCount),
      );

      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));
    } catch (error) {
      console.error('Get reports error:', error);
      return [];
    }
  }

  /**
   * Sohbeti sil
   */
  async deleteChat(chatId) {
    try {
      // Önce mesajları sil
      const messagesSnapshot = await getDocs(
        collection(db, COLLECTIONS.CHATS, chatId, 'messages'),
      );

      const deletePromises = messagesSnapshot.docs.map(doc =>
        deleteDoc(doc.ref),
      );
      await Promise.all(deletePromises);

      // Sonra sohbeti sil
      await deleteDoc(doc(db, COLLECTIONS.CHATS, chatId));
    } catch (error) {
      console.error('Delete chat error:', error);
      throw error;
    }
  }

  /**
   * Mesajı sil
   */
  async deleteMessage(chatId, messageId) {
    try {
      await deleteDoc(
        doc(db, COLLECTIONS.CHATS, chatId, 'messages', messageId),
      );
    } catch (error) {
      console.error('Delete message error:', error);
      throw error;
    }
  }

  // ==================== MATCHES ====================

  /**
   * Tüm eşleşmeleri getir
   */
  async getAllMatches(limitCount = 50, lastDoc = null) {
    try {
      // Admin kontrolü yap
      const isAdmin = await this.checkAdminStatus();
      if (!isAdmin) {
        console.warn('User is not admin, cannot list matches');
        return [];
      }

      // orderBy olmadan dene (index gerektirmez)
      let q = query(
        collection(db, COLLECTIONS.MATCHES),
        limit(limitCount),
      );

      if (lastDoc) {
        q = query(q, startAfter(lastDoc));
      }

      const snapshot = await getDocs(q);
      const matches = snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          ...data,
        };
      });

      // Tarihe göre sırala (client-side)
      matches.sort((a, b) => {
        const aDate = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(0);
        const bDate = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(0);
        return bDate.getTime() - aDate.getTime();
      });

      return matches;
    } catch (error) {
      console.error('Get all matches error:', error);
      return [];
    }
  }

  /**
   * Eşleşme detaylarını getir
   */
  async getMatchDetail(matchId) {
    try {
      // Admin kontrolü yap
      const isAdmin = await this.checkAdminStatus();
      if (!isAdmin) {
        console.warn('User is not admin, cannot get match detail');
        throw new Error('Yetkisiz erişim');
      }

      const matchDoc = await getDoc(doc(db, COLLECTIONS.MATCHES, matchId));
      if (!matchDoc.exists()) {
        throw new Error('Eşleşme bulunamadı');
      }
      return { id: matchDoc.id, ...matchDoc.data() };
    } catch (error) {
      console.error('Get match detail error:', error);
      throw error;
    }
  }

  /**
   * Eşleşmeyi sil
   */
  async deleteMatch(matchId) {
    try {
      await deleteDoc(doc(db, COLLECTIONS.MATCHES, matchId));
    } catch (error) {
      console.error('Delete match error:', error);
      throw error;
    }
  }

  // ==================== ADMINS ====================

  /**
   * Tüm admin'leri getir
   */
  async getAllAdmins() {
    try {
      const isAdmin = await this.checkAdminStatus();
      if (!isAdmin) {
        console.warn('User is not admin, cannot list admins');
        return [];
      }

      const snapshot = await getDocs(collection(db, COLLECTIONS.ADMINS));
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));
    } catch (error) {
      console.error('Get all admins error:', error);
      return [];
    }
  }

  /**
   * Admin ekle
   */
  async addAdmin(userId, email) {
    try {
      await setDoc(doc(db, COLLECTIONS.ADMINS, userId), {
        isAdmin: true,
        email: email,
        createdAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Add admin error:', error);
      throw error;
    }
  }

  /**
   * Admin'i kaldır
   */
  async removeAdmin(userId) {
    try {
      await deleteDoc(doc(db, COLLECTIONS.ADMINS, userId));
    } catch (error) {
      console.error('Remove admin error:', error);
      throw error;
    }
  }
}

export default new FirebaseService();
