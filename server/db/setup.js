// Rebuilds the database from scratch: schema first, then seed data.
// Safe to re-run any time — schema.sql drops the tables before recreating them.
const fs = require('fs');
const path = require('path');
const pool = require('./pool');

async function run() {
  const schema = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
  const seed = fs.readFileSync(path.join(__dirname, 'seed.sql'), 'utf8');

  console.log('Applying schema...');
  await pool.query(schema);

  console.log('Loading seed data...');
  await pool.query(seed);

  console.log('Done.');
  await pool.end();
}

run().catch((err) => {
  console.error('Database setup failed:', err.message);
  process.exit(1);
});
