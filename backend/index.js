const express = require('express');
const app = express();
const port = 3000;
const db = require('./db'); // db.js dosyasını dahil et

app.get('/', (req, res) => {
  res.send('Yeşil Yol Backend Sunucusu');
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
    const result = await db.query('SELECT * FROM Mekanlar WHERE id = $1', [id]);
    if (result.rows.length > 0) {
      res.json(result.rows[0]);
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