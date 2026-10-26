require('dotenv').config();
const { Pool, types } = require('pg');

// NUMERIC llega como texto desde pg; lo convertimos a número
types.setTypeParser(1700, (v) => parseFloat(v));

if (!process.env.DATABASE_URL) {
  console.error('Falta la variable DATABASE_URL');
  process.exit(1);
}

const local = /localhost|127\.0\.0\.1/.test(process.env.DATABASE_URL);
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: local ? false : { rejectUnauthorized: false },
});

async function init() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS productos (
      id SERIAL PRIMARY KEY,
      nombre VARCHAR(150) NOT NULL,
      codigo VARCHAR(50) NOT NULL UNIQUE,
      descripcion TEXT,
      precio NUMERIC(12,2) NOT NULL CHECK (precio >= 0),
      cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
      categoria VARCHAR(100) NOT NULL
    )
  `);
}

module.exports = { pool, init };