# Falla Aura - Yeni Özellikler Test Rehberi

Bu doküman, yeni eklenen özelliklerin nasıl test edileceğini açıklar.

## 📋 İçindekiler

1. [Streak Uyarısı](#1-streak-uyarısı)
2. [Quest Sistemi](#2-quest-sistemi)
3. [Paylaşılabilir Kartlar](#3-paylaşılabilir-kartlar)
4. [Aşk Adayları Sistemi](#4-aşk-adayları-sistemi)

---

## 1. Streak Uyarısı

### Test Senaryosu

**Amaç:** Günlük ödül kartında streak sıfırlanma uyarısının görünmesi

**Adımlar:**
1. Uygulamayı açın ve giriş yapın
2. Ana ekrana gidin (Home tab)
3. Eğer bugün giriş yapmadıysanız, **"Günlük Aura Ödülün"** kartı görünmeli
4. Kartın alt kısmında kırmızı bir uyarı kutusu olmalı:
   - 🔥 ikonu
   - "Bugün giriş yapmazsan X günlük serin sıfırlanır!" mesajı
   - X = mevcut streak sayısı

**Beklenen Sonuç:**
- Streak > 0 ise uyarı görünmeli
- Streak = 0 ise uyarı görünmemeli
- Uyarı kutusu kırmızı renkte ve dikkat çekici olmalı

**Not:** Eğer kart görünmüyorsa:
- Bugün zaten giriş yapmış olabilirsiniz
- Firebase'de `daily_activities` koleksiyonunu kontrol edin
- `checkDailyLogin()` fonksiyonunun doğru çalıştığından emin olun

---

## 2. Quest Sistemi

### Test Senaryosu

**Amaç:** Günlük görevler kartının görünmesi ve görevlerin takip edilmesi

**Adımlar:**
1. Ana ekrana gidin
2. **"Bugünkü Görevler"** kartını bulun (Günlük ödül kartının altında)
3. Kart şunları göstermeli:
   - ☕ 1 kahve falı gönder (+3 karma)
   - 💕 1 aşk testi çöz (+2 karma)
   - ✨ 1 aura eşleşme dene (+2 karma)
   - Tamamlanma durumu: X/3

**Görev Tamamlama Testi:**

#### Kahve Falı Görevi
1. Kahve falı sayfasına gidin
2. Bir kahve falı gönderin
3. Ana ekrana dönün
4. Quest kartında kahve falı görevinin yanında ✅ işareti görünmeli

**Not:** Görev tamamlama tracking'i henüz otomatik değil. Manuel olarak Firebase'e kayıt eklemeniz gerekebilir:

```dart
// Kahve falı tamamlandığında
await FirebaseService().recordQuestCompletion(userId, 'coffee_fortune');
```

#### Aşk Testi Görevi
1. Testler sayfasına gidin
2. Bir aşk testi çözün
3. Ana ekrana dönün
4. Quest kartında aşk testi görevinin tamamlandığını kontrol edin

#### Aura Eşleşme Görevi
1. Sosyal sayfasına gidin
2. Bir aura eşleşmesi deneyin
3. Ana ekrana dönün
4. Quest kartında aura eşleşme görevinin tamamlandığını kontrol edin

**Tüm Görevler Tamamlandığında:**
- Kartın üstünde "Tamamlandı! ✅" rozeti görünmeli
- Alt kısımda "Tüm görevleri tamamladın! Harika iş çıkardın! 🎉" mesajı görünmeli

**Firebase Kontrolü:**
```javascript
// Firestore Console'da kontrol edin
users/{userId}/daily_activities/{todayString}
// "quests" array'inde tamamlanan görevler olmalı: ["coffee_fortune", "love_test", "aura_match"]
```

---

## 3. Paylaşılabilir Kartlar

### Test Senaryosu

**Amaç:** Burç yorumlarını Instagram story formatında paylaşabilme

**Adımlar:**
1. Astroloji sayfasına gidin
2. Herhangi bir burç kartına tıklayın (örn: Koç ♈)
3. Burç detay sayfasında üst sağdaki **Paylaş** butonuna tıklayın
4. Tam ekran bir dialog açılmalı:
   - Instagram story formatında (1080x1920)
   - Üstte "Falla Aura" logosu
   - Ortada burç emoji ve ismi
   - 1-2 cümlelik kısa yorum
   - Altta "Falla Aura ile falını baktır" butonu
   - Sağ üstte Paylaş ve Kapat butonları

**Paylaşım Testi:**
1. Dialog'da **Paylaş** butonuna tıklayın
2. Sistem paylaşım menüsünü açmalı
3. Instagram Stories'i seçin
4. Kart Instagram story'de görünmeli

**Beklenen Sonuç:**
- Kart Instagram story boyutunda (9:16 aspect ratio)
- Tüm elementler düzgün görünmeli
- Paylaşım başarılı olmalı

**Sorun Giderme:**
- Eğer kart görünmüyorsa, `ShareableHoroscopeCard` widget'ının `repaintKey` ile doğru bağlandığından emin olun
- `ShareUtils.captureAndShare()` fonksiyonunun çalıştığını kontrol edin

---

## 4. Aşk Adayları Sistemi

### Test Senaryosu - Aday Listesi

**Adımlar:**
1. Alt navigasyon menüsünden **Sosyal** sekmesine gidin
2. **"İstekler"** tab'ında, "Aura Eşleş" butonunun altında **"Aşk Adaylarım"** butonunu bulun
3. "Aşk Adaylarım" butonuna tıklayın
3. Ekran şunları göstermeli:
   - Üstte açıklama: "Hoşlandığın kişileri ekle, burç ve doğum bilgilerine göre aşk uyumunu gör."
   - "Aday Ekle" butonu
   - Eğer aday yoksa: "Henüz aday eklenmedi" mesajı

### Test Senaryosu - Aday Ekleme

**Adımlar:**
1. "Aday Ekle" butonuna tıklayın
2. Form açılmalı:
   - **Avatar Seçimi (Opsiyonel):** Ortadaki avatar'a tıklayarak galeriden resim seçin
   - **İsim/Takma Ad:** Zorunlu alan, örn: "Ayşe"
   - **Doğum Tarihi:** Tarih seçiciye tıklayın, örn: 15/05/1995
   - **Burç:** Otomatik hesaplanmalı (örn: Boğa ♉)
   - **Yakınlık (Opsiyonel):** 
     - "Hoşlandığım kişi"
     - "Sevgilim"
     - "Eski sevgilim"
3. "Adayı Kaydet ve Uyum Hesapla" butonuna tıklayın

**Beklenen Sonuç:**
- Form validasyonu çalışmalı (isim boşsa hata)
- Doğum tarihi seçilmezse hata
- Burç otomatik hesaplanmalı
- Firebase'e kayıt yapılmalı
- Uyum sonucu ekranına yönlendirilmeli

**Firebase Kontrolü:**
```javascript
// Firestore Console'da kontrol edin
users/{userId}/love_candidates/{candidateId}
// Şu alanlar olmalı:
// - name: "Ayşe"
// - birthDate: Timestamp
// - zodiacSign: "Boğa"
// - relationshipType: "crush" (veya null)
// - avatarUrl: "https://..." (veya null)
```

### Test Senaryosu - Uyum Sonucu

**Adımlar:**
1. Aday kaydedildikten sonra otomatik olarak uyum sonucu ekranına yönlendirilmelisiniz
2. Ekran şunları göstermeli:
   - **Büyük Skor:** Ortada daire içinde "%82 Aşk Uyumu" gibi
   - **4 Kategori Barı:**
     - Duygusal Uyum: %70
     - İletişim Uyumu: %75
     - Uzun Vadeli Uyum: %80
     - Çekim / Tutku Uyumu: %70
   - **Detaylı Analiz:** 300-400 kelimelik AI yorumu
   - **Güçlü Yanlar:** Liste halinde 3 madde
   - **Dikkat Edilmesi Gerekenler:** Liste halinde 3 madde

**AI Analizi Testi:**
- Analiz gerçekçi ve detaylı olmalı
- Kullanıcının ve adayın burçlarına göre özelleştirilmiş olmalı
- İlişki tipi (hoşlandığım kişi/sevgilim/eski sevgilim) analize yansımalı

**Yeniden Hesaplama:**
1. Sağ üstteki **Yenile** butonuna tıklayın
2. Yeni bir analiz oluşturulmalı
3. Skorlar değişebilir (AI rastgelelik faktörü)

**Firebase Kontrolü:**
```javascript
// Firestore Console'da kontrol edin
users/{userId}/love_candidates/{candidateId}
// Şu alanlar güncellenmiş olmalı:
// - lastCompatibilityCheck: Timestamp
// - lastCompatibilityScore: 82.5
// - lastCompatibilityResult: { overallScore, emotionalCompatibility, ... }
```

### Test Senaryosu - Aday Listesi (Sonuç Sonrası)

**Adımlar:**
1. Uyum sonucu ekranından geri dönün
2. Aday listesinde:
   - Adayın avatarı görünmeli
   - İsim ve burç bilgisi görünmeli
   - Sağda son uyum skoru görünmeli (örn: %82)
   - Eğer skor yoksa, hesaplama butonu görünmeli

**Aday Silme:**
1. Bir adayın yanındaki çöp kutusu ikonuna tıklayın
2. Onay dialog'u açılmalı
3. "Sil" butonuna tıklayın
4. Aday listeden kaldırılmalı

**Aday Düzenleme:**
- Şu an için düzenleme özelliği yok
- Adaya tıklayarak yeni uyum analizi yapabilirsiniz

---

## 🔧 Manuel Test Komutları

### Firebase Console'da Kontrol

```javascript
// Günlük aktiviteleri kontrol et
db.collection('users').doc('{userId}').collection('daily_activities').doc('2024-01-15').get()

// Quest tamamlamalarını kontrol et
// "quests" array'inde: ["coffee_fortune", "love_test", "aura_match"]

// Aşk adaylarını kontrol et
db.collection('users').doc('{userId}').collection('love_candidates').get()

// Login streak'i kontrol et
db.collection('users').doc('{userId}').get()
// "loginStreak" ve "lastLoginDate" alanlarına bakın
```

### Debug İçin

```dart
// Quest tamamlama manuel ekleme (test için)
final firebaseService = FirebaseService();
await firebaseService.recordQuestCompletion(userId, 'coffee_fortune');

// Aday oluşturma (test için)
final candidateData = {
  'userId': userId,
  'name': 'Test Adayı',
  'birthDate': Timestamp.fromDate(DateTime(1995, 5, 15)),
  'zodiacSign': 'Boğa',
  'relationshipType': 'crush',
};
await firebaseService.createLoveCandidate(userId, candidateData);
```

---

## ⚠️ Bilinen Sorunlar / Notlar

1. **Quest Tracking:** Görev tamamlama henüz otomatik değil. Kahve falı, aşk testi ve aura eşleşme tamamlandığında `recordQuestCompletion()` çağrılmalı. Bu entegrasyonu ilgili ekranlara eklemeniz gerekebilir.

2. **Paylaşılabilir Kart:** Instagram story formatı sabit boyutludur (1080x1920). Farklı ekran boyutlarında görünüm test edilmeli.

3. **AI Analizi:** Uyum analizi AI tarafından üretilir, bu yüzden her seferinde farklı sonuçlar alabilirsiniz. Bu normaldir.

4. **Firebase Rules:** `love_candidates` koleksiyonu için Firebase Security Rules eklenmeli:
   ```javascript
   match /users/{userId}/love_candidates/{candidateId} {
     allow read, write: if request.auth != null && request.auth.uid == userId;
   }
   ```

---

## ✅ Test Checklist

- [ ] Streak uyarısı görünüyor mu? (streak > 0)
- [ ] Quest kartı ana ekranda görünüyor mu?
- [ ] Quest'ler tamamlandığında işaretleniyor mu?
- [ ] Tüm quest'ler tamamlandığında bonus mesajı görünüyor mu?
- [ ] Burç detay sayfasında paylaş butonu çalışıyor mu?
- [ ] Paylaşılabilir kart Instagram story formatında mı?
- [ ] Aşk adayları listesi görünüyor mu?
- [ ] Aday ekleme formu çalışıyor mu?
- [ ] Doğum tarihinden burç otomatik hesaplanıyor mu?
- [ ] Uyum analizi başarıyla oluşturuluyor mu?
- [ ] Uyum sonucu ekranı tüm bilgileri gösteriyor mu?
- [ ] Aday silme çalışıyor mu?
- [ ] Firebase'e veriler doğru kaydediliyor mu?

---

## 📞 Sorun Bildirimi

Eğer bir özellik çalışmıyorsa:

1. Console log'larını kontrol edin
2. Firebase Console'da verilerin kaydedildiğini kontrol edin
3. Network isteklerini kontrol edin (AI API çağrıları)
4. Linter hatalarını kontrol edin

**Önemli:** Tüm özellikler için kullanıcı giriş yapmış olmalıdır!

