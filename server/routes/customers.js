const express = require('express');
const pool = require('../db/pool');
const asyncHandler = require('../lib/asyncHandler');

const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
  const { rows } = await pool.query(
    'SELECT id, name, email, address FROM customers ORDER BY name'
  );
  res.json(rows);
}));

module.exports = router;
