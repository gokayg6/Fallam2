🧿 Falla Aura — Teknik Özellikler ve Yapı Dökümanı
⚙ 1. Genel Mimari

Frontend: Flutter (Material + Custom Shader Effects)

Backend: Firebase (Firestore, Auth, Storage, Functions)

AI Servisleri: OpenAI / VertexAI / Local model (tarot, fal, aura)

Tema: Mistik, koyu, parıltılı mor & pembe degrade arayüz

Veritabanı Şeması (Firestore):

users: kullanıcı profilleri, burç, doğum tarihi, ruh hali, aura verileri

readings: kahve/tarot/rüya sonuçları

matches: aura eşleşmeleri (eşleşme yüzdesi)

tests: aşk, ilişki, kader, kişilik test sonuçları

biorhythm: fiziksel, duygusal, zihinsel döngü hesapları

karma: uygulama içi puan sistemi (madalya, enerji vs.)

☕ 2. Fal Türleri Modülü (fal_module)+
2.1 Kahve Falı (Coffee Reading)

Upload: Kullanıcı 3-5 fotoğraf yükler (fincan, tabak,)

AI Pipeline: Firebase Storage → Cloud Function →  GPT yorumlama

Output: JSON → {“title”: “Kalp sembolü”, “meaning”: “Yakında aşk haberi alacaksın.”}

UI: Misty loading animasyonu + yazı yavaş yavaş oluşur

2.2 Tarot Falı

Deck: 22 Major Arcana + 56 Minor Arcana

Randomizer: SecureRandom + enerji etkisi (kullanıcının ruh hali, doğum günü seed)

AI yorum: Kart başına + genel özet

Ek: “Kader çarkı” animasyonu kart seçimi için

2.3 Rüya Yorumu & Rüya Çiz+

Input: Kullanıcı metin veya ses girişiyle rüya anlatır

AI: Natural Language → sembol tanıma → anlam tablosu eşleşmesi

Rüya Çiz: Stable Diffusion API ile görselleştirme (isteğe bağlı)

Yorum Output: {tema, semboller, genel mesaj, ruhsal uyarı}

2.4 El Falı+


💞 3. Aşk ve İlişki Testleri (love_module)+
3.1 Aşk Uyumu Testi

Input: İki kişinin doğum tarihi, burcu, isim

Hesaplama:

Numeroloji + burç uyumu + AI yorumlama

Yüzde skor + kısa açıklama

3.2 Ruh Eşi Analizi

Input: Kullanıcının doğum bilgisi + aura renkleri + AI tahmini

AI Model: Embedding similarity (kullanıcı kişilik vektörü → potansiyel eşler)

Eşleşme: Firestore’daki diğer kullanıcılarla % benzerlik hesaplanır

UI: Swipe arayüz (Tinder benzeri), üstte “% aura uyumu” etiketi

3.3 İlişki Testleri

Soru tabanlı testler: JSON formatlı (lokal veya Firestore)

Sonuçlar:

romantik tip, bağlılık seviyesi, özgürlük eğilimi

görsel/emoji bazlı sonuç kartları (ör: 🔥 Tutkulu Aşık)

🌈 4. Aura Sistemi (aura_module)

Amaç: Kullanıcının ruhsal enerjisini, rengine ve dalgasına göre analiz eder

Inputlar:

Günlük ruh hali

Son uyku süresi (manuel veya otomatik)

Doğum tarihi + burç

Günün duygusu (seçim: mutlu, yorgun, stresli vb.)

Hesaplama:

Aura rengi: HSV temelli duygusal harita

Aura açıklaması: AI prompt temelli açıklama

Aura frekansı: 0–100 arası (enerji seviyesi)

UI:

3D parıltılı halka animasyonu (CustomPainter + Shader)

“Aura Güncelle” butonu → yeni analiz + animasyon

🔮 5. Aura Eşleşme (Match System)

Veri: Aura rengi, frekans, ruh hali, burç, cinsiyet, yaş

Algoritma: K-Means cluster veya cosine similarity

UI: SwipeCards → Her kartta

Profil foto

Aura rengi efekti

Uyum yüzdesi (ör: %92 Uyumlu)

“Bağlantı kur” butonu → Firestore’da match kaydı

🧘 6. Biyoritim Modülü (biorhythm_module)+

Input: Kullanıcının doğum tarihi + bugünün tarihi

Formül:

Fiziksel: sin((2π * gün sayısı)/23)

