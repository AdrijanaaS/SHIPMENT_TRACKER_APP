require('dotenv').config();
const { Pool } = require('pg');

// A Pool hands out reusable database connections instead of opening a new
// one for every query. One shared pool for the whole app.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

module.exports = pool;
