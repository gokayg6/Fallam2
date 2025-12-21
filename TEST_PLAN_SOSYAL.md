# Sosyal Özellikler Test Planı

## 📋 Test Senaryoları - Adım Adım

### 1. Kullanıcı Kayıt ve Profil Oluşturma

#### 1.1 Yeni Kullanıcı Kaydı
- [ ] Uygulamayı aç
- [ ] "Kayıt Ol" butonuna tıkla
- [ ] Email ve şifre ile kayıt ol
- [ ] İlk girişte profil bilgileri ekranı açılmalı

#### 1.2 Doğum Tarihi Kayıt Sırasında Seçimi
- [ ] Kayıt formunda doğum tarihi alanını gör
- [ ] Doğum tarihi alanına tıkla
- [ ] Tarih seçici açılmalı
- [ ] 18 yaş altı bir tarih seç (örn: 2010-01-01)
- [ ] Burç otomatik olarak seçilmeli (doğum tarihine göre)
- [ ] "Kayıt Ol" butonuna tıkla
- [ ] Firestore'da `age` ve `ageGroup` alanlarının doğru set edildiğini kontrol et
  - `age` < 18 ise `ageGroup` = "under18" olmalı
  - `age` >= 18 ise `ageGroup` = "adult" olmalı
  - `birthDate` doğru kaydedilmiş olmalı
  - `zodiacSign` otomatik seçilmiş olmalı

#### 1.3 Profil Düzenleme ile Doğum Tarihi Ekleme/Düzenleme
- [ ] Profil ekranına git
- [ ] "Profil Düzenle" butonuna tıkla
- [ ] Doğum tarihi alanını gör
- [ ] Doğum tarihi alanına tıkla
- [ ] Tarih seçici açılmalı
- [ ] Yeni bir tarih seç (örn: 2005-05-15)
- [ ] Burç otomatik olarak güncellenmeli
- [ ] "Kaydet" butonuna tıkla
- [ ] Firestore'da `birthDate`, `age`, `ageGroup` ve `zodiacSign` güncellenmiş olmalı

#### 1.4 Yetişkin Kullanıcı Oluşturma
- [ ] Yeni bir hesap oluştur (farklı email)
- [ ] Kayıt formunda doğum tarihi alanını gör
- [ ] Doğum tarihi olarak 18 yaş üstü bir tarih seç (örn: 2000-01-01)
- [ ] Burç otomatik seçilmeli
- [ ] "Kayıt Ol" butonuna tıkla
- [ ] Firestore'da `ageGroup` = "adult" olduğunu kontrol et
- [ ] `age` >= 18 olduğunu kontrol et

---

### 2. Sosyal Görünürlük Ayarı Testi

#### 2.1 Sosyal Görünürlük Toggle'ı Kontrolü
- [ ] Sosyal sayfasına git
- [ ] "Gizlilik" sekmesine tıkla
- [ ] "Sosyal bölümde profilimi gösterme" toggle'ını gör
- [ ] Toggle'ı KAPALI yap (görünürlük AÇIK)
- [ ] Firestore'da `socialVisible` = true olduğunu kontrol et
- [ ] Toggle'ı AÇIK yap (görünürlük KAPALI)
- [ ] Firestore'da `socialVisible` = false olduğunu kontrol et

#### 2.2 Gizlilik Ayarının Etkisi
- [ ] Kullanıcı A: `socialVisible` = false yap
- [ ] Kullanıcı B: Aura eşleşme sayfasına git
- [ ] Kullanıcı A'nın listede GÖRÜNMEMESİ gerekiyor
- [ ] Kullanıcı A: `socialVisible` = true yap
- [ ] Kullanıcı B: Sayfayı yenile
- [ ] Kullanıcı A'nın listede GÖRÜNMESİ gerekiyor

---

### 3. Yaş Grubu Filtreleme Testi

#### 3.1 Aynı Yaş Grubu Eşleşmesi
- [ ] Kullanıcı A (under18): Aura eşleşme sayfasına git
- [ ] Sadece under18 kullanıcıların göründüğünü kontrol et
- [ ] Kullanıcı B (adult): Aura eşleşme sayfasına git
- [ ] Sadece adult kullanıcıların göründüğünü kontrol et

#### 3.2 Cross-Age Eşleşme Engelleme
- [ ] Kullanıcı A (under18): Bir adult kullanıcıya istek göndermeye çalış
- [ ] "Yaş kısıtlaması nedeniyle bu profil ile eşleşme yapılamaz" hatası alınmalı
- [ ] İstek gönderilememeli

#### 3.3 Doğum Tarihi Olmadan Erişim Engelleme
- [ ] Yeni bir kullanıcı oluştur
- [ ] Doğum tarihi EKLEMEDEN sosyal sayfaya git
- [ ] "Sosyal ve aura eşleşme özelliklerini kullanmadan önce profilinden doğum tarihini eklemelisin" mesajı görünmeli
- [ ] Aura eşleşme butonu çalışmamalı

---

### 4. Sosyal İstek Sistemi Testi

