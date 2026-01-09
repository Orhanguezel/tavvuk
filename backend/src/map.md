Süper; verdiğin net cevaplar mimariyi “oturtuyor”. Şu anki ihtiyaçlarınızla **backend’i modüler (router bazlı), RBAC kontrollü, audit-log’lu, prim motoru olan, mobil-first şoför UX’ini destekleyen** bir çekirdek kurmak en doğru yaklaşım.

Aşağıdaki değerlendirmeler ve öneriler, senin mevcut Fastify modül yapına bire bir uyumlu olacak şekilde tasarlandı.

---

## 1) Netleşen Kuralların Mimariye Etkisi

### Kesin kurallar

* **Admin onayı olmadan dağıtıma çıkmaz** (driver/seller/admin kim açarsa açsın).
* **Şoför güzergâhı admin tarafından manuel belirlenir** (şehir/ilçe bazlı).
* **Eksik/fazla teslimat adet olarak tutulur** (delta quantity).
* **Aynı siparişte birden fazla tavuk cinsi olabilir** (order items gerekiyor).
* **Şehir/ilçe sabit liste** (referans tablo + import).
* **Şoför mobil-first kullanacak** (UI akışları hız/az tıklama odaklı).

Bunlar şu sonucu doğuruyor:

* Sipariş tablosu tek satır olamaz; **Order + OrderItems** tasarımı şart.
* Prim modülü için **sipariş teslim sonucunun** “kilitlendiği” bir an olmalı (delivered/partial_delivered).
* Güzergâh için **DriverRoute** / **DriverCoverage** gibi bir ilişki şart.
* Yetkilendirme backend’de katı olmalı; admin routes ayrı olsa da ayrıca **permission check** gerekir.

---

## 2) Modül Bazlı Backend Tasarımı (Tavvuk’a Uyarlama)

Mevcut app.ts yapın ideal: `/api/...` public, `/api/admin/...` admin.

Tavvuk’ta “public” kavramı yok; ama yine de ayrım mantıklı:

* `/api/auth` (login)
* `/api/orders` (seller/driver/admin: kendi kapsamı)
* `/api/driver/*` (şoför odaklı okunabilir shortcut’lar)
* `/api/admin/*` (tam yetkili yönetim)

Önerilen modüller:

### A) auth (mevcut)

* Login
* Refresh/cookie
* Session user + role claim (JWT)

### B) users / profiles (mevcut “profiles” uygunsa)

* Kullanıcılar: admin, seller, driver
* Driver ve seller’a özel alanlar: aktif/pasif, prim planı vs.

### C) locations (yeni)

* İl / ilçe referans tabloları
* Import endpoint (admin) + seed script

### D) products (tavuk cinsleri) (mevcut “products” uyarlanır)

* Tavuk cinsi (aktif/pasif)
* (Opsiyonel) birim prim varsayılanı (prim modülü ile çakışmayacak şekilde)

### E) orders (çekirdek)

* Order (müşteri + adres + durum + createdBy + assignedDriver vb.)
* OrderItems (tavuk cinsi + adet)
* DeliveryResult (teslim notu + delivered_qty + missing/excess)

### F) assignments / routes (yeni)

* DriverRoute: şoför → şehir/ilçe kapsamı
* OrderAssign: atayan admin + tarih

### G) incentives (prim) (yeni)

* Prim planı tanımı (admin girer)
* Prim hesap özeti (driver/seller bazında dönemsel)
* Prim “hesap motoru” (sipariş teslim datalarından türetir)

### H) reports (admin)

* Günlük/haftalık/aylık KPI (sipariş, tavuk adedi, başarı oranı)
* Şehir/ilçe kırılımı

---

## 3) Sipariş Modeli (Çoklu Tavuk Cinsi + Teslim Sonucu)

### Sipariş statüleri (kesinleşmiş akışa uygun)

* `draft` (isterseniz; yoksa direkt submitted)
* `submitted` (sisteme girdi)
* `approved` (admin onayladı)
* `assigned` (şoföre atandı)
* `on_delivery` (dağıtıma çıktı)
* `delivered` (tam teslim)
* `partial_delivered` (eksik/fazla var)
* `cancelled`
* `failed`

### OrderItems zorunlu

* `order_items`: `order_id`, `product_id`, `qty_ordered`
  Teslim sırasında aynı item’lar için “gerçekte teslim edilen” tutulmalı:
* Seçenek 1: `order_items` içine `qty_delivered` eklemek
* Seçenek 2 (daha temiz): `order_item_deliveries` (teslim anında yaz, audit daha iyi)

Senin ihtiyaçlar (eksik/fazla adet) için pratik çözüm:

* `order_items.qty_delivered` + `order_items.qty_delta` (delivered - ordered) veya sadece delivered tutup farkı hesaplamak.

---

## 4) Prim Modülü Tasarımı (Admin Tanımlar, Sistem Hesaplar)

Senin tarifin iki tip prim içeriyor:

1. **Tavuk başına prim** (seller ve/veya driver)
2. **Teslim başına prim** (driver ve/veya seller)

Bunu en esnek çözümle şöyle kur:

* `incentive_plans` (plan üst bilgi: aktif mi, geçerlilik tarihi, kime uygulanır)
* `incentive_rules` (satır satır kural)

  * scope: `driver` / `seller` / `admin` (admin de sipariş açabiliyor dedin)
  * trigger: `per_delivery` / `per_chicken`
  * amount: decimal
  * product_id opsiyonel (bazı tavuk cinsleri farklı prim olabilir)
  * status_filter (sadece delivered mı, partial da dahil mi)

Hesap mantığı:

* **per_delivery**: sipariş delivered/partial_delivered olduğunda 1 adet say
* **per_chicken**: teslim edilen toplam tavuk adedi üzerinden hesapla
  (burada “ordered” değil “delivered” baz alınmalı; siz eksik/fazla tutuyorsunuz)

Kritik prensip:

* Prim hesapları “her an değişebilir” olmamalı.

  * Plan değişirse geçmiş dönem etkilenmesin istiyorsanız: “plan snapshot” yaklaşımı gerekir.
  * Basit MVP: geçmiş de güncellenir (kabul edilebilir).
  * Doğru yaklaşım: teslim finalize olduğunda **o anki rule snapshot** ile “ledger” kaydı yazmak.

Benim önerim (pratik + doğru):

* MVP’de bile **ledger** tut:

  * `incentive_ledger` (order_id, user_id, role, qty_basis, amount, calculated_at)
    Bu sayede raporlama çok rahatlar.

---

## 5) Şoför Güzergâhı (Admin Manuel Belirler)

