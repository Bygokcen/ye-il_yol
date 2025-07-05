CREATE TABLE Ozellikler (
    id SERIAL PRIMARY KEY,
    ad VARCHAR(100) UNIQUE NOT NULL,
    ikon_url TEXT -- Özelliği temsil eden ikonun adresi (opsiyonel)
);

CREATE TABLE Mekan_Ozellikleri (
    mekan_id INTEGER NOT NULL REFERENCES Mekanlar(id) ON DELETE CASCADE,
    ozellik_id INTEGER NOT NULL REFERENCES Ozellikler(id) ON DELETE CASCADE,
    PRIMARY KEY (mekan_id, ozellik_id) -- Her mekan-özellik çifti benzersiz olmalı
);