# Admin Panel Kurulum Rehberi (Web)

## Gereksinimler

- Node.js >= 18
- npm veya yarn

## Kurulum Adımları

### 1. Projeyi Hazırlama

```bash
cd admin-panel
npm install
# veya
yarn install
```

### 2. Firebase Yapılandırması

#### Web App ID'yi Alma

1. Firebase Console'a gidin: https://console.firebase.google.com/
2. `falla-6b4f1` projesini seçin
3. Project Settings > General sekmesine gidin
4. "Your apps" bölümünde Web uygulaması yoksa "Add app" > Web ikonuna tıklayın
5. App nickname verin ve "Register app" butonuna tıklayın
6. `appId` değerini kopyalayın (format: `1:916591463999:web:xxxxx`)

#### Config Dosyasını Güncelleme

`src/config/firebase.config.js` dosyasını açın ve `appId` değerini güncelleyin:

```javascript
const firebaseConfig = {
  // ... diğer değerler
  appId: '1:916591463999:web:YOUR_ACTUAL_WEB_APP_ID', // Buraya gerçek ID'yi yapıştırın
};
```

### 3. Admin Kullanıcı Oluşturma

Firestore'da `admins` collection'ı oluşturun ve admin kullanıcı ekleyin:

#### Firebase Console'dan:

1. Firestore Database'e gidin
2. `admins` collection'ını oluşturun
3. Yeni bir document ekleyin:
   - Document ID: Admin kullanıcının Firebase Auth UID'si
   - Fields:
     - `isAdmin` (boolean): `true`
     - `email` (string): Admin email adresi
     - `createdAt` (timestamp): Server timestamp

#### Firebase CLI ile:

```bash
firebase firestore:set admins/ADMIN_USER_ID '{"isAdmin": true, "email": "admin@falla.com", "createdAt": "SERVER_TIMESTAMP"}'
```

### 4. Firestore Security Rules ⚠️ ÖNEMLİ

**Bu adımı mutlaka yapın!** Aksi halde karma güncelleme ve diğer işlemler çalışmaz.

**Hızlı Kurulum:**

1. Firebase Console'a gidin: https://console.firebase.google.com/
2. `falla-6b4f1` projesini seçin
3. Firestore Database > Rules sekmesine gidin
4. `FIRESTORE_RULES.md` dosyasındaki **tüm kuralları** kopyalayıp yapıştırın
5. "Publish" butonuna tıklayın

**Detaylı kurallar için `FIRESTORE_RULES.md` dosyasına bakın.**

**Not:** İlk admin oluşturma için `admins` collection'ına yazma izni gereklidir. Kurallar bunu otomatik olarak sağlar.

### 5. Çalıştırma

#### Development Mode

```bash
npm run dev
# veya
yarn dev
```

Tarayıcıda `http://localhost:3000` adresine gidin.

#### Production Build

```bash
npm run build
# veya
yarn build
```

Build dosyaları `dist/` klasörüne oluşturulur.

#### Preview Production Build

```bash
npm run preview
# veya
yarn preview
```

## Özellikler

### ✅ Tamamlanan Özellikler

1. **Authentication**
   - Admin girişi
   - Auth state yönetimi
   - Otomatik yönlendirme

2. **Dashboard**
   - Genel istatistikler
   - Hızlı erişim butonları

3. **Kullanıcı Yönetimi**
   - Kullanıcı listesi
   - Kullanıcı arama
   - Kullanıcı detayları
   - Karma yönetimi

4. **Fal Yönetimi**
   - Fal kayıtları listesi
   - Fal detayları
   - Fal silme

5. **Test Yönetimi**
   - Test sonuçları listesi

6. **İstatistikler**
   - Toplam kullanıcı sayısı
   - Aktif kullanıcı sayısı
   - Fal türlerine göre dağılım

## Sorun Giderme

### Firebase bağlantı hatası
- `firebase.config.js` dosyasındaki `appId` değerini kontrol edin
- Firebase Console'da Web app'in oluşturulduğundan emin olun
- Browser console'da hata mesajlarını kontrol edin

### Admin girişi yapılamıyor
- Firestore'da `admins` collection'ının oluşturulduğundan emin olun
- Admin kullanıcının `isAdmin: true` olduğunu kontrol edin
- Firebase Auth'da kullanıcının oluşturulduğundan emin olun

### Veri yüklenmiyor
- Firestore Security Rules'ı kontrol edin
- Browser console'da network tab'ını kontrol edin
- Firebase Console'da Firestore'u kontrol edin

### CORS hatası
- Firebase Hosting kullanıyorsanız, CORS ayarlarını kontrol edin
- Development'ta Vite proxy kullanabilirsiniz

## Deployment

### Firebase Hosting

```bash
# Firebase CLI'yi yükleyin
npm install -g firebase-tools

# Firebase'e giriş yapın
firebase login

# Firebase projesini başlatın
firebase init hosting

# Build alın
npm run build

# Deploy edin
firebase deploy --only hosting
```

### Vercel

```bash
# Vercel CLI'yi yükleyin
npm install -g vercel

# Deploy edin
vercel
```

### Netlify

```bash
# Netlify CLI'yi yükleyin
npm install -g netlify-cli

# Deploy edin
netlify deploy --prod
```

## Notlar

- Admin paneli için ayrı bir Firebase projesi kullanılabilir (önerilir)
- Production ve development için farklı admin hesapları oluşturulabilir
- Admin hesapları için 2FA (Two-Factor Authentication) önerilir
- Admin işlemleri için audit log tutulması önerilir