Bunu iki seviyede ele al:

1. **Kapsam tanımı**: Şoför hangi il/ilçelere gidebilir?

   * `driver_routes` (driver_id, city_id, district_id nullable)
   * district_id null ise “ilin tamamı”
2. **Atama validasyonu**: Admin bir siparişi şoföre atarken:

   * Siparişin il/ilçesi şoför kapsamına giriyor mu?
   * Uymuyorsa uyarı veya engel (tercih sizde)

Bu validasyon, hata oranını düşürür ve süreç standardize olur.

---

## 6) İl/İlçe Sabit Liste ve Import

Bu iş için sıfırdan veri yazmak yerine paket/dataset kullanmak mantıklı.

Öne çıkan seçenekler:

* `turkey-neighbourhoods` (NPM): Türkiye il/ilçe/mahalle verisi sağlıyor; “always up to date” iddiası var. ([GitHub][1])
* `turkey-cities-districts` (GitHub dataset): İl + ilçe listesi. ([GitHub][2])
* `turkiye-api` (GitHub): il/ilçe/mahalle/köy datası sağlayan bir API projesi. ([GitHub][3])
* `turkey-city-regions` (NPM/GitHub): PTT posta kodu kaynağından veri çektiğini belirtiyor. ([GitHub][4])

Backend açısından önerim:

* **DB’de cities/districts tabloları** olsun
* Bir kez import edin (seed + admin endpoint opsiyonel)
* UI’da sadece DB’den okuyun
  Bu, paketin/servisin değişmesi durumunda uygulamanın kırılmasını engeller.

---

## 7) RBAC / Yetki Tasarımı (Sizin Yapıya Uygun)

Sen zaten `userRoles` modülü kullanıyorsun; Tavvuk’ta bunu netleştirelim:

### Rol

* `admin`, `seller`, `driver`

### Yetki (permission) yaklaşımı

İki seçenek:

**Seçenek A (Hızlı, yeterli):** Role bazlı hardcoded guard

* `requireRole('admin')`
* `requireAnyRole(['admin','seller'])`

**Seçenek B (Daha esnek):** role → permissions tablosu

* `orders:create`, `orders:view_own`, `orders:assign`, `orders:approve`, `reports:view`…

Tavvuk için MVP’de A ile başlayıp, büyüyünce B’ye geçmek mantıklı.

Ek olarak “ownership” kuralı şart:

* Seller: sadece `created_by = self`
* Driver: sadece `assigned_driver_id = self` (+ kendi oluşturduğu siparişler)
* Admin: hepsi

---

## 8) Mobil-first Şoför Akışı (Backend’i Etkileyen UX)

Şoför için ekranlar genelde:

* “Bugün atanmış siparişler”
* “Dağıtımda”
* “Teslim et” (tek ekranda minimal form)
* “Yeni sipariş oluştur” (mobil hızlı)

Backend buna uygun “shortcut endpoint” ister:

* `GET /api/driver/orders?status=assigned|on_delivery`
* `POST /api/driver/orders/:id/mark-on-delivery`
* `POST /api/driver/orders/:id/deliver` (not + delivered qty)

Bu endpoint’ler admin/seller karmaşasından arınmış olur.

---

## 9) Önerilen Backend Yol Haritası (Net ve Uygulanabilir)

### Faz 1 — Temel Altyapı (1)

* Roles: admin/seller/driver
* Locations import + şehir/ilçe tabloları
* Products (tavuk cinsleri)
* Orders + OrderItems
* Admin onay akışı (submitted → approved)

### Faz 2 — Atama ve Teslimat (2)

* Admin order assign (driver)
* Driver “my orders” ekranına uygun endpoint’ler
* Teslimat sonucu (not + delivered qty + delta)
* Status akışı: assigned → on_delivery → delivered/partial

### Faz 3 — Prim (3)

* Incentive plan CRUD (admin)
* Ledger yazımı (sipariş finalize olduğunda)
* Driver/Seller prim özet endpoint’leri (günlük/aylık)

### Faz 4 — Raporlar ve Operasyon (4)

* Admin dashboard KPI
* Şehir/ilçe kırılımları
* Başarısız teslim nedenleri (opsiyonel enum)

---

## 10) Sormam Gereken Son Net Sorular (Backend şemasını kilitlemek için)

1. **Prim hesap “delivered” mi yoksa “partial_delivered” da dahil mi?**
   (Örn: eksik teslim olduysa yine de teslim başı prim var mı?)

2. **İptal/başarısız durumunda prim sıfır mı?**
   (Çoğu sistemde evet ama siz karar verin.)

3. **Siparişte adres modeli**:

   * İl/ilçe sabit, “mahalle” şart mı? (mahalle de sabit listeden mi olacak?)
     Şoför mobilde mahalle seçmek zor olabilir.

4. **Admin de sipariş açıyor dedin**: Admin siparişi açınca “seller_id” boş mu olacak, yoksa “created_by_role=admin” gibi mi?
   (Prim tarafı için önemli.)

Bu 4 soruya verdiğin cevapla, ben sana bir sonraki adımda:

* Tavvuk’a uygun **modül listesi + route sözleşmesi (endpoint taslağı)**
* **DB şema taslağı (Drizzle)**
* **validation (zod) şablonları**
  çıkaracağım; senin mevcut Fastify/Drizzle pattern’ına bire bir oturturuz.



  Anlaşıldı. Kod tarafına geçmeden, mevcut kararlarla mimariyi “kilitleyelim” ve olası çelişkileri erkenden temizleyelim. Aşağıdaki analiz, şu anki iş kurallarınızın backend tasarımına etkisini netleştirir.

---

## 1) Prim Mantığı Son Hali

### Prim tetikleyicisi

* Prim için tek kriter: **sipariş “teslim edildi” mi, “iptal” mi**
* Eksik/fazla adet farkı **prim uygunluğu için önemli değil**

### Başarısız (failed) şimdilik

* `failed` durumunda **prim = 0**
* İleride “negatif prim / ceza” eklenebilir (şimdilik yok)

Bu kararlar şu avantajı getirir:

* MVP prim hesabı çok basit olur: “delivered sayısı” (teslim başı) + “teslim edilen tavuk adedi” (tavuk başı) gibi; fakat “teslim edilen adet” yerine **sipariş item toplamı** da kullanılabilir.
* Ancak dikkat: Siz “eksik/fazla adet” tutacağınızı söylediniz; bu veriyi tutmak iyi, fakat prim hesaplamada kullanmayacaksınız. Bu da normal; rapor ve kalite takibi için saklanır.

---

## 2) Role / User Yapısı Son Hali (Çok Önemli)

