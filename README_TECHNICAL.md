## Falla Aura — Teknik Özellikler ve Yapı Dökümanı

### ⚙ Genel Mimari

- **Frontend**: Flutter (Material + Custom Shader Effects)
- **Backend**: Firebase (Firestore, Auth, Storage, Functions)
- **AI Servisleri**: OpenAI / VertexAI / Lokal model (tarot, fal, aura)
- **Tema**: Mistik, koyu, parıltılı mor & pembe degrade arayüz

### 🔐 Firestore Şeması (önerilen)

```json
collections:
  users/{uid}:
    id: string
    email: string | null
    name: string
    zodiac: string | null
    birthDate: timestamp | null
    mood: string | null
    aura:
      color: string | null
      frequency: number | null
      description: string | null
    karma: number
    createdAt: timestamp
    lastLoginAt: timestamp
    preferences: { notifications: bool, sound: bool, vibration: bool, language: string, theme: string }

  readings/{readingId}:
    userId: string
    type: "coffee" | "tarot" | "dream"
    payload: object  // input verisi ve meta
    result: object   // { title, meaning, details... }
    createdAt: timestamp

  matches/{matchId}:
    userId: string
    otherUserId: string
    auraMatchPercent: number
    meta: object
    createdAt: timestamp

  tests/{resultId}:
    userId: string
    kind: "love" | "relationship" | "destiny" | "personality"
    answers: object
    result: object
    createdAt: timestamp

  biorhythm/{docId}:
    userId: string
    date: date
    physical: number
    emotional: number
    mental: number
    score: number

  spins/{docId}:
    userId: string
    lastSpinAt: timestamp
    reward: { type: string, amount: number }
```

