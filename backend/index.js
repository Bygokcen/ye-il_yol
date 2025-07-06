const express = require('express');
const app = express();
const port = 3000;
const db = require('./db'); // db.js dosyasını dahil et
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

app.use(express.json()); // JSON body parsing için

const SECRET_KEY = process.env.JWT_SECRET || 'supersecretjwtkey'; // Güvenli bir anahtar kullanın

// Token doğrulama middleware'i
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (token == null) {
    return res.sendStatus(401); // Unauthorized
  }

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) {
      return res.sendStatus(403); // Forbidden
    }
    req.user = user; // user bilgisini request objesine ekle
    next();
  });
};


app.get('/', (req, res) => {
  res.send('Yeşil Yol Backend Sunucusu');
});

// Kullanıcı kayıt endpoint'i
app.post('/api/register', async (req, res) => {
  const { ad_soyad, eposta, sifre } = req.body;
  try {
    const sifre_hash = await bcrypt.hash(sifre, 10);
    const result = await db.query(
      'INSERT INTO Kullanicilar (ad_soyad, eposta, sifre_hash) VALUES ($1, $2, $3) RETURNING id',
      [ad_soyad, eposta, sifre_hash]
    );
    const newUser = { id: result.rows[0].id, ad_soyad, eposta };
    res.status(201).json(newUser);
  } catch (err) {
    console.error(err);
    if (err.code === '23505') { // Unique violation
      return res.status(409).json({ message: 'Bu e-posta adresi zaten kullanımda.' });
    }
    res.status(500).json({ message: 'Sunucu Hatası' });
  }
});

// Kullanıcı giriş endpoint'i
app.post('/api/login', async (req, res) => {
  const { eposta, sifre } = req.body;
  try {
    const result = await db.query('SELECT * FROM Kullanicilar WHERE eposta = $1', [eposta]);
    if (result.rows.length === 0) {
      return res.status(400).json({ message: 'Geçersiz e-posta veya şifre' });
    }

    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(sifre, user.sifre_hash);

    if (!isPasswordValid) {
      return res.status(400).json({ message: 'Geçersiz e-posta veya şifre' });
    }

    const token = jwt.sign({ userId: user.id }, SECRET_KEY, { expiresIn: '24h' });
    // Şifre hash'ini client'a göndermiyoruz.
    const { sifre_hash, ...userToSend } = user;
    res.json({ message: 'Giriş başarılı', token, user: userToSend });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Sunucu Hatası' });
  }
});

// Tüm mekanları listeleme endpoint'i
app.get('/api/places', async (req, res) => {
  try {
    const result = await db.query('SELECT id, ad, latitude, longitude, aciklama FROM Mekanlar WHERE onay_durumu = $1', ['onaylandi']);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Sunucu Hatası' });
  }
});

// Belirli bir mekanın detaylarını getirme endpoint'i
app.get('/api/places/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const placeResult = await db.query('SELECT * FROM Mekanlar WHERE id = $1', [id]);

    if (placeResult.rows.length > 0) {
      const place = placeResult.rows[0];
      const mediaResult = await db.query('SELECT medya_url, medya_tipi FROM Mekan_Medya WHERE mekan_id = $1', [id]);
      place.medya = mediaResult.rows;
      res.json(place);
    } else {
      res.status(404).json({ message: 'Mekan bulunamadı' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Sunucu Hatası' });
  }
});

// Yeni mekan ekleme endpoint'i (Token gerektirir)
app.post('/api/places', authenticateToken, async (req, res) => {
  const { ad, latitude, longitude, aciklama, ozellikler } = req.body;
  const ekleyen_kullanici_id = req.user.userId;

  // TODO: Gelen `ozellikler` objesini (`{\"rampa\":true, ...}`) alıp \n  // `Mekan_Ozellikleri` tablosuna işleyecek daha gelişmiş bir mantık kurulmalı.\n  // Bu işlem için özellik adlarından ID'leri getiren bir sorgu gerekebilir.\n
  // TODO: Kullanıcıya \"Kaşif\" rozeti verme mantığı eklenmeli.
  
  try {
    const result = await db.query(
      `INSERT INTO Mekanlar (ad, latitude, longitude, aciklama, ekleyen_kullanici_id, onay_durumu) 
       VALUES ($1, $2, $3, $4, $5, 'aday') RETURNING id`,
      [ad, latitude, longitude, aciklama, ekleyen_kullanici_id]
    );
    res.status(201).json({ message: 'Mekan başarıyla eklendi ve onaya gönderildi.', placeId: result.rows[0].id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Mekan eklenirken bir hata oluştu.' });
  }
});

app.listen(port, () => {
  console.log(`Sunucu http://localhost:${port} adresinde çalışıyor`);
});