Siz “tek kullanıcı birden fazla role sahip olabilir” diyorsunuz:

* Admin, aynı zamanda **seller** olabilir.
* Driver, aynı zamanda **seller** olabilir.
* Seller **sadece seller** olabilir (yani seller rolüne sahip biri admin/driver olamaz).

Bu aslında “role assignment” mantığıdır:

* Bazı kullanıcılar birden fazla role taşıyabilir.
* Ama “seller-only” diye bir kuralınız var.

Bunu teknik olarak iki şekilde modelleyebiliriz (şimdilik karar gerektirmiyor, sadece analiz):

1. **Single primary role + flags**

   * primary_role: admin/driver/seller
   * can_sell: boolean
   * Bu yaklaşım basit ama büyüyünce zorlar.
2. **RBAC (user_roles join table)**

   * user_roles: user_id + role
   * Ek kural: “seller” rolüne sahip olup “admin/driver” rolüne sahip olmayanlar = “seller-only”
   * Daha temiz ve esnek.

Sizin mevcut backend’te `userRoles` modülünüz zaten var. Bu, 2. yaklaşımı destekliyor.

---

## 3) Görünürlük Kuralları (Access Control) Son Hali

### Seller

* Sadece **kendi oluşturduğu** siparişleri görür.

### Driver

* Sadece **kendisine atanmış** siparişleri görür.
* Ayrıca **kendisi sipariş açtıysa**, o siparişi görür (atanmamış olsa bile).

### Admin

* Hepsini görür.

Burada kritik bir birleşim kuralı var:

* Driver için liste sorgusu = `(assigned_driver_id = me) OR (created_by = me)`
* Seller için liste sorgusu = `(created_by = me)` ve rol seller-only olduğundan başka istisna yok

Bu kuralın backend’de “her sorguya” uygulanması gerekir:

* Listeleme
* Detay
* Update / teslim işaretleme

---

## 4) Sipariş Akışı (En Net Hali)

* Kim açarsa açsın (admin/seller/driver): sipariş **admin onayından geçmeden** dağıtıma çıkamaz.
* Driver sahada açsa bile: admin onayı şart.

Bu, statü zincirini netleştirir:

* submitted → approved → assigned → on_delivery → delivered/cancelled
  (Araya draft koymak isterseniz koyabiliriz, ama şart değil.)

---

## 5) Lokasyon (İl/İlçe) Stratejisi

* İl/ilçe **sabit referans data** olacak.
* **Seed ile yükleyeceğiz.**

Bu karar doğru; çünkü:

* UI seçimleri tutarlı olur
* Filtreleme/raporlama doğru indekslenir
* “Serbest text kirliliği” olmaz

---

## 6) Açık Kalan, Mimariyi Etkileyen Risk Noktaları

Şu an “kodu yazmayacağız”, ama tasarım risklerini işaretlemek önemli:

### A) “Teslim edildi” tanımı

Prim için sadece “teslim edildi mi” önemli dediniz.
Burada bir tanım gerekiyor:

* “Partial teslim” var mı yok mu?
* Eğer var ve sipariş yine de “delivered” sayılacaksa, status’ta ayrı tutulmasına gerek olmayabilir; eksik/fazla sadece not/field olur.
* Eğer operasyonel raporlamada “eksik/fazla teslim” ayrı izlenecekse, `delivered` + `has_delta=true` gibi bir alan yeterli olur.

### B) Admin’in seller olması

“Admin aynı zamanda seller olabilir” dediniz.
Bu durumda:

* Admin sipariş açtığında created_by admin kullanıcıdır, ama role olarak seller davranışı da olabilir.
* Yetkilendirme açısından sorun yok; çünkü admin zaten tüm siparişleri görür.
* Raporlamada “admin-seller performansı” ayrı gösterilecek mi, yoksa admin siparişleri de seller hanesine mi yazılacak? (Şimdilik “önemli değil” dediniz; o halde default olarak yazarız.)

### C) Şoförün seller olması

Driver+seller olan kullanıcı:

* Sahada sipariş açabilir (created_by)
* Kendisine atanan siparişleri görür (assigned_driver_id)
  Bu birleşim kuralı iyi; ancak UI’da “Benim siparişlerim” iki kategoriye ayrılmalı:
* “Bana atanmış”
* “Benim oluşturduklarım”

---

## 7) Şu An İçin Net Yol Haritası (Kod Yok)

Sizin talebinize uygun şekilde “şimdi sadece analiz”:

### Aşama 1 — Sözleşme (Contract) Dondurma

* Rol matrisi (kim ne yapar)
* Sipariş statüleri
* Prim tetik kuralları
* Lokasyon modeli

### Aşama 2 — Modül Tasarım Dokümanı

* `/modules/auth`
* `/modules/userRoles`
* `/modules/orders`
* `/modules/products`
* `/modules/locations`
* `/modules/incentives`
* `/modules/reports`
  Her modül için:
* endpoint listesi
* permission check listesi
* DB entity listesi

### Aşama 3 — Şema Taslağı ve Index Planı

* Orders + OrderItems
* Assignment fields
* Incentive plan + ledger (ileriye dönük)
* Cities/Districts

---

## 8) Şu Noktayı Netleştirirsek Tasarım Tam Kilitlenir

Tek bir net soru bırakıyorum (kod değil, tasarım kararı):

**“Teslim edildi” ile “iptal” dışında “teslim edilemedi (failed)” statüsünü süreçte gösterecek miyiz, yoksa şimdilik sadece iptal mi var?**
Sen primde 0 dedin; ama operasyonda “iptal” ile “teslim edilemedi” aynı şey olmayabilir. İstersen MVP’de ikisini tek statüde de birleştirebiliriz.

Sen buna karar verince, bir sonraki adımda (yine kod yazmadan) sana:

* Tavvuk için **modül bazlı endpoint haritasını**
* **permission matrix’i**
* **DB entity şemasını** (sadece tablo/alan listesi düzeyinde)
  hazırlayıp sunayım.

Evet, bu model gayet uygulanabilir ve pratikte sık kullanılan bir RBAC kurgusu.

## 1) Önerdiğin rol kuralı

* **Admin kullanıcı:** `admin` + `seller`
* **Şoför kullanıcı:** `driver` + `seller`
* **Satıcı kullanıcı:** sadece `seller`

Bu sayede:

* Admin ve şoförün “sipariş açabilme” yetkisi seller rolünden gelir.
* Adminin yönetim yetkisi admin rolünden gelir.
* Şoförün teslimat/atanan sipariş yetkisi driver rolünden gelir.
* Satıcı yalnızca seller yetkileriyle sınırlı kalır.

