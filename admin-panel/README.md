# Falla Admin Panel - Web

React + Vite ile geliştirilmiş Firebase tabanlı web admin paneli.

## Firebase Yapılandırması

### Proje Bilgileri
- **Project ID**: `falla-6b4f1`
- **API Key**: `AIzaSyDS-1WcDKAeoyNdzbLCTBM8R6Yo3DWADMQ`
- **Storage Bucket**: `falla-6b4f1.firebasestorage.app`
- **Messaging Sender ID**: `916591463999`

### Firestore Collections

#### Root Collections
- `users/{userId}` - Kullanıcı profilleri
- `readings/{readingId}` - Fal okumaları
- `tarot_cards/{cardId}` - Tarot kartları
- `fortune_tellers/{tellerId}` - Falcılar
- `horoscopes/{horoscopeId}` - Burç yorumları
- `ip_addresses/{ipAddress}` - IP adres kayıtları
- `admins/{adminId}` - Admin kullanıcıları

#### Subcollections (users/{userId}/...)
- `fortunes` - Fal kayıtları
- `tests` - Test kayıtları
- `test_results` - Test sonuçları
- `quiz_test_results` - Quiz test sonuçları
- `spins` - Kader çarkı spin kayıtları
- `karma_transactions` - Karma işlemleri
- `daily_activities` - Günlük aktiviteler
- `dream_draws` - Rüya çizimleri

## Kurulum

```bash
# Projeyi klonla
cd admin-panel

# Bağımlılıkları yükle
npm install
# veya
yarn install
```

## Çalıştırma

```bash
# Development server
npm run dev
# veya
yarn dev

# Production build
npm run build
# veya
yarn build

# Preview production build
npm run preview
# veya
yarn preview
```

## Özellikler

### 1. Kullanıcı Yönetimi
- Kullanıcı listesi ve arama
- Kullanıcı detayları görüntüleme
- Karma puanı yönetimi
- Premium durumu yönetimi

### 2. Fal Kayıtları Yönetimi
- Tüm fal kayıtlarını görüntüleme
- Fal türüne göre filtreleme
- Fal detaylarını görüntüleme
- Fal silme

### 3. Test Sonuçları Yönetimi
- Test sonuçlarını görüntüleme
- Test türüne göre filtreleme

### 4. İstatistikler
- Toplam kullanıcı sayısı
- Aktif kullanıcı sayısı
- Günlük/haftalık/aylık fal sayıları
- En popüler fal türleri
- Karma dağılımı

### 5. Karma İşlemleri
- Kullanıcılara karma ekleme/çıkarma
- Karma işlem geçmişi

## Güvenlik

Admin paneli için Firebase Authentication kullanılmalı. Sadece yetkili admin kullanıcıları giriş yapabilir.

Firestore Security Rules'da admin kullanıcıları için özel kurallar tanımlanmalı. Detaylar için `FIREBASE_INFO.md` dosyasına bakın.

## Proje Yapısı

```
admin-panel/
├── src/
│   ├── components/       # Reusable components
│   ├── screens/         # Screen components
│   ├── services/        # Firebase services
│   ├── config/          # Configuration files
│   └── App.jsx          # Main app component
├── index.html
├── vite.config.js
└── package.json
```

## Teknolojiler

- **React 18** - UI framework
- **Vite** - Build tool
- **React Router** - Routing
- **Firebase Web SDK** - Backend services
- **CSS Modules** - Styling

## Notlar

- Firebase Web App ID'yi `src/config/firebase.config.js` dosyasında güncellemeniz gerekebilir
- Admin kullanıcıları Firestore'da `admins` collection'ında tutulmalı
- Firestore Security Rules'ı admin erişimi için yapılandırılmalı
