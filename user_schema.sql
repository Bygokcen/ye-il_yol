-- Kullanıcı rollerini tanımlamak için bir ENUM tipi oluşturuyoruz.
CREATE TYPE kullanici_rolu AS ENUM ('kullanici', 'moderator', 'admin');

CREATE TABLE Kullanicilar (
    id SERIAL PRIMARY KEY,
    ad_soyad VARCHAR(100) NOT NULL,
    eposta VARCHAR(255) UNIQUE NOT NULL,
    sifre_hash VARCHAR(255) NOT NULL,
    kayit_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Rol ve Banlama Alanları
    rol kullanici_rolu NOT NULL DEFAULT 'kullanici', -- Her yeni kullanıcı standart 'kullanici' rolüyle başlar
    ban_durumu BOOLEAN NOT NULL DEFAULT FALSE, -- Varsayılan olarak kimse banlı değildir
    ban_gerekcesi TEXT -- Banlama nedenini kaydetmek için
);