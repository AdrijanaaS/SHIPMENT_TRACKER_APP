require('dotenv').config();
const { Pool, types } = require('pg');

// Keeping DATE values as plain 'YYYY-MM-DD' strings avoids timezone-related issues.
const PG_TYPE_DATE = 1082;
types.setTypeParser(PG_TYPE_DATE, (value) => value);

// A Pool hands out reusable database connections instead of opening a new
// one for every query. One shared pool for the whole app.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

module.exports = pool;
