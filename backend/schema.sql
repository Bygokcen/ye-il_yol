
-- PostgreSQL schema for the Yeşil Yol project

CREATE TABLE Kullanicilar (
    kullanici_id SERIAL PRIMARY KEY,
    kullanici_adi VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    sifre_hash VARCHAR(255) NOT NULL,
    olusturma_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Mekanlar (
    mekan_id SERIAL PRIMARY KEY,
    kullanici_id INTEGER REFERENCES Kullanicilar(kullanici_id),
    ad VARCHAR(255) NOT NULL,
    aciklama TEXT,
    latitude NUMERIC(10, 8) NOT NULL,
    longitude NUMERIC(11, 8) NOT NULL,
    olusturma_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Rozetler (
    rozet_id SERIAL PRIMARY KEY,
    rozet_adi VARCHAR(100) NOT NULL,
    aciklama TEXT,
    icon_url VARCHAR(255)
);

CREATE TABLE Ozellikler (
    ozellik_id SERIAL PRIMARY KEY,
    ozellik_adi VARCHAR(100) NOT NULL,
    aciklama TEXT
);

CREATE TABLE Mekan_Ozellikleri (
    mekan_id INTEGER REFERENCES Mekanlar(mekan_id),
    ozellik_id INTEGER REFERENCES Ozellikler(ozellik_id),
    PRIMARY KEY (mekan_id, ozellik_id)
);

CREATE TABLE Mekan_Rozetleri (
    mekan_id INTEGER REFERENCES Mekanlar(mekan_id),
    rozet_id INTEGER REFERENCES Rozetler(rozet_id),
    PRIMARY KEY (mekan_id, rozet_id)
);

CREATE TABLE Mekan_Medya (
    medya_id SERIAL PRIMARY KEY,
    mekan_id INTEGER REFERENCES Mekanlar(mekan_id) ON DELETE CASCADE,
    kullanici_id INTEGER REFERENCES Kullanicilar(kullanici_id) ON DELETE SET NULL, -- Medyayı ekleyen kullanıcının ID'si
    medya_url VARCHAR(255) NOT NULL,
    medya_tipi VARCHAR(50) NOT NULL, -- 'resim' veya 'video'
    olusturma_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