Bu, mimariyi sadeleştirir.

---

## 2) Yetki matrisi (netleşsin diye)

Aşağıdaki “permission set” mantığını öneriyorum (kod değil, kural listesi):

### Seller (herkeste var, seller-only’de tek rol)

* Sipariş oluşturma
* Kendi oluşturduğu siparişleri listeleme/görme
* Kendi siparişinde temel alanları (ör. müşteri notu) güncelleme (isterseniz)

**Kritik kural:** Seller asla başkasının siparişini göremez.

### Driver (şoförlerde ek rol)

* Kendisine atanmış siparişleri görme
* Atanmış siparişte “dağıtıma çıktı / teslim edildi / not / eksik-fazla” işlemleri
* (Seller rolü sayesinde) sahada sipariş açabilme

**Kritik kural:** Driver da başkasının siparişini göremez; sadece:

* `assigned_driver_id = me` olanlar
* veya `created_by = me` olanlar

### Admin (adminlerde ek rol)

* Tüm siparişleri görme
* Onaylama
* Şoför atama
* Güzergâh tanımlama
* Prim planı tanımlama
* Raporlar

---

## 3) Veri modeline etkisi (tasarım notu)

Bu yaklaşım için backend’de en temiz model:

* `users`
* `user_roles` (user_id + role)

Roller sabit enum:

* `seller`
* `driver`
* `admin`

Ek kısıtlar (iş kuralı):

* `admin` rolü olan kullanıcıda **seller** rolü de zorunlu
* `driver` rolü olan kullanıcıda **seller** rolü de zorunlu
* `seller` tek başına olabilir

Bu kısıtları:

* Admin panelinde kullanıcı oluşturma akışında “otomatik ekleme” ile sağlayabilirsiniz (admin seçildiyse seller’ı otomatik işaretle gibi).
* İsterseniz DB’de “constraint” gibi de düşünebiliriz ama uygulama seviyesinde enforce etmek çoğu zaman yeterli.

---

## 4) Bu rol düzeniyle erişim filtresi nasıl olur?

* Seller ekranları: `created_by = currentUserId`
* Driver ekranları: `(assigned_driver_id = currentUserId) OR (created_by = currentUserId)`
* Admin ekranları: filtre yok (tümü)

Bu sizin daha önce verdiğiniz görünürlük kurallarıyla bire bir uyumlu.

---

## 5) Son kontrol sorusu (tasarımı kilitlemek için)

Admin ve şoför hem seller olduğu için ikisi de sipariş açabiliyor.
Şu ayrımı sistemde saklamak ister misiniz?

* “Bu siparişi **hangi rolde** açtı?” (admin olarak mı, şoför olarak mı, satıcı olarak mı)

Teknikte bu genelde `created_by_role` veya `source` alanı ile tutulur. Raporlama/prim kırılımı için ileride işinize yarayabilir; istemezseniz sadece `created_by` yeter.

İstersen bir sonraki adımda (kod yazmadan) bu rol modeline göre:

* modül listesi
* endpoint haritası
* permission matrix’i
* tablo/alan listesi
  hazırlayıp “backend tasarım dokümanı” gibi çıkaralım.

  Anlaşıldı. Bu durumda en doğru çerçeve şu:

* Sistemde çok sayıda **seller** ve çok sayıda **driver** var.
* Her kullanıcının **performans** ve **prim** verileri ayrı ayrı izlenecek.
* “Admin’i karıştırmayalım”: Admin zaten *superuser*; ayrıca “admin+seller” gibi rol kombinasyonlarını iş kuralı olarak zorlamaya gerek yok. Admin sipariş de açabilir; bu sadece “sipariş oluşturabilme” yetkisinin adminde de olacağı anlamına gelir.

Aşağıda, bu yaklaşımın mimariye etkisini net ve sade şekilde özetliyorum.

---

## 1) Basitleştirilmiş Rol Modeli (Öneri)

### Roller

* `admin`
* `seller`
* `driver`

### Temel kural

* **Admin**: tüm yetkiler (create dahil). Admin’in ayrıca seller rolüne sahip olmasını *zorunlu tutmayız*.
* **Seller**: sipariş oluşturur, sadece kendi siparişlerini görür.
* **Driver**: kendine atanmış siparişleri görür ve teslim sürecini yönetir; ayrıca sipariş oluşturabilir (ister “driver da create edebilir” diye permission ile verilir, ister driver’a otomatik “create order” hakkı tanımlanır).

Bu sade model, senin “admini karıştırma” isteğine tam uyuyor.

---

## 2) Görünürlük Kuralları (Değişmeden, Net)

* Seller: `created_by = me`
* Driver: `(assigned_driver_id = me) OR (created_by = me)`
  (Kendi açtığını da görebilsin diye)
* Admin: hepsi

Bu kadar.

---

## 3) Performans/Prim Takibi İçin “Doğru Veri Kaynağı”

Çok kullanıcı olduğunda “anlık hesap” yerine şu yaklaşım temiz olur:

### Sipariş finalize olunca (delivered veya cancelled)

* Sipariş “sonuca bağlandı” kabul edilir.
* O anda:

  * Performans metrikleri türetilir
  * Prim hesaplanır (plan/rule’a göre)
  * Kullanıcı bazlı kayıt (ledger) yazılır

Böylece:

* Sonradan rapor almak hızlı olur
* Her user için “benim primim / performansım” sorusu net cevaplanır

> Eksik/fazla adet sizin için prim uygunluğu açısından önemli değil dediniz; ama “tavuk başı prim” varsa hangi adet kullanılacak sorusu çıkar. Sizin kararınıza göre iki yol var:
>
> * Tavuk başı prim = **siparişte istenen toplam adet** üzerinden (en basit)
> * Tavuk başı prim = **teslim edilen toplam adet** üzerinden (eksik/fazla alanlarını gerçekten kullanmış olursunuz)
>
> Prim uygunluğu “teslim mi iptal mi” dediniz; ama tutar hesabında “adet” kriteri varsa hangi adedin baz alınacağını seçmemiz gerekecek.

---

## 4) Admin’in Sipariş Açması (Karışmasın diye net öneri)

Admin sipariş açabilir; bu durumda:

* `created_by = adminUserId`
* Sipariş yine **admin onayına** tabi (kuralınız: onaysız dağıtıma çıkmaz).
  Burada pratik bir detay: Admin kendi açtığı siparişi “auto-approved” yapabilir mi?
  İsterseniz admin açınca otomatik `approved` olabilir. İsterseniz aynı akıştan geçer.

Bu “admini karıştırmadan” yönetilebilir; sadece bir iş kuralı seçimi.

