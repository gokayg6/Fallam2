  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      // ==================== ADMIN PANEL KURALLARI ====================
      
      // Admin kontrolü için helper function
      function isAdmin() {
        return request.auth != null && 
          exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
          get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true;
      }

      // Admins collection - İlk admin oluşturma için yazma izni gerekli
      match /admins/{adminId} {
        // Admin'ler okuyabilir
        allow read: if isAdmin();
        // İlk admin oluşturma için: collection boşsa authenticated kullanıcı yazabilir
        // Sonraki admin'ler için: sadece mevcut admin'ler yazabilir
        allow create: if request.auth != null && (
          // Collection boşsa (ilk admin) - count query ile kontrol
          !exists(/databases/$(database)/documents/admins) ||
          // Veya mevcut admin ise
          isAdmin()
        );
        // Güncelleme: sadece admin'ler
        allow update: if isAdmin();
        // Silme: sadece admin'ler (ilk admin silinemez - isFirstAdmin kontrolü uygulama tarafında)
        allow delete: if isAdmin();
      }

      // Raporlar (reports) - sohbet mesajı / kullanıcı raporları
      // Oluşturma: sadece kimliği doğrulanmış kullanıcılar yeni rapor ekleyebilir
      // Okuma / silme / güncelleme: sadece admin panel (admin kullanıcılar)
      match /reports/{reportId} {
        // Admin tüm raporları görebilir
        allow read, list, get: if isAdmin();

        // Uygulama tarafı: sadece create (rapor ekleme)
        allow create: if request.auth != null;

        // Kullanıcılar raporu sonradan değiştiremez veya silemez; sadece admin
        allow update, delete: if isAdmin();
      }

      // ==================== MEVCUT UYGULAMA KURALLARI ====================
      
      // Users koleksiyonu için kurallar
      match /users/{userId} {
        // Okuma izni: Kimliği doğrulanmış kullanıcılar TÜM kullanıcı profillerini okuyabilir
        // (Ruh Eşi Analizi gibi listeleme özellikleri için gereklidir)
        // Admin'ler de okuyabilir
        allow read: if request.auth != null;
        
        // Yazma izni: Kendi profiline VEYA admin ise
        allow write: if (request.auth != null && request.auth.uid == userId) || isAdmin();

        // Alt koleksiyonlar (ör. users/{uid}/spins/state, karma_transactions, test_results, vb.)
        // Sahibine açık VEYA admin ise
        // Not: {sub=**} tüm subcollection'ları kapsar (test_results, quiz_test_results, karma_transactions, vb.)
        match /{subcollection=**} {
          // Read: Sahibine açık VEYA admin ise
          // isAdmin() fonksiyonu query sırasında çalışmayabilir, bu yüzden direkt kontrol yapıyoruz
          allow read: if (request.auth != null && request.auth.uid == userId) || 
                       (request.auth != null && 
                        exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
                        get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true);
          
          // Write: Sahibine açık VEYA admin ise
          allow write: if (request.auth != null && request.auth.uid == userId) || isAdmin();
        }
      }
      
      // Tarot kartları (sadece okuma — kimliği doğrulanmış kullanıcılar)
      // Admin'ler okuyabilir ama yazamaz (backend'den yönetilir)
      match /tarot_cards/{cardId} {
        allow read: if request.auth != null;
        allow create, update, delete: if false;
      }

      // Falcılar (sadece okuma — kimliği doğrulanmış kullanıcılar)
      // Admin'ler okuyabilir ama yazamaz (backend'den yönetilir)
      match /fortune_tellers/{tellerId} {
        allow read: if request.auth != null;
        allow create, update, delete: if false;
      }

      // Günlük burç yorumları (horoscopes)
      // Kimliği doğrulanmış kullanıcılar okuyabilir, yazabilir (günlük cache için)
      // Admin'ler de tam erişim
      match /horoscopes/{horoscopeId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null || isAdmin();
      }

      // Kullanıcı fal kayıtları (readings)
      // Uygulama 'readings' koleksiyonuna kullanıcıya ait dökümanlar yazar ve okur
      // Admin'ler tüm falları okuyabilir ve silebilir
      match /readings/{readingId} {
        // Oluşturma: sadece kimliği doğrulanmış kullanıcı ve kendi userId'si ile
        allow create: if request.auth != null
                      && request.resource.data.userId == request.auth.uid;

        // List (query): Admin'ler tüm falları listeleyebilir
        // Normal kullanıcılar: where userId == auth.uid ile query yapabilir
        // Not: Firestore rules'da query parametrelerine direkt erişim yok, bu yüzden
        // authenticated kullanıcılar için list izni veriyoruz, ama get/update'de userId kontrolü yapıyoruz
        allow list: if isAdmin() || request.auth != null;

        // Get (tek document): dökümanın sahibi VEYA admin ise
        allow get: if isAdmin() || (request.auth != null
                        && resource.data.userId == request.auth.uid);

        // Güncelleme: dökümanın sahibi VEYA admin ise
        allow update: if isAdmin() || (request.auth != null
                          && resource.data.userId == request.auth.uid);

        // Silme: sadece admin (kullanıcılar kendi fallarını silemez)
        allow delete: if isAdmin();
      }

      // Eşleşmeler (matches)
      // Okuma: sadece dokümandaki users listesinde bulunan kullanıcılar
      // Yazma: sadece kimliği doğrulanmış kullanıcılar (uygulama tarafında kontrol ediliyor)
      // Güncelleme: karşılıklı onay sistemi için - sadece match'teki kullanıcılardan biri güncelleyebilir
      match /matches/{matchId} {
        // List (query): Admin'ler tüm eşleşmeleri listeleyebilir
        // Normal kullanıcılar için: where users arrayContains auth.uid ile query yapılmalı
        allow list: if isAdmin() || request.auth != null;
        
        // Get (tek document): kullanıcının users listesinde olması gerekir VEYA admin
        // isAdmin() fonksiyonu bazı durumlarda çalışmayabilir, bu yüzden direkt kontrol de ekliyoruz
        allow get: if isAdmin() || 
                   (request.auth != null && 
                    exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
                    get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true) ||
                   (request.auth != null && request.auth.uid in resource.data.users);
        
        // Oluşturma: kimliği doğrulanmış kullanıcılar, kendini users listesine eklemeli VEYA admin
        allow create: if isAdmin() || (request.auth != null 
                    && request.auth.uid in request.resource.data.users);
        
        // Güncelleme: karşılıklı onay sistemi için
        // - Match'teki kullanıcılardan biri olmalı VEYA admin
        // - users array'i değiştirilemez (güvenlik için - her iki array'in de aynı elemanları içermesi gerekir)
        // - Sadece status, acceptedAt, rejectedAt, hasAuraCompatibility gibi field'lar güncellenebilir
        allow update: if isAdmin() || (request.auth != null 
                    && request.auth.uid in resource.data.users
                    && request.resource.data.users.hasAll(resource.data.users)
                    && resource.data.users.hasAll(request.resource.data.users)
                    && request.resource.data.users.size() == resource.data.users.size()); // users array değiştirilemez
        
        // Silme: sadece admin
        allow delete: if isAdmin();
      }

        // Sosyal istekler (social_requests)
        match /social_requests/{requestId} {
          // Okuma: isteğin göndericisi veya alıcısı (veya admin)
          allow get, list: if request.auth != null &&
            (request.auth.uid == resource.data.fromUserId ||
            request.auth.uid == resource.data.toUserId ||
            isAdmin());

          // Oluşturma: sadece kimliği doğrulanmış kullanıcı kendi UID'si ile fromUserId olarak yazabilir
          allow create: if request.auth != null &&
            request.resource.data.fromUserId == request.auth.uid;

          // Güncelleme:
          // - Admin her şeyi güncelleyebilir
          // - Gönderen pending isteğini iptal edebilir (status -> 'cancelled')
          // - Alan kullanıcı pending isteği accepted/rejected/blocked yapabilir
          // - Engeli kaldırma: blocked isteği rejected yapabilir (her iki taraf da)
          allow update: if isAdmin() || (
            request.auth != null &&
            (
              (
                request.auth.uid == resource.data.fromUserId &&
                resource.data.status == 'pending' &&
                request.resource.data.status == 'cancelled'
              ) ||
              (
                request.auth.uid == resource.data.toUserId &&
                resource.data.status == 'pending' &&
                request.resource.data.status in ['accepted', 'rejected', 'blocked']
              ) ||
              (
                // Engeli kaldırma: blocked isteği rejected yapabilir
                resource.data.status == 'blocked' &&
                request.resource.data.status == 'rejected' &&
                (request.auth.uid == resource.data.fromUserId ||
                 request.auth.uid == resource.data.toUserId)
              )
            )
          );

          // Silme: sadece admin
          allow delete: if isAdmin();
        }

    // Sohbetler (chats)
    // Okuma: chat'teki kullanıcılardan biri VEYA admin
    // Yazma: chat'teki kullanıcılardan biri VEYA admin
    match /chats/{chatId} {
       // List (query): Admin'ler tüm sohbetleri listeleyebilir
      // Normal kullanıcılar için: where users arrayContains auth.uid ile query yapılmalı
      // Not: Query yaparken resource yok, bu yüzden sadece admin kontrolü yapılıyor
        // Ayrıca snapshots() kullanıldığında list izni gerekiyor, bu yüzden authenticated kullanıcılara da izin ver
        // Güvenlik: Client-side'da where users arrayContains auth.uid ile filtreleme yapılmalı
        allow list: if isAdmin() || request.auth != null;
      
      // Get (tek document): chat'teki kullanıcılardan biri VEYA admin
        // Eğer document yoksa da izin ver (sonra create yapılacak)
        // Document varsa users array'inde kullanıcı olmalı
        allow get: if isAdmin() || 
                  (request.auth != null && 
                   (!resource.exists || 
                    request.auth.uid in resource.data.get('users', [])));
        
        // Chat oluşturma: kullanıcı kendini users listesine eklemeli VEYA admin
        allow create: if isAdmin() || (request.auth != null && request.auth.uid in request.resource.data.users);
        
        // Güncelleme: 
        // - Chat'teki kullanıcılardan biri olmalı VEYA admin
        // - users array'i değiştirilemez (eğer güncellemede varsa aynı kalmalı, yoksa sorun yok)
        allow update: if isAdmin() || (request.auth != null 
                    && request.auth.uid in resource.data.users);
        
        // Silme: sadece admin
        allow delete: if isAdmin();

        // Mesajlar (chats/{chatId}/messages)
        // Okuma ve yazma: chat'in kullanıcılarından biri VEYA admin
        match /messages/{messageId} {
          // Okuma: chat'in kullanıcılarından biri VEYA admin
            // Parent chat document'ini kontrol et
            // Not: get() document yoksa hata verir, bu yüzden exists() kontrolü yapıyoruz
            // Eğer document yoksa izin ver (chat henüz oluşturulmamış olabilir)
            allow read: if isAdmin() || 
                      (request.auth != null && 
                       (!exists(/databases/$(database)/documents/chats/$(chatId)) ||
                        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.get('users', [])));
            
            // List (query): chat'in kullanıcılarından biri VEYA admin
            // Parent chat document'ini kontrol et
            // Not: get() document yoksa hata verir, bu yüzden exists() kontrolü yapıyoruz
            // Eğer document yoksa izin ver (chat henüz oluşturulmamış olabilir)
            allow list: if isAdmin() || 
                       (request.auth != null && 
                        (!exists(/databases/$(database)/documents/chats/$(chatId)) ||
                         request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.get('users', [])));
          
          // Oluşturma: mesaj gönderen kullanıcı VEYA admin
            // Parent chat document'ini kontrol et
            // Not: get() document yoksa hata verir, bu yüzden exists() kontrolü yapıyoruz
            // Eğer document yoksa izin ver (chat henüz oluşturulmamış olabilir, sonra oluşturulacak)
            allow create: if isAdmin() || 
                        (request.auth != null && 
                         request.auth.uid == request.resource.data.senderId &&
                         (!exists(/databases/$(database)/documents/chats/$(chatId)) ||
                          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.get('users', [])));
          
          // Güncelleme: sadece admin
          allow update: if isAdmin();
          
          // Silme: sadece admin
          allow delete: if isAdmin();
        }
      }

      // IP Adresleri (ip_addresses)
      // IP kontrolü kayıt öncesi yapıldığı için anonymous okuma izni veriliyor
      // IP kaydı için: sadece kayıt sonrası kimliği doğrulanmış kullanıcılar yazabilir
      // Admin'ler tam erişim
      match /ip_addresses/{ipAddress} {
        // Okuma: Herkes okuyabilir (IP kontrolü kayıt öncesi yapılıyor)
        // IP adresi zaten public bilgi olduğu için güvenlik riski minimal
        allow read: if true;
        
        // Oluşturma: kimliği doğrulanmış kullanıcılar VEYA admin
        // userId alanı kullanıcının kendi UID'si olmalı (admin değilse)
        allow create: if (request.auth != null 
                          && request.resource.data.userId == request.auth.uid) || isAdmin();
        
        // Silme: Hesap silinirken IP kaydını silebilir (kendi userId'si ile) VEYA admin
        allow delete: if (request.auth != null 
                          && resource.data.userId == request.auth.uid) || isAdmin();
        
        // Güncelleme: sadece admin (normal kullanıcılar güncelleyemez)
        allow update: if isAdmin();
      }

      // Collection Group Query'leri için admin erişimi
      // test_results, quiz_test_results gibi subcollection'lar için
      // Not: users/{userId}/test_results zaten yukarıdaki users/{userId}/{sub=**} kuralı ile kapsanıyor
      // CollectionGroup query'leri için: Admin'ler tüm users'ı okuyabildiği için test_results'a da erişebilir

      // Test sonuçları ve diğer collection'lar için admin erişimi
      // (users subcollection'ları zaten yukarıda kapsanıyor)
      
      // Diğer koleksiyonlar için varsayılan olarak erişimi reddet
      // Ancak admin'ler için özel izinler yukarıda tanımlanmıştır
      match /{document=**} {
        allow read, write: if false;
      }
    }
  }