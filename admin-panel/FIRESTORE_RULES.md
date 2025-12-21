# Firestore Security Rules - Admin Panel

Firebase Console > Firestore Database > Rules sekmesine bu kuralları yapıştırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin kontrolü için helper function
    function isAdmin() {
      return request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true;
    }

    // Admins collection - İlk admin oluşturma için yazma izni gerekli
    // Sonraki admin'ler sadece backend'den eklenebilir
    match /admins/{adminId} {
      // Admin'ler okuyabilir
      allow read: if isAdmin();
      // İlk admin oluşturma için: collection boşsa herkes yazabilir
      // Sonraki admin'ler için: sadece mevcut admin'ler yazabilir
      allow write: if request.auth != null && (
        // Collection boşsa (ilk admin)
        !exists(/databases/$(database)/documents/admins) ||
        // Veya mevcut admin ise
        isAdmin()
      );
    }

    // Users collection - Admin'ler tam erişim
    match /users/{userId} {
      allow read, write: if isAdmin();
      
      // Subcollections (karma_transactions, fortunes, tests, vb.)
      match /{subcollection=**} {
        allow read, write: if isAdmin();
      }
    }

    // Readings collection - Admin'ler tam erişim
    match /readings/{readingId} {
      allow read, write: if isAdmin();
    }

    // Tarot cards - Admin'ler okuyabilir, yazamaz
    match /tarot_cards/{cardId} {
      allow read: if isAdmin();
      allow write: if false; // Sadece backend'den yazılabilir
    }

    // Fortune tellers - Admin'ler okuyabilir, yazamaz
    match /fortune_tellers/{tellerId} {
      allow read: if isAdmin();
      allow write: if false;
    }

    // Horoscopes - Admin'ler tam erişim
    match /horoscopes/{horoscopeId} {
      allow read, write: if isAdmin();
    }

    // IP addresses - Admin'ler tam erişim
    match /ip_addresses/{ipAddress} {
      allow read, write: if isAdmin();
    }
  }
}
```

## Önemli Notlar

1. **İlk Admin Oluşturma**: `admins` collection'ı boşsa, herhangi bir authenticated kullanıcı admin olarak kaydedilebilir. Bu, ilk admin oluşturma için gereklidir.

2. **Sonraki Admin'ler**: İlk admin oluşturulduktan sonra, sadece mevcut admin'ler yeni admin ekleyebilir.

3. **Transaction İzinleri**: Transaction'lar normal write izinlerini kullanır. `users` collection'ına write izni varsa, transaction'lar da çalışır.

4. **Subcollection İzinleri**: `users/{userId}/karma_transactions` gibi subcollection'lar için `match /{subcollection=**}` kuralı tüm subcollection'ları kapsar.

## Kuralları Güncelleme

1. Firebase Console'a gidin: https://console.firebase.google.com/
2. Projenizi seçin: `falla-6b4f1`
3. Firestore Database > Rules sekmesine gidin
4. Yukarıdaki kuralları yapıştırın
5. "Publish" butonuna tıklayın

## Test Etme

Kuralları güncelledikten sonra:
1. Admin panelinde karma güncelleme yapmayı deneyin
2. Kullanıcı listesini görüntülemeyi deneyin
3. Fal kayıtlarını görüntülemeyi deneyin

Eğer hala permission hatası alıyorsanız:
- Browser'ı yenileyin (cache temizle)
- Firebase Console'da Rules'ın doğru publish edildiğini kontrol edin
- Admin kullanıcının `admins` collection'ında olduğunu kontrol edin