---

## 5) Panelde Görmek İstediğiniz Sayfalar (Çıktı Odaklı)

### Admin tarafı

* Kullanıcı listesi (seller/driver)
* Kullanıcı detay:

  * Teslim sayısı (gün/hafta/ay)
  * Sipariş sayısı
  * Tavuk adedi
  * Prim toplamı (dönemsel)
* Prim planı yönetimi (rule set)

### Seller tarafı

* Sipariş oluştur
* Benim siparişlerim (status takip)
* Benim performansım / primim

### Driver tarafı (mobil-first)

* Bana atananlar (büyük aksiyon butonları)
* Teslim ekranı (not + adet farkı)
* Benim performansım / primim
* Yeni sipariş oluştur

---

## 6) Tasarımı Kilitlemek İçin 3 Karar (Kod Yok)

Sen “analiz yapalım” dediğin için burada durmadan önce 3 kararın netleşmesi gerekiyor; bunlar netleşince backend tasarım dokümanı %100 kilitlenir:

1. **Tavuk başı prim hangi adetten hesaplanacak?**

   * A) siparişte istenen adet (ordered)
   * B) teslim edilen adet (delivered)

2. **Admin kendi açtığı siparişi otomatik onaylı sayalım mı?**

   * A) evet (admin create → approved)
   * B) hayır (admin create → submitted, sonra onaylar)

3. **Siparişin “owner”ı kim?**

   * Seller/driver siparişi açtıysa owner = created_by (tamam)
   * Admin açtıysa owner = admin (tamam)
   * Peki sipariş bir “müşteriye” bağlı ama “bayi” adına mı? (şimdilik yok dedin, o zaman owner = created_by yeter)

Bu üçüne verdiğin kararla bir sonraki adımda (yine kod yazmadan):

* Tavvuk modül listesi
* Endpoint haritası
* Permission matrix
* DB tablo/alan taslağı + index planı
  dokümanını çıkarırım.


  Net. Bu kararlarla prim ve performans modeli tamamen “teslim gerçekleşen miktar” merkezli oluyor ve sistem çok düzgün kapanıyor. Aşağıda son durumu, çelişkisiz şekilde “iş kuralı sözleşmesi” gibi toparlıyorum; ardından bunun veri modeline ve raporlamaya etkisini veriyorum (kod yok).

---

## 1) Prim Kuralları Son Hali (Kesin)

### 1.1 Tavuk başı prim

* Prim hesabında baz alınacak adet: **teslim edilen sağlam adet** (paid/collected bazlı, pratikte `delivered_qty`).
* Eksik teslim varsa: **sadece teslim edilen adet** kadar tavuk başı prim.

### 1.2 Sipariş başı prim

* Şoför için: sipariş **iptal edilmediyse** (yani delivered/partial gibi “teslim sayılan” bir sonuç varsa) **sipariş başı primi alır**.
* Satıcı/oluşturan için: sipariş teslim sayıldıysa, **teslim edilen tavuk adedi** üzerinden tavuk başı prim + (eğer kural tanımlıysa) sipariş başı prim.

> Önemli ayrım: Şoförün sipariş başı primi “eksik teslimden etkilenmiyor”; iptal edilmediği sürece sipariş başı prim var. Tavuk başı prim ise delivered_qty’ye bağlı.

### 1.3 Admin siparişleri

* Admin’in açtığı siparişler de **aynı havuza düşer**, aynı akıştan geçer:

  * submitted → approved → assigned → delivered/cancelled
* Admin açtıysa ve prim “oluşturana” yazıyorsa, admin kullanıcıya da ledger yazar (siz “önemli değil” dediniz; yazmakta sakınca yok).

---

## 2) Sipariş Sahipliği ve Prim Hakedişi (Netleştirme)

Bir sipariş için potansiyel prim hak sahipleri:

1. **Oluşturan (created_by)**

   * Rolü seller/driver/admin olabilir (kim açtıysa).
   * Hakediş:

     * Tavuk başı prim: `sum(item.delivered_qty)` üzerinden
     * Sipariş başı prim: (kural varsa) sipariş “teslim sayıldıysa”

2. **Teslim eden / atanan şoför (assigned_driver_id)**

   * Hakediş:

     * Sipariş başı prim: iptal değilse (teslim sayıldıysa)
     * Tavuk başı prim: `sum(item.delivered_qty)` üzerinden (kural varsa)

Bu, senin söylediğin “şoför siparişi açtıysa hem oluşturan olarak hem teslim eden olarak prim alır mı?” sorusunu da doğurur:

* **İş kuralı tercihi**: Aynı kişi hem created_by hem assigned_driver ise *çifte yazılacak mı?*

  * Benim önerim: **Evet, iki farklı rol ledger’ı olarak yazılabilir** (birisi “creator bonus”, diğeri “driver bonus”). Ama tutarları kural setiyle kontrol edersiniz.
  * Eğer istemezseniz “aynı kullanıcı ise creator legder’ını yazma” gibi bir kural eklenir.

Bu tek nokta, prim sisteminin adalet algısını etkiler; ileride tartışma çıkmasın diye baştan karar verin.

---

## 3) “Teslim Sayıldı” Kavramı (Status Tasarımı)

Sizde iki farklı “teslim” gerçekliği var:

* Sipariş başı prim için: “iptal değilse” (teslim sayıldıysa) yeterli
* Tavuk başı prim için: delivered_qty kadar

Bu nedenle statusları şu şekilde sadeleştirmek mümkün:

* `cancelled` → teslim sayılmaz
* `delivered` → teslim sayılır (tam veya eksik/fazla olabilir)
* Eksik/fazla bilgisini status yerine alanlarda tutarız:

  * `has_delta` boolean
  * `delivered_qty_total` (order-level cache)
  * item-level `delivered_qty`

Alternatif olarak `partial_delivered` ayrı status isterseniz raporlama daha okunur olur; ama iş kuralı aynı kalır.

---

## 4) Veri Modeline Etkisi (Kod Değil, Taslak)

Gereken çekirdek alanlar:

### orders

* id
* created_by (user)
* assigned_driver_id (user, nullable)
* status (submitted/approved/assigned/on_delivery/delivered/cancelled)
* city_id, district_id (FK)
* customer_name, phone, address_text
* approved_by, approved_at
* assigned_by, assigned_at
* delivered_at, delivery_note
* **delivered_qty_total** (cache / kolay rapor için)
* **is_delivery_counted** (opsiyonel; status’tan türetilir)

### order_items

* id
* order_id
* product_id (tavuk cinsi)
* qty_ordered
* **qty_delivered** (teslim edilen sağlam adet)