### 🔒 Örnek Firestore Güvenlik Kuralları (özet)

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isOwner(uid) { return isSignedIn() && request.auth.uid == uid; }

    match /users/{uid} {
      allow read: if isOwner(uid);
      allow create: if isOwner(uid);
      allow update: if isOwner(uid) && request.resource.data.keys().hasOnly([
        'name','zodiac','birthDate','mood','aura','karma','preferences','lastLoginAt'
      ]);
    }

    match /readings/{id} {
      allow create, read: if isSignedIn() && request.resource.data.userId == request.auth.uid;
    }

    match /matches/{id} {
      allow read, create: if isSignedIn();
    }

    match /tests/{id} {
      allow create, read: if isSignedIn() && request.resource.data.userId == request.auth.uid;
    }

    match /biorhythm/{id} {
      allow read, create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
    }

    match /spins/{id} {
      allow read, create, update: if isSignedIn() && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### ☕ Fal Modülü (fal_module)

#### 2.1 Kahve Falı (Coffee Reading)
- Upload: Kullanıcı 3–5 fotoğraf (fincan, tabak)
- Pipeline: Firebase Storage → Cloud Function → AI (GPT) yorumlama
- Output: `{ title, meaning, details... }`
- UI: Misty loading animasyonu, metin progressive reveal

Cloud Function iskeleti:
```ts
// functions/src/coffeeReading.ts
export const coffeeReading = onCall(async (req) => {
  const { userId, imagePaths } = req.data;
  // 1) Load images from Storage
  // 2) Vision/CLIP ile sembol çıkarımı (opsiyonel)
  // 3) GPT prompt → yorum üret
  // 4) Firestore readings/ kaydet ve sonucu dön
});
```

#### 2.2 Tarot Falı
- Deste: 22 Major + 56 Minor Arcana
- RNG: `SecureRandom` + seed = kullanıcı ruh hali + doğum günü
- AI: Kart başına yorum + genel özet
- UI: “Kader çarkı” animasyonu ile seçim

#### 2.3 Rüya Yorumu & Rüya Çiz
- Input: Metin veya ses → metne dönüştürme
- AI: Sembol tanıma + anlam tablosu
- Görsel: Stable Diffusion API (opsiyonel)
- Output: `{ tema, semboller, mesaj, uyarı }`

#### 2.4 El Falı
- (Genişleme alanı: avuç içi çizgileri → sınıflandırma + AI yorum)

### 💞 Aşk ve İlişki Testleri (love_module)

#### 3.1 Aşk Uyumu Testi
- Input: İki kişinin doğum tarihi, burcu, isim
- Hesaplama: Numeroloji + burç uyumu + AI
- Sonuç: % skor + kısa açıklama

#### 3.2 Ruh Eşi Analizi
- Input: aura renkleri + doğum bilgisi
- Model: Embedding similarity → Firestore kullanıcılarıyla cosine similarity
- UI: Swipe (Tinder benzeri), üstte “% aura uyumu” etiketi

#### 3.3 İlişki Testleri
- Soru JSON (lokal/remote)
- Sonuç: romantik tip, bağlılık seviyesi, özgürlük eğilimi

### 🌈 Aura Sistemi (aura_module)

- Input: günlük ruh hali, uyku süresi, burç, duygusal durum
- Hesap: HSV duygusal harita + AI açıklaması + 0–100 frekans
- UI: 3D parıltılı halka (CustomPainter + Shader), “Aura Güncelle” butonu

### 🔮 Aura Eşleşme (match_module)

- Veri: aura rengi, frekans, ruh hali, burç, cinsiyet, yaş
- Algoritma: K-Means veya cosine similarity
- UI: SwipeCards, kartta aura efekti + uyum yüzdesi
- Aksiyon: “Bağlantı kur” → Firestore `matches/`

### 🧘 Biyoritim (biorhythm_module)

- Input: doğum tarihi + bugün
- Formüller: 23/28/33 gün sinüs
- UI: 3 çizgili grafik + günlük denge puanı + AI yorumu

### 🪙 Karma / Enerji Sistemi

- Amaç: Aktiviteye göre puan
- Kurallar (öneri):
  - Fal baktırma: +5
  - Günlük giriş: +2
  - Test tamamlama: +3
  - Aura paylaşımı: +1
- Firestore: `users/{uid}.karma`
- UI: Header’da sabit “✨ Karma: {n}”

### 🌙 Günlük Burç & Astroloji

- Veri: 12 burç yorumu (günlük) — Firestore’a cron/Functions ile yazılır
- Kullanıcı: Kendi burcuna özel kart
- Ek: “Yarın için önsezi” (seed + aura etkisi)

### 🎲 Kader Çarkı & Oyna-Kazan

- RNG: SecureRandom (10 sonuçtan biri)
- Ödül: Karma veya özel fal hakkı
- Firestore: `spins/{uid}` cooldown (24h)
- UI: Dönen mistik çark animasyonu

### 💫 Altın / Coin Sistemi (opsiyonel)

- Kullanım: Premium fallar, özel testler, aura yeniden analiz
- Satın alma: Firebase Billing / Shopier
- Tablo: `coins → { balance, last_spent, premium_features }`

### 🪄 Görsel & Animasyon Teknikleri

- Shaderlar: MistGlow (pembe-mor aura), Starfield arka plan, NeonText titreşim
- Transition: Hero + fade + blur
- CustomPainter: Aura çemberi, kader çarkı, biyoritim grafik

### 📦 Kurulum ve Ortam

1) Flutter & Firebase CLI kurulu olmalı.
2) `firebase init` → Firestore, Functions, Storage, Hosting (opsiyonel)
3) `google-services.json`/`GoogleService-Info.plist` projeye eklenmeli.
4) Flutter bağımlılıkları:
```bash
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
flutter pub add firebase_functions
flutter pub add provider flutter_animate
```
5) Uygulama başlatma:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 🚦 CI/CD (öneri)

- GitHub Actions: Flutter build (android/ios/web) + Firebase deploy (functions, hosting)
- Lint/Format kontrolü: `flutter analyze` ve `dart format --set-exit-if-changed .`

### 🧪 Test Stratejisi

- Unit: RNG seed, aura hesap fonksiyonları, biorhythm formülleri
- Widget: Kader çarkı animasyonu, loading, header karma gösterimi
- Entegrasyon: Firestore CRUD, Functions çağrıları

### 🔭 Yol Haritası (Gelecek Geliştirmeler)

- Aura bazlı sohbet odası (aynı renkten kullanıcılar)
- Ruh hali takibi (haftalık değişim grafiği)
- “Canlı Falcı” (şimdilik pasif)
- iOS / Android push bildirimleri (Firebase Messaging)

### 📚 Notlar

- Emulator OpenGL sorunları için: `flutter run --enable-software-rendering`
- Auth session kalıcılığı: `FirebaseAuth.instance.setPersistence(Persistence.LOCAL)`
- Güvenlik kuralları prod öncesi test edilmeli (Rules Playground + emulator)