#### 4.1 İstek Gönderme
- [ ] Kullanıcı A (adult): Aura eşleşme sayfasına git
- [ ] Kullanıcı B (adult, aynı yaş grubu) kartını gör
- [ ] "Eşleş" butonuna tıkla
- [ ] Onay dialog'u görünmeli
- [ ] "Onayla" butonuna tıkla
- [ ] Karma kesilmeli veya ücretsiz eşleşme kullanılmalı
- [ ] Firestore'da `social_requests` koleksiyonunda yeni kayıt oluşmalı:
  - `fromUserId` = Kullanıcı A ID
  - `toUserId` = Kullanıcı B ID
  - `status` = "pending"
  - `createdAt` set edilmiş olmalı

#### 4.2 Tekrar İstek Gönderme Engelleme
- [ ] Kullanıcı A: Aynı kullanıcıya tekrar istek göndermeye çalış
- [ ] "İstek zaten gönderildi" mesajı görünmeli
- [ ] Yeni istek oluşturulmamalı

#### 4.3 Gelen İstekler Listesi
- [ ] Kullanıcı B: Sosyal sayfasına git
- [ ] "İstekler" sekmesine tıkla
- [ ] Gelen istekler listesinde Kullanıcı A görünmeli
- [ ] İstek kartında:
  - Kullanıcı A'nın adı
  - Aura rengi
  - Uyum skoru (%)
  - "Kabul Et", "Reddet", "Engelle" butonları görünmeli

#### 4.4 İstek Kabul Etme
- [ ] Kullanıcı B: Gelen istekte "Kabul Et" butonuna tıkla
- [ ] Firestore'da:
  - `social_requests` koleksiyonunda `status` = "accepted" olmalı
  - `matches` koleksiyonunda yeni match kaydı oluşmalı:
    - `users` = [Kullanıcı A ID, Kullanıcı B ID]
    - `status` = "accepted"
    - `score` set edilmiş olmalı
- [ ] "Eşleşme kabul edildi" mesajı görünmeli
- [ ] İstekler listesinden kaybolmalı
- [ ] Eşleşmeler listesinde görünmeli

#### 4.5 İstek Reddetme
- [ ] Kullanıcı A: Başka bir kullanıcıya istek gönder
- [ ] Kullanıcı C: Gelen istekte "Reddet" butonuna tıkla
- [ ] Firestore'da `social_requests` koleksiyonunda `status` = "rejected" olmalı
- [ ] "İstek reddedildi" mesajı görünmeli
- [ ] İstekler listesinden kaybolmalı
- [ ] Eşleşme oluşmamalı

#### 4.6 Kullanıcı Engelleme
- [ ] Kullanıcı A: Başka bir kullanıcıya istek gönder
- [ ] Kullanıcı D: Gelen istekte "Engelle" butonuna tıkla
- [ ] Onay dialog'u görünmeli
- [ ] "Engelle" butonuna tıkla
- [ ] Firestore'da:
  - `social_requests` koleksiyonunda `status` = "blocked" olmalı
  - Kullanıcı D'nin `blockedUsers` listesine Kullanıcı A ID eklenmeli
- [ ] "Kullanıcı başarıyla engellendi" mesajı görünmeli
- [ ] Kullanıcı A: Aura eşleşme sayfasına git
- [ ] Kullanıcı D listede GÖRÜNMEMELİ
- [ ] Kullanıcı A: Kullanıcı D'ye istek göndermeye çalış
- [ ] Engellenmiş kullanıcıya istek gönderilememeli

---

### 5. Arka Plan Kontrolleri Testi

#### 5.1 Yaş Değiştiğinde Match Pasife Alma
- [ ] Kullanıcı A (adult) ve Kullanıcı B (adult) eşleşmiş olsun
- [ ] Kullanıcı A: Profil ekranına git
- [ ] "Profil Düzenle" butonuna tıkla
- [ ] Doğum tarihi alanına tıkla
- [ ] Doğum tarihini değiştir (18 yaş altı bir tarih yap, örn: 2010-01-01)
- [ ] Burç otomatik güncellenmeli
- [ ] "Kaydet" butonuna tıkla
- [ ] Sosyal sayfaya git
- [ ] Eşleşmeler listesini kontrol et
- [ ] Firestore'da `matches` koleksiyonunda:
  - İlgili match'in `status` = "age_blocked" olmalı
- [ ] Eşleşmeler listesinde görünmemeli

#### 5.2 Yaş Kısıtlaması Olan Chat Kontrolü
- [ ] Kullanıcı A (adult) ve Kullanıcı B (adult) eşleşmiş olsun
- [ ] Sohbet açılmış olsun
- [ ] Kullanıcı A: Profil ekranına git
- [ ] "Profil Düzenle" butonuna tıkla
- [ ] Doğum tarihini 18 yaş altı yap (örn: 2010-01-01)
- [ ] "Kaydet" butonuna tıkla
- [ ] Kullanıcı A: Sohbet sayfasına git
- [ ] "Bu sohbet yaş kısıtlaması sebebiyle kapatıldı" mesajı görünmeli
- [ ] Mesaj gönderilememeli