> Eksik/fazla ayrıca tutulacaksa:

* qty_delta = qty_delivered - qty_ordered (opsiyonel, hesaplanabilir)

### incentive_plans / rules

* per_role (seller/driver/creator vs.)
* per_delivery_amount
* per_chicken_amount
* product_id optional
* effective_from, is_active

### incentive_ledger (kesin önerim)

* order_id
* user_id
* role_context: `creator` | `driver`
* basis_deliveries: 1 or 0
* basis_chickens: delivered_qty_total
* amount_total
* calculated_at
* plan_version_id / snapshot (ileriye dönük)

Bu ledger yaklaşımı günlük 100 siparişte sizi çok rahat ettirir:

* Ay sonunda prim raporu “ledger sum” ile saniyeler içinde çıkar.
* Plan değişse bile geçmiş ledger sabit kalabilir.

---

## 5) Hacim ve Performans (100 sipariş/gün)

100/gün düşük-orta hacim; doğru indeksle her şey rahat çalışır.

Önerilen indeks mantığı (sadece konsept):

* orders(status, city_id, district_id, created_at)
* orders(created_by, created_at)
* orders(assigned_driver_id, created_at)
* ledger(user_id, calculated_at)
* ledger(order_id) unique (aynı rol_context için unique)

Bu sayede:

* Admin filtreli listeler hızlı
* Seller/Driver “benim siparişlerim” hızlı
* Prim raporları hızlı

---

## 6) Süreç Akışı Son Hali (Operasyon)

1. Sipariş oluşturulur (seller/driver/admin)
2. Havuzda görünür (admin paneli)
3. Admin onaylar
4. Admin şoför atar (güzergâh uygunluğu kontrolü varsa uygulanır)
5. Şoför teslim eder:

   * Her item için delivered qty girer (mobil minimal UI ile)
   * Not yazar
6. Sipariş delivered olur (iptal edilmezse)
7. Sistem ledger üretir:

   * Oluşturana: tavuk başı (+ varsa sipariş başı)
   * Şoföre: sipariş başı (+ varsa tavuk başı)

---

## 7) Kilit Karar: “Creator” primini kim alır?

Senin cümlen: “siparisi kim actiysa ona ait”. Bu, creator primini netleştiriyor.
Şimdi sadece şu alt detayı kesinleştirelim:

* **Creator primi sadece “seller rolüyle” açılan siparişlerde mi var, yoksa kim açarsa açsın (driver/admin dahil) creator primi var mı?**
  Sen şu an “kim açtıysa ona yaz” diyorsun; o halde **evet, driver/admin de creator primi alır**. Bu kabul ise tasarım tamam.

Eğer bu kabul ise, bir sonraki adım olarak (hala kod yazmadan) şunları çıkaracağım:

* Endpoint haritası (auth, orders, admin orders, driver endpoints, incentives, reports)
* Permission matrix (role → allowed actions)
* DB tablo/alan listesi (Drizzle’a bire bir aktarılabilir düzeyde)
* Mobil şoför “teslim ekranı” için alan minimizasyonu (hangi alanlar zorunlu)

Hazır olduğunda “tamam, dokümanı çıkar” dediğinde devam edelim.



Aşağıda Tavvuk için, bugünkü kararlarla uyumlu **Backend Tasarım Dokümanı (v1 / MVP + Prim Modülü)** yer alıyor. Bu doküman **kod içermez**; modüller, endpoint sözleşmeleri, yetki matrisi, veri modeli (tablo/alan listesi), iş akışları, raporlama ve indeks planını kapsar.

---

# Tavvuk Backend Tasarım Dokümanı (v1)

## 0) Amaç ve Kapsam

Tavvuk; satıcıların ve şoförlerin sipariş açtığı, admin’in siparişleri onaylayıp şoför atadığı, şoförün teslimat sonuçlarını (teslim edilen adet + not) girdiği ve sistemin **prim/performance** hesaplayıp kullanıcı bazında raporladığı bir yönetim panelidir.

* Public sayfa yok.
* Mobil-first öncelik: şoför ekranları.
* Ortalama hacim: ~100 sipariş/gün.

---

## 1) Roller ve Yetki Prensipleri

### Roller

* **admin**
* **seller**
* **driver**

Sistemde:

* Birden fazla seller ve birden fazla driver var.
* Admin “superuser”: tüm yetkilere sahiptir ve sipariş de açabilir.
* Driver sipariş açabilir.
* Seller sadece seller yetkileriyle sınırlıdır.

### Görünürlük Kuralları (Zorunlu)

* **Seller**: yalnızca `created_by = me` olan siparişleri görür.
* **Driver**: `assigned_driver_id = me` olan siparişleri görür; ayrıca `created_by = me` olan siparişleri de görür.
* **Admin**: tüm siparişleri görür.

### Prim Çifte Yazım Kuralı (Kesin)

Aynı kullanıcı hem `created_by` hem `assigned_driver_id` ise:

* **Oluşturucu (creator)** olarak tavuk başı prim + (kural varsa) sipariş başı prim alır.
* **Şoför (driver)** olarak sipariş başı prim + (kural varsa) tavuk başı prim alır.
  Yani ledger’da **iki ayrı kayıt** oluşabilir (role_context üzerinden ayrılır).

---

## 2) Sipariş Yaşam Döngüsü ve İş Akışı

### Temel Akış (Kesin)

1. Sipariş oluşturulur (seller/driver/admin)
2. Sipariş “havuz”a düşer (admin listesinde)
3. Admin onaylar (onaysız dağıtıma çıkmaz)
4. Admin şoför atar
5. Şoför teslim ekranında:

   * Ürün bazında teslim edilen adetleri girer (`qty_delivered`)
   * Not yazar
6. Sipariş “teslim sayıldı” olur (cancel olmadıkça)
7. Sistem prim ledger üretir (creator ve driver için ayrı ayrı)

### Status Önerisi (MVP)

* `submitted` (sipariş açıldı, havuzda)
* `approved` (admin onayladı)
* `assigned` (şoför atandı)
* `on_delivery` (opsiyonel; isterseniz ekleyin)
* `delivered` (teslim sayıldı)
* `cancelled` (iptal)

Not: “Eksik teslim” ayrı status olmak zorunda değil; çünkü prim uygunluğu “iptal mi değil mi” ile belirleniyor. Eksik/fazla zaten item bazında `qty_delivered` ile izlenir.

---

## 3) Prim Kuralları ve Hesap Mantığı

### 3.1 Prim Uygunluğu

