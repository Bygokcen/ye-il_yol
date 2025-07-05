# Yeşil Yol Projesi - Veritabanı Şeması

Bu belge, Yeşil Yol projesinin PostgreSQL veritabanı şemasını detaylandırmaktadır.

---

## Tablolar

### 1. `Mekanlar` Tablosu

Erişilebilir mekanların temel bilgilerini tutar.

| Sütun Adı           | Veri Tipi                 | Kısıtlamalar           | Açıklama                                                              |
| :------------------ | :------------------------ | :--------------------- | :-------------------------------------------------------------------- |
| `id`                | `SERIAL`                  | `PRIMARY KEY`          | Mekanın benzersiz kimliği.                                            |
| `ad`                | `VARCHAR(255)`            | `NOT NULL`             | Mekanın adı.                                                          |
| `adres`             | `TEXT`                    |                        | Mekanın açık adresi.                                                  |
| `bölge`             | `VARCHAR(100)`            |                        | Mekanın bulunduğu coğrafi bölge (örn: Karadeniz, Akdeniz).            |
| `il`                | `VARCHAR(100)`            |                        | Mekanın bulunduğu il.                                                 |
| `ilçe`              | `VARCHAR(100)`            |                        | Mekanın bulunduğu ilçe.                                               |
| `telefon`           | `VARCHAR(20)`             |                        | Mekanın telefon numarası.                                             |
| `koordinat`         | `GEOMETRY(Point, 4326)`   |                        | Mekanın coğrafi konumu (enlem ve boylam). SRID 4326 (WGS 84) kullanılır. |
| `ekleyen_kullanici_id` | `INTEGER`                 | `FOREIGN KEY` (`Kullanicilar.id`) | Mekanı ekleyen kullanıcının kimliği.                                  |
| `onay_durumu`       | `VARCHAR(50)`             | `DEFAULT 'aday'`       | Mekanın onay durumu (`aday`, `onaylandı`, `reddedildi`). Başlangıçta 'aday'dır. |
| `eklenme_tarihi`    | `TIMESTAMP WITH TIME ZONE`| `DEFAULT CURRENT_TIMESTAMP` | Mekanın veritabanına eklendiği tarih ve saat.                         |

---

### 2. `Kullanicilar` Tablosu

Uygulama kullanıcılarının bilgilerini ve yetkilerini tutar.

| Sütun Adı           | Veri Tipi                 | Kısıtlamalar           | Açıklama                                                              |
| :------------------ | :------------------------ | :--------------------- | :-------------------------------------------------------------------- |
| `id`                | `SERIAL`                  | `PRIMARY KEY`          | Kullanıcının benzersiz kimliği.                                       |
| `ad_soyad`          | `VARCHAR(100)`            | `NOT NULL`             | Kullanıcının adı ve soyadı.                                           |
| `eposta`            | `VARCHAR(255)`            | `UNIQUE`, `NOT NULL`   | Kullanıcının e-posta adresi (benzersiz olmalı).                       |
| `sifre_hash`        | `VARCHAR(255)`            | `NOT NULL`             | Kullanıcının şifresinin hash'lenmiş hali.                             |
| `kayit_tarihi`      | `TIMESTAMP WITH TIME ZONE`| `DEFAULT CURRENT_TIMESTAMP` | Kullanıcının kayıt olduğu tarih ve saat.                              |
| `rol`               | `kullanici_rolu`          | `NOT NULL`, `DEFAULT 'kullanici'` | Kullanıcının yetki rolü (`kullanici`, `moderator`, `admin`).          |
| `ban_durumu`        | `BOOLEAN`                 | `NOT NULL`, `DEFAULT FALSE` | Kullanıcının yasaklı olup olmadığı.                                   |
| `ban_gerekcesi`     | `TEXT`                    |                        | Kullanıcının neden yasaklandığına dair açıklama.                      |

**`kullanici_rolu` ENUM Tipi:**
*   `'kullanici'`: Standart kullanıcı.
*   `'moderator'`: İçerik denetimi yapabilen kullanıcı.
*   `'admin'`: Tam yetkili yönetici.

---

### 3. `Ozellikler` Tablosu

Mekanların sahip olabileceği erişilebilirlik özelliklerini tanımlar.

