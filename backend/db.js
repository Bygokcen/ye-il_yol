const { Pool } = require('pg');

const pool = new Pool({
  user: 'gokcen',
  host: 'localhost', // veya PostgreSQL sunucunuzun adresi
  database: 'yesil_yol_db',
  password: '', // Eğer şifreniz varsa buraya girin
  port: 5432, // PostgreSQL varsayılan portu
});

module.exports = {
  query: (text, params) => pool.query(text, params),
};