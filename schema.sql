CREATE TABLE Mekanlar (
    id SERIAL PRIMARY KEY,
    ad VARCHAR(255) NOT NULL,
    adres TEXT,
    bölge VARCHAR(100),
    il VARCHAR(100),
    ilçe VARCHAR(100),
    telefon VARCHAR(20),
    koordinat GEOMETRY(Point, 4326),
    ekleyen_kullanici_id INTEGER,
    onay_durumu VARCHAR(50) DEFAULT 'aday',
    eklenme_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);