* **Sipariş başı prim**: sipariş iptal değilse (delivered ise) ödenir.
* **Tavuk başı prim**: **teslim edilen sağlam adet** üzerinden hesaplanır.
  Baz = `sum(order_items.qty_delivered)`.

### 3.2 Kural Tipleri (Admin belirler)

* `per_delivery` (sipariş başına)
* `per_chicken` (tavuk başına)
* Kural hedefi:

  * `creator` (siparişi açana)
  * `driver` (teslim eden şoföre)
* Kural ürün bazlı olabilir (opsiyonel): `product_id` ile.

### 3.3 Ledger (Önerilen – MVP’de de olmalı)

Sipariş delivered olduğunda ledger yazılır:

* creator için 1 satır
* driver için 1 satır (assigned_driver_id varsa)

Ledger; plan değişse bile geçmişi sabit tutar ve raporlamayı hızlandırır.

---

## 4) Modül Listesi (Fastify Router Bazlı)

Sizin mevcut yapı ile uyumlu biçimde önerilen modüller:

### 4.1 auth

* login/logout/me

### 4.2 users (veya mevcut profiles’i Tavvuk’a uyarlama)

* kullanıcı listesi (admin)
* kullanıcı detay (admin)
* rol atama (admin)

### 4.3 userRoles

* user_roles yönetimi (admin)

### 4.4 locations

* cities
* districts
* seed/import (admin)

### 4.5 products

* tavuk cinsleri (aktif/pasif)

### 4.6 orders (core)

* sipariş oluşturma/listeleme/detay
* admin onay & atama & admin listeleme
* driver teslim endpoint’leri

### 4.7 routes (driver coverage)

* driver güzergâh kapsamı (admin tanımlar)

### 4.8 incentives

* prim planı + kurallar CRUD (admin)
* ledger ve özet rapor endpoint’leri

### 4.9 reports

* günlük/haftalık/aylık performans & prim özetleri (admin)

---

## 5) Endpoint Sözleşmesi (Öneri)

Aşağıdaki yollar “/api” altında toplanır. Admin yolları `/api/admin/...` kullanır.

### 5.1 Auth

* `POST /api/auth/login`
* `POST /api/auth/logout`
* `GET  /api/auth/me`

### 5.2 Locations

* `GET /api/locations/cities`
* `GET /api/locations/districts?city_id=...`

Admin:

* `POST /api/admin/locations/import` (seed/import tetikleme; opsiyonel)
* `GET  /api/admin/locations/stats` (kaç city/district yüklü)

### 5.3 Products (Tavuk Cinsleri)

* `GET /api/products` (aktif liste; tüm roller görebilir)

Admin:

* `POST /api/admin/products`
* `PATCH /api/admin/products/:id`
* `GET /api/admin/products` (tüm liste)

### 5.4 Orders (Seller/Driver ortak)

* `POST /api/orders`

  * customer + adres + items (product + qty_ordered)
  * status = submitted
* `GET /api/orders`

  * seller: own only
  * driver: assigned OR created_by
* `GET /api/orders/:id`

  * aynı görünürlük kuralı

> Satıcı/şoför tarafında “update” ihtiyacı varsa (MVP’de minimal tutmak için):

* `PATCH /api/orders/:id` (yalnızca submitted durumunda, own order için)

### 5.5 Driver operasyon endpoint’leri (mobil kolaylık)

* `GET /api/driver/orders` (assigned + created_by filtreli hızlı liste)
* `POST /api/driver/orders/:id/mark-on-delivery` (opsiyonel)
* `POST /api/driver/orders/:id/deliver`

  * item delivered qty + note
  * status → delivered

### 5.6 Admin Orders

* `GET /api/admin/orders`

  * filtreler: status, city_id, district_id, date_from/date_to, q (telefon/ad)

* `POST /api/admin/orders/:id/approve`

* `POST /api/admin/orders/:id/assign-driver`

  * driver_id
  * (opsiyonel) güzergâh uygunluk kontrolü: driver_routes üzerinden

* `POST /api/admin/orders/:id/cancel`

  * cancel_reason (opsiyonel)

### 5.7 Driver Routes (Güzergâh/Kapsam)

Admin:

* `GET /api/admin/drivers`
* `GET /api/admin/drivers/:id/routes`
* `PUT /api/admin/drivers/:id/routes`

  * city + district kapsam listesi
  * district null → ilin tamamı

### 5.8 Incentives (Prim Planı)

Admin:

* `GET /api/admin/incentives/plans`
* `POST /api/admin/incentives/plans`
* `PATCH /api/admin/incentives/plans/:id` (aktif/pasif, effective_from)
* `GET /api/admin/incentives/plans/:id/rules`
* `PUT /api/admin/incentives/plans/:id/rules` (tam replace)

Rapor/Özet:

* `GET /api/admin/incentives/summary?from=...&to=...&role_context=creator|driver&user_id=...`
* `GET /api/incentives/my-summary?from=...&to=...` (seller/driver kendi)

Ledger (admin debug için):

* `GET /api/admin/incentives/ledger?order_id=...`
* `GET /api/admin/incentives/ledger?user_id=...&from=...&to=...`

### 5.9 Reports

Admin:

* `GET /api/admin/reports/kpi?from=...&to=...`
* `GET /api/admin/reports/users/performance?from=...&to=...&role=seller|driver`
* `GET /api/admin/reports/locations?from=...&to=...` (il/ilçe kırılımı)

---

## 6) Yetki Matrisi (Permission Matrix)

| Aksiyon              | seller |                driver | admin |
| -------------------- | -----: | --------------------: | ----: |
| Sipariş oluştur      |      ✓ |                     ✓ |     ✓ |
| Sipariş listele      |    own |        assigned ∪ own |   all |
| Sipariş detay        |    own |        assigned ∪ own |   all |
| Sipariş onay         |      ✗ |                     ✗ |     ✓ |
| Şoför atama          |      ✗ |                     ✗ |     ✓ |
| Teslim gir           |      ✗ | ✓ (assigned veya own) |     ✓ |
| Prim planı yönet     |      ✗ |                     ✗ |     ✓ |
| Prim özet (kendi)    |      ✓ |                     ✓ |     ✓ |
| Raporlar             |      ✗ |                     ✗ |     ✓ |
| Lokasyon seed/import |      ✗ |                     ✗ |     ✓ |

---

## 7) Veri Modeli (Tablo ve Alan Taslağı)

> İsimlendirme ve alan tipleri Drizzle/MySQL’e uygun şekilde sonradan netleştirilecek. Burada amaç “şema kontratı”dır.

### 7.1 users

* id (uuid)
* name, phone, email (opsiyonel)
* is_active
* created_at, updated_at

