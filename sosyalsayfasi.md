fAura eşleşmesi
Yaş Grupları ve Eşleşme Kısıtı
Amaç: 18 yaş altı kullanıcıların, 18 yaş ve üzeri kullanıcılarla eşleşmemesi ve birbirlerinin listelerinde
hiç görünmemesi.
1. Doğum Tarihi Zorunlu
o Aura eşleşme ve sosyal kısım (keşfet/kişiler) kullanılmadan önce kullanıcıdan doğum
tarihi kesin olarak alınsın.
o Yaş, sunucu tarafında currentDate - birthDate ile hesaplanacak, client’tan gelen “age”
değişkenine güvenilmeyecek.
2. Yaş grubu alanı
o users koleksiyonunda/tabloda:
▪ age (int)
▪ ageGroup (string: "under18" / "adult")
o age < 18 → under18
o age >= 18 → adult
3. Match query filtresi
Aura eşleşmesi için aday kullanıcı listesi çekilirken:
o ageGroup == currentUser.ageGroup şartı zorunlu olsun.
o Yani:
▪ under18 kullanıcı, sadece under18 kullanıcıları görsün.
▪ adult kullanıcı, sadece adult kullanıcıları görsün.
o Bu filtre:
▪ Swipe ekranı
▪ “Önerilen eşleşmeler”
▪ Random/keşfet listeleri
hepsinde geçerli olmalı. Hiçbir yerde cross-age görünmeyecek.
4. Arka plan kontrolleri
o Mevcut eşleşme/sohbetlerde, sistem sonradan yaşı değişen ya da yanlış girip
düzelten kullanıcılar için:
▪ Eğer iki taraftan biri under18, diğeri adult durumuna düşüyorsa;
▪ İlgili match kaydı pasife alınsın (örn. status = "age_blocked"),
▪ Sohbet kanalında da “Bu sohbet yaş kısıtlaması sebebiyle kapatıldı.”
tarzı uyarı gösterilebilsin (server tarafında flag).
2. Sosyal Görünürlük (Gizlilik Ayarı)
Amaç: Kullanıcı isterse sosyal bölümde hiç gözükmesin; isteyen sadece fal vs. kullanmaya devam
edebilsin.
1. Yeni ayar alanı
users tablosuna/collection’a:
o socialVisible (bool, default: true) eklensin.
2. Ayar ekranı
o Ayarlarda veya Aura/Sosyal sekmesinde toggle:
▪ Metin örneği: “Sosyal bölümde profilimi gösterme”
▪ Açık = görünmüyor, Kapalı = görünüyor şeklinde olabilir (ya da tam tersi, UI’ya
göre).
3. Filtreleme
o Sosyal/swap/eşleşme listeleri çekilirken:
▪ socialVisible == true şartı zorunlu olsun.
o socialVisible == false olan kullanıcı:
▪ Hiçbir “keşfet”, “yakındakiler”, “önerilenler”, “aura eşleşmesi listesi”
ekranlarında görünmesin.
o Ancak:
▪ Mevcut eşleşmeleri ve geçmiş sohbetleri kullanmaya devam edebilsin (yani
sadece keşfet tarafında gizlilik).
3. Sosyal Kısımda “Gelen İstekler” Bölümü
Amaç: Kullanıcıya gelen bağlantı/eşleşme isteklerini ayrı bir sekmede toplamak.
1. İstek modeli
Yeni koleksiyon/tablo: social_requests (isim sana kalmış). Önerilen alanlar:
o id
o fromUserId (isteği gönderen)
o toUserId (isteği alan)
o status (string: "pending", "accepted", "rejected", "blocked")
o createdAt, updatedAt (timestamp)
2. Gönderim mantığı
o Kullanıcı A, B’nin profiline veya eşleşme kartına tıkladığında “Bağlantı isteği gönder” /
“Connect” butonu olsun.
o Tıklandığında:
▪ Eğer A ve B aynı ageGroup’ta değilse → backend direkt reddetsin (ekstra
güvenlik).
▪ Aynı ise: social_requests koleksiyonuna status = "pending" ile kayıt atılsın.
o Aynı ikili arasında açıkta pending kayıt varsa, tekrar gönderilemesin (check).
3. Gelen istekler ekranı (Social > Requests)
o Sosyal sekmesinde 2 tab önerisi:
▪ Keşfet (veya Eşleşmeler)
▪ Gelen İstekler
o “Gelen İstekler” listesinde:
▪ toUserId == currentUserId ve status == "pending" olan tüm kayıtlar çekilsin.
o Her card’da:
▪ Gönderen kişinin mini profili (foto, burç, yaş aralığı, aura vs.)
▪ 2 buton: Kabul et / Reddet (isteğe bağlı olarak “Engelle” de eklenebilir).
4. Aksiyonlar
o Kabul et:
▪ status = "accepted"
▪ İki kullanıcı için arkadaş/match kaydı oluştur. (Mevcut match sistemine veya
ayrı social_links tablosuna bağlayabilirsin.)
▪ Opsiyonel: Otomatik sohbet kanalı oluştur.
o Reddet:
▪ status = "rejected"; tekrar isteğe izin verilebilir veya belirli bir süre
bloklanabilir (senin mantığa göre).
o Engelle (varsa):
▪ Kullanıcı B, A’yı engellemek isterse:
▪ Hem isteği “blocked” yap,
▪ Hem de blockedUsers listesine ekle (B tarafı için).
▪ Böylece A, B’ye tekrar istek gönderemesin; keşfet listesinde de
görünmesin.
4. Özet (Developer TL;DR)
• Kullanıcı yaşı zorunlu → age + ageGroup (under18/adult) alanları.
• Match / discover sorgusu: aynı ageGroup + socialVisible == true filtreleri ile çalışacak.
• < 18 ve ≥ 18 kullanıcılar birbirlerini hiçbir listede görmeyecek, eşleşmeyecek.
• Kullanıcıya “Sosyal bölümde profilimi gösterme” tarzı bir toggle → socialVisible false ise hiçbir
keşfet / eşleşme listesinde görünmeyecek.
• Sosyal sekmede “Gelen İstekler” tab’ı: social_requests tablosu ile pending istekleri listele,
Accept/Reject/Block aksiyonları tanımla.
