const express = require('express');
const app = express();
const port = 3000;
const db = require('./db'); // db.js dosyasını dahil et
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

app.use(express.json()); // JSON body parsing için

const SECRET_KEY = process.env.JWT_SECRET || 'supersecretjwtkey'; // Güvenli bir anahtar kullanın

app.get('/', (req, res) => {
  res.send('Yeşil Yol Backend Sunucusu');
});

// Kullanıcı kayıt endpoint'i
app.post('/api/register', async (req, res) => {
  const { kullanici_adi, email, sifre } = req.body;
  try {
    const sifre_hash = await bcrypt.hash(sifre, 10); // Şifreyi hashle
    const result = await db.query(
      'INSERT INTO Kullanicilar (kullanici_adi, email, sifre_hash) VALUES ($1, $2, $3) RETURNING kullanici_id',
      [kullanici_adi, email, sifre_hash]
    );
    res.status(201).json({ message: 'Kullanıcı başarıyla kaydedildi', userId: result.rows[0].kullanici_id });
  } catch (err) {
    console.error(err);
    if (err.code === '23505') { // Unique violation error code
      return res.status(409).json({ message: 'Bu e-posta veya kullanıcı adı zaten kullanımda.' });
    }
    res.status(500).send('Sunucu Hatası');
  }
});

// Kullanıcı giriş endpoint'i
app.post('/api/login', async (req, res) => {
  const { email, sifre } = req.body;
  try {
    const result = await db.query('SELECT * FROM Kullanicilar WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(400).json({ message: 'Geçersiz e-posta veya şifre' });
    }

    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(sifre, user.sifre_hash);

    if (!isPasswordValid) {
      return res.status(400).json({ message: 'Geçersiz e-posta veya şifre' });
    }

    const token = jwt.sign({ userId: user.kullanici_id, email: user.email }, SECRET_KEY, { expiresIn: '1h' });
    res.json({ message: 'Giriş başarılı', token, userId: user.kullanici_id });
  } catch (err) {
    console.error(err);
    res.status(500).send('Sunucu Hatası');
  }
});

// Tüm mekanları listeleme endpoint'i
app.get('/api/places', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM Mekanlar');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Sunucu Hatası');
  }
});

// Belirli bir mekanın detaylarını getirme endpoint'i
app.get('/api/places/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const placeResult = await db.query('SELECT * FROM Mekanlar WHERE mekan_id = $1', [id]);

    if (placeResult.rows.length > 0) {
      const place = placeResult.rows[0];
      const mediaResult = await db.query('SELECT medya_url, medya_tipi FROM Mekan_Medya WHERE mekan_id = $1', [id]);
      place.medya = mediaResult.rows;
      res.json(place);
    } else {
      res.status(404).send('Mekan bulunamadı');
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Sunucu Hatası');
  }
});

app.listen(port, () => {
  console.log(`Sunucu http://localhost:${port} adresinde çalışıyor`);
});