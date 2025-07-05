# Proje: Yeşil Yol - Görev Listesi

Bu dosya, "Yeşil Yol" projesinin geliştirme adımlarını ve görevlerini takip etmek için oluşturulmuştur.

### Teknik Plan Özeti

*   **Frontend:** Flutter
*   **Backend:** Node.js (Express.js)
*   **Veritabanı:** PostgreSQL + PostGIS
*   **Harita Servisi:** Google Maps Platform
*   **Altyapı:** Docker

---

### Geliştirme Görev Listesi (To-Do List)

**Aşama 1: MVP (Minimum Uygulanabilir Ürün) - Temel Kurulum ve Çekirdek Fonksiyonlar**
*   [x] Proje yapısının oluşturulması (Backend ve Flutter için klasörlerin ve temel dosyaların hazırlanması).
*   [x] Gerekli teknolojilerin (Flutter, Node.js, Docker) geliştirme ortamına kurulumu ve konfigürasyonu.
*   [x] Veritabanı şemasının tasarlanması (`Mekanlar`, `Kullanıcılar`, `Rozetler`, `Özellikler` tabloları).
*   [x] Backend: Temel API endpoint'lerinin oluşturulması (`/api/places` - yerleri listele, `/api/places/:id` - yer detayı getir).
*   [ ] Flutter: Proje iskeletinin oluşturulması ve temel klasör yapısının ayarlanması.
*   [ ] Flutter: Google Haritalar entegrasyonu ve haritanın ekranda gösterilmesi.
*   [ ] Flutter: API'den gelen verilerle harita üzerinde özel ikonların (Rampa, WC vb.) gösterilmesi.
*   [ ] Flutter: Haritadaki bir ikona tıklandığında mekan detaylarını gösteren basit bir bilgi kartının tasarlanması.
*   [ ] MVP sürümü için veritabanına manuel olarak birkaç örnek mekan verisinin girilmesi.

**Aşama 2: Topluluk ve Etkileşim Özellikleri**
*   [ ] Kullanıcı kayıt ve giriş sistemi (Authentication - E-posta/şifre ile).
*   [ ] Backend: Kullanıcıların yeni yer eklemesi ve mevcut yerleri güncellemesi için gerekli API endpoint'lerinin yazılması.
*   [ ] Flutter: "Yeni Yer Ekle" formu arayüzünün tasarlanması (fotoğraf yükleme dahil).
*   [ ] Flutter: Kullanıcıların kendi ekledikleri yerleri görebileceği basit bir profil sayfası.
*   [ ] Mekanlar için topluluk tarafından puanlama veya doğrulama sistemi altyapısının kurulması.

**Aşama 3: İleri Seviye ve Navigasyon Özellikleri**
*   [ ] Erişilebilir toplu taşıma (otobüs hatları vb.) verilerinin araştırılması ve sisteme entegrasyonu.
*   [ ] Google Directions API kullanarak iki nokta arasında rota çizme özelliğinin eklenmesi.
*   [ ] Rota oluşturma algoritmasının, güzergah üzerindeki erişilebilirlik kriterlerine (rampalı yollar, asansörlü duraklar) göre özelleştirilmesi.
*   [ ] Gelişmiş arama ve filtreleme seçenekleri (örneğin, "sadece 3 Kupalı Yeşil Alan rozetine sahip yerleri göster").