Duygusal: sin((2π * gün sayısı)/28)

Zihinsel: sin((2π * gün sayısı)/33)

UI:

3 çizgili grafik (Recharts veya Flutter Chart lib)

Günlük denge puanı (ortalama 0–100)

“Bugün zihinsel enerjin yüksek” gibi AI yorumu

🪙 7. Karma / Enerji Sistemi

Amaç: Kullanıcıların uygulama içi aktivitelere göre puan kazanması

Kazanma yolları:

Fal baktırma: +5

Günlük giriş: +2

Test tamamlama: +3

Aura paylaşımı: +1

Firestore alanı: users/{uid}/karma

UI: Üstte sabit “✨ Karma: 128” göstergesi (Header’da)

🌙 8. Günlük Burç & Astroloji++

Veri: Günlük olarak Firestore’a AI tarafından eklenen 12 burç yorumu

Kullanıcı: Kendi burcuna özel dinamik kart

Ek: “Yarın için önsezi” butonu (AI random seed + kişisel aura etkisi)

🎲 9. Kader Çarkı & Oyna-Kazan+

Randomizer: SecureRandom → 10 sonuçtan biri (aura parıltısı, enerji, mini fal)

UI: Dönen mistik çark animasyonu

Ödül: Karma puanı veya özel fal hakkı

Firestore: spins/{uid} → spin cooldown (24h)

💫 10. Altın / Coin Sistemi (isteğe bağlı)

Kullanım: Premium fallar, özel testler, aura yeniden analiz

Satın Alma: Firebase Billing / Shopier entegrasyonu

Tablo: coins → { balance, last_spent, premium_features }

🪄 11. Görsel & Animasyon Teknikleri

Shaderlar:

MistGlow → pembe-mor aura dalgası

Starfield → yavaş kayan arka plan

NeonText → titreşimli yazı animasyonu

Transitionlar: Hero → fade + blur efekt

CustomPainter: Aura çemberi, kader çarkı, biyoritim grafiği

🧩 15. Gelecek Geliştirmeler

Aura bazlı sohbet odası (aynı renkten kullanıcılar)

Ruh hali takibi (haftalık değişim grafiği)

“Canlı Falcı” canlı konuşma modu (coming soon) şu anlık pasif gözükebilir.

iOS / Android özel push bildirimleri (Firebase Messaging)+

---

✅ Yapılanlar (Özet)

- Kader Çarkı (Spin Wheel): UI + ödül dağıtımı + 24h cooldown (Firestore `users/{uid}/spins/state`).
- AI Servisi: GPT-4o-mini metin, gpt-image-1 görsel (Dream Draw entegrasyonu ve hata yönetimi).
- Dream: “Rüyamı Çiz” butonu hem sonuç ekranında hem ana sayfada; çizim ekranı prompt+stil seçenekleriyle çalışır.
- Fal Akışları: Kahve, Tarot, Rüya, El, Katina, Su – tekleştirilmiş model ve `FortuneService` ile kayıt.
- Ana Ekran: Kartlar `AnimatedCard` ile standartlaştırıldı; Diğer Özellikler düzenlendi.
- Günlük Burç: AI üretimi + Firestore cache (`horoscopes/{YYYY-MM-DD}` tek doküman, `texts/shorts` alanları), kısa özet düzeltildi.
- Günlük Burç: Detay ekranda “Yarın için önsezi” butonu; AI ile üretip aynı şemaya (`texts/shorts`) kaydediyor ve modalda gösteriliyor.
- Profil sekmesi: `MainScreen`’de Profil tabı `ProfileScreen`e yönlendiriyor.
- Kader Çarkı ekranında karma göstergesi (AppBar ve çark üstü rozet).
- MysticalButton: metin taşmaları için esnek/ellipsis; projenin buton standardı olarak kullanıldı.
- Canlı Sohbet: Diğer Özellikler’de Numeroloji yerine “Canlı Sohbet” kartı.
- Biyoritim: Ana ekrana “Biyoritim” kartı eklendi (navigasyon hazır).
- Ruh Eşi Analizi: Firestore’dan kullanıcı çekme, basit uygunluk skoru, Tinder benzeri tek kartlık PageView UI.
- Ruh Eşi Analizi: "Bağlantı kur" → `matches` koleksiyonuna kayıt (rules eklendi).
- Firestore Kuralları: `users/*` authenticated read açık; `horoscopes/*` read/write açık; `readings` sahip tabanlı erişim.