### 7.2 user_roles

* user_id
* role: `admin|seller|driver`
* (unique: user_id + role)

### 7.3 cities

* id (int veya varchar code)
* name

### 7.4 districts

* id
* city_id
* name

### 7.5 products (tavuk cinsleri)

* id
* name
* is_active
* created_at, updated_at

### 7.6 orders

* id (uuid)
* created_by (user_id)
* status (submitted/approved/assigned/on_delivery/delivered/cancelled)
* city_id, district_id
* address_text
* customer_name
* customer_phone
* note_internal (opsiyonel; admin notu)
* approved_by, approved_at
* assigned_driver_id (nullable)
* assigned_by, assigned_at
* delivered_at
* delivery_note (driver note)
* **delivered_qty_total** (cache; sum of items delivered)
* created_at, updated_at

### 7.7 order_items

* id
* order_id
* product_id
* qty_ordered
* **qty_delivered** (default 0; deliver ekranında girilir)
* created_at, updated_at

### 7.8 driver_routes (kapsam/güzergâh)

* id
* driver_id (user_id)
* city_id
* district_id (nullable: tüm il)
* created_at

### 7.9 incentive_plans

* id
* name
* is_active
* effective_from (date)
* created_by (admin user)
* created_at, updated_at

### 7.10 incentive_rules

* id
* plan_id
* role_context: `creator|driver`
* rule_type: `per_delivery|per_chicken`
* amount (decimal)
* product_id (nullable)  // per_chicken + product bazlı
* is_active (opsiyonel)
* created_at, updated_at

### 7.11 incentive_ledger

* id
* order_id
* user_id
* role_context: `creator|driver`
* deliveries_count (0/1)
* chickens_count (delivered_qty_total veya product breakdown’dan gelen)
* amount_total (decimal)
* plan_id (hangi planla hesaplandı)
* calculated_at

**Unique kural önerisi:**

* (order_id, user_id, role_context) unique
  Aynı sipariş için aynı kullanıcı/rol_context ledger’ı tekrar yazılmasın.

---

## 8) Prim Hesaplama Motoru (İşleyiş)

### Tetik

* Sipariş `delivered` durumuna geçtiğinde çalışır.

### Veri

* `delivered_qty_total` = `sum(order_items.qty_delivered)`
* active plan = `incentive_plans.is_active = 1` ve `effective_from <= delivered_at` (en günceli seç)

### Ledger üretimi

1. Creator ledger:

   * user = orders.created_by
   * deliveries_count = 1
   * chickens_count = delivered_qty_total
   * amount_total = (per_delivery + per_chicken * chickens_count) (product bazlı rule varsa item bazında)

2. Driver ledger:

   * user = orders.assigned_driver_id (varsa)
   * deliveries_count = 1 (iptal değilse)
   * chickens_count = delivered_qty_total
   * amount_total aynı kural mantığıyla

> Eğer sipariş iptal edilirse ledger yazılmaz.
> Eğer ileride “failed/ceza” eklenirse ledger negatif olabilir; şimdilik yok.

---

## 9) Listeleme ve Filtreleme Gereksinimleri

### Admin sipariş listesi

* status (default: submitted/approved/assigned)
* şehir/ilçe
* tarih aralığı
* arama: müşteri adı/telefon
* göstereceği özet: ürün cinsi ve toplam adet (ordered/delivered), kim açtı, hangi şoför

### Seller sipariş listesi

* status
* tarih aralığı
* kendi siparişleri

### Driver sipariş listesi (mobil)

* “Bana atanmış” (default)
* “Benim açtıklarım”
* hızlı aksiyon: teslim et

---

## 10) İndeks Planı (Öneri)

Hacim 100/gün olsa bile filtreli admin listesi ve ledger raporları için:

* orders:

  * (status, created_at)
  * (city_id, district_id, created_at)
  * (created_by, created_at)
  * (assigned_driver_id, created_at)

* order_items:

  * (order_id)
  * (product_id)

* incentive_ledger:

  * (user_id, calculated_at)
  * (order_id)
  * unique(order_id, user_id, role_context)

* driver_routes:

  * (driver_id)
  * (city_id, district_id)

---

## 11) MVP’de Bilinçli Olarak Dışarıda Bırakılanlar

* Maaş takibi
* Negatif prim / ceza
* Offline çalışma (ileriye bırakıldı)
* Müşteri CRM / tekrar eden müşteri profili (sipariş bazlı kalıyoruz)
* Tahsilat/ödeme detayları (sadece “teslim edilen sağlam adet” varsayımı)

---

## 12) Kabul Kriterleri (MVP Done Definition)

* Seller/Driver/Admin sipariş açar → admin havuzunda görünür.
* Admin onaylamadan sipariş şoföre atanamaz veya dağıtıma çıkamaz (süreç kilidi).
* Admin şoför atar → şoför mobil listede görür.
* Şoför teslim eder: item bazında `qty_delivered` + not girer → sipariş delivered olur.
* Sistem ledger üretir:

  * Creator (kim açtıysa) tavuk başı + (varsa) sipariş başı
  * Driver sipariş başı + (varsa) tavuk başı
  * Aynı kişi creator+driver ise iki ayrı ledger satırı oluşur.
* Admin kullanıcı prim/performance raporlarını kişi bazında görebilir.

---

## 13) Son Onay İçin 5 Maddelik Kontrol Listesi

Aşağıdakiler “doküman doğru mu?” kontrolü içindir; cevap istemiyorsan varsayılanı uygulayacağız:

1. Sipariş başı prim **creator** için de var mı, yoksa sadece driver için mi?
   (Dokümanda iki role_context için de mümkün kabul ettim.)

2. Driver teslim ekranında `qty_delivered` ürün bazında zorunlu mu?
   (Ben zorunlu kabul ettim.)

3. `on_delivery` status’u istiyor musunuz?
   (Opsiyonel bıraktım.)

4. İptal sadece admin mi yapacak?
   (Dokümanda admin varsaydım.)

5. Driver’a atanmadan sipariş delivered olabilir mi? (örn. admin açtı, kendisi teslim etti)
   (MVP’de “deliver” endpoint’ini role bazlı kısıtlayarak engelleyebiliriz; ama isterseniz admin teslim edebilir.)

---

Hazırsanız bir sonraki adım (hala kod yazmadan) şu iki çıktıyı da üretebilirim:

1. **Endpoint request/response payload şemaları** (örnek JSON kontratları)
2. **Ekran akışları** (admin/seller/driver için sayfa listesi ve kullanıcı yolculukları)

“Payload şemalarını da çıkar” dersen devam edeyim.