| Sütun Adı           | Veri Tipi                 | Kısıtlamalar           | Açıklama                                                              |
| :------------------ | :------------------------ | :--------------------- | :-------------------------------------------------------------------- |
| `id`                | `SERIAL`                  | `PRIMARY KEY`          | Özelliğin benzersiz kimliği.                                          |
| `ad`                | `VARCHAR(100)`            | `UNIQUE`, `NOT NULL`   | Özelliğin adı (örn: 'Rampa', 'Engelli WC', 'Asansör'). Benzersiz olmalı. |
| `ikon_url`          | `TEXT`                    |                        | Özelliği temsil eden ikonun URL'si (isteğe bağlı).                    |

---

### 4. `Mekan_Ozellikleri` Tablosu

`Mekanlar` ve `Ozellikler` tabloları arasındaki çok-a-çok ilişkiyi kurar. Bir mekanın hangi özelliklere sahip olduğunu belirtir.

| Sütun Adı           | Veri Tipi                 | Kısıtlamalar           | Açıklama                                                              |
| :------------------ | :------------------------ | :--------------------- | :-------------------------------------------------------------------- |
| `mekan_id`          | `INTEGER`                 | `NOT NULL`, `FOREIGN KEY` (`Mekanlar.id`), `ON DELETE CASCADE` | Özelliğin ait olduğu mekanın kimliği. Mekan silindiğince ilgili kayıtlar da silinir. |
| `ozellik_id`        | `INTEGER`                 | `NOT NULL`, `FOREIGN KEY` (`Ozellikler.id`), `ON DELETE CASCADE` | Mekana atanan özelliğin kimliği. Özellik silindiğince ilgili kayıtlar da silinir. |
| `PRIMARY KEY`       |                           | (`mekan_id`, `ozellik_id`) | Her mekan-özellik çifti benzersiz olmalı.                           |

---

### 5. `Rozetler` Tablosu

Kullanıcıların veya mekanların kazanabileceği rozetleri tanımlar.

| Sütun Adı           | Veri Tipi                 | Kısıtlamalar           | Açıklama                                                              |
| :------------------ | :------------------------ | :--------------------- | :-------------------------------------------------------------------- |
| `id`                | `SERIAL`                  | `PRIMARY KEY`          | Rozetin benzersiz kimliği.                                            |
| `ad`                | `VARCHAR(100)`            | `UNIQUE`, `NOT NULL`   | Rozetin adı (örn: 'Yeşil Alan Kaşifi', 'Erişim Uzmanı'). Benzersiz olmalı. |
| `aciklama`          | `TEXT`                    |                        | Rozetin açıklaması.                                                   |
| `ikon_url`          | `TEXT`                    |                        | Rozeti temsil eden ikonun URL'si (isteğe bağlı).                      |

---

### 6. `Kullanici_Rozetleri` Tablosu

`Kullanicilar` ve `Rozetler` tabloları arasındaki çok-a-çok ilişkiyi kurar. Hangi kullanıcının hangi rozeti ne zaman kazandığını belirtir.

| Sütun Adı           | Veri Tipi                 | Kısıtlamalar           | Açıklama                                                              |
| :------------------ | :------------------------ | :--------------------- | :-------------------------------------------------------------------- |
| `kullanici_id`      | `INTEGER`                 | `NOT NULL`, `FOREIGN KEY` (`Kullanicilar.id`), `ON DELETE CASCADE` | Rozeti kazanan kullanıcının kimliği. Kullanıcı silindiğince ilgili kayıtlar da silinir. |
| `rozet_id`          | `INTEGER`                 | `NOT NULL`, `FOREIGN KEY` (`Rozetler.id`), `ON DELETE CASCADE` | Kazanılan rozetin kimliği. Rozet silindiğince ilgili kayıtlar da silinir. |
| `kazanma_tarihi`    | `TIMESTAMP WITH TIME ZONE`| `DEFAULT CURRENT_TIMESTAMP` | Rozetin kazanıldığı tarih ve saat.                                    |
| `PRIMARY KEY`       |                           | (`kullanici_id`, `rozet_id`) | Her kullanıcı-rozet çifti benzersiz olmalı.                           |