---

### 6. Eşleşmeler Listesi Testi

#### 6.1 Eşleşmeleri Görüntüleme
- [ ] Sosyal sayfasına git
- [ ] "İstekler" sekmesinde
- [ ] Eşleşmeler bölümünde kabul edilmiş match'ler görünmeli
- [ ] Her match kartında:
  - Kullanıcı adı
  - Aura rengi
  - Uyum skoru
  - Burç bilgisi (varsa)

#### 6.2 Sohbet Açma
- [ ] Bir match kartına tıkla
- [ ] Chat detail sayfası açılmalı
- [ ] Mesaj gönderebilmeli
- [ ] Mesajlar görünmeli

---

### 7. Edge Case Testleri

#### 7.1 Boş Liste Durumları
- [ ] Hiç istek gelmemiş kullanıcı: İstekler sekmesinde "Henüz istek yok" mesajı görünmeli
- [ ] Hiç eşleşme olmayan kullanıcı: "Henüz aura uyumlu eşleşmen yok" mesajı görünmeli

#### 7.2 Çoklu İstek Durumu
- [ ] 3 farklı kullanıcıdan istek gelmiş olsun
- [ ] İstekler listesinde hepsi görünmeli
- [ ] Badge'de "3" yazmalı

#### 7.3 Aynı Kullanıcıya Karşılıklı İstek
- [ ] Kullanıcı A: Kullanıcı B'ye istek gönder
- [ ] Kullanıcı B: Kullanıcı A'ya istek gönder
- [ ] Kullanıcı B: İsteği kabul et
- [ ] Otomatik match oluşmalı
- [ ] Her iki istek de "accepted" olmalı

#### 7.4 Blocked User Kontrolü
- [ ] Kullanıcı A: Kullanıcı B'yi engelle
- [ ] Kullanıcı A: Aura eşleşme sayfasına git
- [ ] Kullanıcı B listede görünmemeli
- [ ] Kullanıcı B: Aura eşleşme sayfasına git
- [ ] Kullanıcı A listede görünmemeli (çift yönlü engelleme)

---

### 8. Firestore Security Rules Testi

#### 8.1 social_requests Koleksiyonu
- [ ] Başka kullanıcının isteklerini okumaya çalış → İZİN VERİLMEMELİ
- [ ] Kendi isteklerini okuma → İZİN VERİLMELİ
- [ ] Kendi isteğini oluşturma → İZİN VERİLMELİ
- [ ] Başkasının isteğini güncelleme → İZİN VERİLMEMELİ
- [ ] Kendi isteğini iptal etme → İZİN VERİLMELİ
- [ ] Gelen isteği kabul/reddet → İZİN VERİLMELİ

---

### 9. UI/UX Testleri

#### 9.1 Tab Geçişleri
- [ ] "İstekler" sekmesine tıkla → İstekler listesi görünmeli
- [ ] "Gizlilik" sekmesine tıkla → Gizlilik ayarları görünmeli
- [ ] Tab geçişleri smooth olmalı

#### 9.2 Badge Güncellemeleri
- [ ] Yeni istek geldiğinde badge sayısı güncellenmeli
- [ ] İstek kabul/reddedildiğinde badge sayısı azalmalı

#### 9.3 Pull to Refresh
- [ ] İstekler sekmesinde aşağı çek
- [ ] Liste yenilenmeli
- [ ] Yeni istekler görünmeli

---

### 10. Performans Testleri

#### 10.1 Çoklu İstek Yükleme
- [ ] 50+ istek olsun
- [ ] Liste hızlı yüklenmeli
- [ ] Scroll smooth olmalı

#### 10.2 Match Yükleme
- [ ] 50+ match olsun
- [ ] Liste hızlı yüklenmeli
- [ ] Yaş kontrolü her match için yapılmalı ama performans düşmemeli

---

## ✅ Test Sonuçları

Her test senaryosunu tamamladıktan sonra:
- [ ] Başarılı testleri işaretle
- [ ] Hata varsa not al
- [ ] Screenshot al (gerekirse)
- [ ] Firestore console'da verileri kontrol et

---

## 🔍 Kontrol Edilecek Firestore Koleksiyonları

1. **users**
   - `age` (int)
   - `ageGroup` ("under18" | "adult")
   - `socialVisible` (bool)
   - `blockedUsers` (array)

2. **social_requests**
   - `fromUserId` (string)
   - `toUserId` (string)
   - `status` ("pending" | "accepted" | "rejected" | "blocked")
   - `createdAt` (timestamp)
   - `updatedAt` (timestamp)

3. **matches**
   - `users` (array)
   - `status` ("accepted" | "age_blocked")
   - `score` (number)
   - `hasAuraCompatibility` (bool)

---

## 📝 Notlar

- Test sırasında Firestore Console'u açık tut
- Her adımda verilerin doğru kaydedildiğini kontrol et
- Hata durumlarında log'ları kontrol et
- Debug modunda test yap (karma kesilmesin)

