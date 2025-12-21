# Firebase Yapılandırma Bilgileri

## Proje Bilgileri

- **Project ID**: `falla-6b4f1`
- **Project Number**: `916591463999`
- **Storage Bucket**: `falla-6b4f1.firebasestorage.app`
- **API Key**: `AIzaSyDS-1WcDKAeoyNdzbLCTBM8R6Yo3DWADMQ`

## Android Yapılandırması

- **Package Name**: `com.mustafakarakus.falla`
- **App ID**: `1:916591463999:android:938b82de32ffbe12c1328a`
- **google-services.json**: `admin-panel/android/app/google-services.json`

## Firestore Collections

### Root Collections

1. **users/{userId}**
   - Kullanıcı profilleri
   - Fields: name, email, karma, isPremium, createdAt, lastLoginAt, etc.

2. **readings/{readingId}**
   - Fal okumaları
   - Fields: userId, type, title, interpretation, createdAt, karmaUsed, etc.

3. **tarot_cards/{cardId}**
   - Tarot kartları (read-only)

4. **fortune_tellers/{tellerId}**
   - Falcılar (read-only)

5. **horoscopes/{horoscopeId}**
   - Burç yorumları

6. **ip_addresses/{ipAddress}**
   - IP adres kayıtları

7. **admins/{adminId}**
   - Admin kullanıcıları
   - Fields: isAdmin (boolean), email, createdAt

### Subcollections (users/{userId}/...)

1. **fortunes**
   - Kullanıcının fal kayıtları

2. **tests**
   - Test kayıtları

3. **test_results**
   - Test sonuçları

4. **quiz_test_results**
   - Quiz test sonuçları

5. **spins**
   - Kader çarkı spin kayıtları
   - Document: `state` (lastSpinAt, lastReward, etc.)

6. **karma_transactions**
   - Karma işlem geçmişi
   - Fields: amount, reason, timestamp, adminId

7. **daily_activities**
   - Günlük aktiviteler
   - Document ID: `YYYY-MM-DD` formatında

8. **dream_draws**
   - Rüya çizimleri

## Fortune Types

- `tarot` - Tarot Falı
- `coffee` - Kahve Falı
- `palm` - El Falı
- `katina` - Katina Falı
- `water` - Su Falı
- `astrology` - Astroloji
- `dream` - Rüya Yorumu
- `daily` - Günlük Yorum

## Test Types

- `love` - Aşk Testi
- `relationship` - İlişki Testi
- `destiny` - Kader Testi
- `personality` - Kişilik Testi
- `quiz` - Quiz Testi

## Admin Panel İçin Firestore Rules Örneği

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function: Admin kontrolü
    function isAdmin() {
      return request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true;
    }

    // Users collection - Admin'ler tam erişim
    match /users/{userId} {
      allow read, write: if isAdmin();
      
      // Subcollections
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

    // Admins collection - Sadece admin'ler okuyabilir
    match /admins/{adminId} {
      allow read: if isAdmin();
      allow write: if false; // Sadece backend'den yazılabilir
    }
  }
}
```

## Admin Kullanıcı Oluşturma

Firestore Console'da veya Cloud Functions ile:

```javascript
// Firestore Console'da
db.collection('admins').doc('ADMIN_USER_ID').set({
  isAdmin: true,
  email: 'admin@falla.com',
  createdAt: firebase.firestore.FieldValue.serverTimestamp()
});
```

Veya Firebase CLI ile:

```bash
firebase firestore:set admins/ADMIN_USER_ID '{"isAdmin": true, "email": "admin@falla.com", "createdAt": "SERVER_TIMESTAMP"}'
```

## Notlar

- Admin paneli için ayrı bir Firebase projesi kullanılabilir (önerilir)
- Production ve development için farklı admin hesapları oluşturulabilir
- Admin hesapları için 2FA (Two-Factor Authentication) önerilir
- Admin işlemleri için audit log tutulması önerilir

