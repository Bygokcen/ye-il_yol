CREATE TABLE Rozetler (
    id SERIAL PRIMARY KEY,
    ad VARCHAR(100) UNIQUE NOT NULL,
    aciklama TEXT,
    ikon_url TEXT -- Rozeti temsil eden ikonun adresi (opsiyonel)
);

CREATE TABLE Kullanici_Rozetleri (
    kullanici_id INTEGER NOT NULL REFERENCES Kullanicilar(id) ON DELETE CASCADE,
    rozet_id INTEGER NOT NULL REFERENCES Rozetler(id) ON DELETE CASCADE,
    kazanma_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (kullanici_id, rozet_id)
);