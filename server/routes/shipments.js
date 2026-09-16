const express = require('express');
const pool = require('../db/pool');
const asyncHandler = require('../lib/asyncHandler');
const { isValidTransition } = require('../lib/transitions');

const router = express.Router();

const SHIPMENT_COLUMNS = `
  s.id, s.destination, s.promised_date, s.status, s.created_at,
  c.id AS customer_id, c.name AS customer_name,
  (s.status <> 'DELIVERED' AND s.promised_date < CURRENT_DATE) AS is_late
`;

// GET /api/shipments?status=&search=&lateOnly=
// Filters are built up conditionally so only the ones actually passed end up in the query
router.get('/', asyncHandler(async (req, res) => {
  const { status, search, lateOnly } = req.query;

  const conditions = [];
  const params = [];

  if (status) {
    params.push(status);
    conditions.push(`s.status = $${params.length}`);
  }
  if (search) {
    params.push(`%${search}%`);
    conditions.push(`c.name ILIKE $${params.length}`);
  }
  if (lateOnly === 'true') {
    conditions.push(`s.status <> 'DELIVERED' AND s.promised_date < CURRENT_DATE`);
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  // Worst-late-first when filtering to late shipments; otherwise newest first.
  const orderBy = lateOnly === 'true'
    ? 'ORDER BY s.promised_date ASC'
    : 'ORDER BY s.created_at DESC';

  const { rows } = await pool.query(
    `SELECT ${SHIPMENT_COLUMNS}
     FROM shipments s
     JOIN customers c ON c.id = s.customer_id
     ${where}
     ${orderBy}`,
    params
  );

  res.json(rows);
}));

// GET /api/shipments/:id — full detail plus its complete event history.
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const shipmentResult = await pool.query(
    `SELECT ${SHIPMENT_COLUMNS},
       c.email AS customer_email, c.address AS customer_address
     FROM shipments s
     JOIN customers c ON c.id = s.customer_id
     WHERE s.id = $1`,
    [id]
  );

  if (shipmentResult.rows.length === 0) {
    return res.status(404).json({ error: 'Shipment not found' });
  }

  const eventsResult = await pool.query(
    `SELECT id, status, note, occurred_at
     FROM shipment_events
     WHERE shipment_id = $1
     ORDER BY occurred_at ASC`,
    [id]
  );

  res.json({ ...shipmentResult.rows[0], events: eventsResult.rows });
}));

// POST /api/shipments — creates a shipment and its opening ORDER_CONFIRMED
// event together, in one transaction, so a shipment never exists without
// at least one matching event (shipments.status always mirrors the last event).
router.post('/', asyncHandler(async (req, res) => {
  const { customerId, destination, promisedDate } = req.body;

  if (!customerId || !destination || !promisedDate) {
    return res.status(400).json({
      error: 'customerId, destination and promisedDate are all required',
    });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const shipmentResult = await client.query(
      `INSERT INTO shipments (customer_id, destination, promised_date, status)
       VALUES ($1, $2, $3, 'ORDER_CONFIRMED')
       RETURNING id, customer_id, destination, promised_date, status, created_at`,
      [customerId, destination, promisedDate]
    );
    const shipment = shipmentResult.rows[0];

    await client.query(
      `INSERT INTO shipment_events (shipment_id, status) VALUES ($1, 'ORDER_CONFIRMED')`,
      [shipment.id]
    );

    await client.query('COMMIT');
    res.status(201).json(shipment);
  } catch (err) {
    await client.query('ROLLBACK');
    if (err.code === '23503') {
      // foreign key violation — customerId didn't match a real customer
      return res.status(400).json({ error: 'customerId does not match an existing customer' });
    }
    throw err;
  } finally {
    client.release();
  }
}));

// POST /api/shipments/:id/events — the business rule. Recording an event IS
// the status change: reject anything that isn't a legal next step, and keep
// the new event + the updated shipment status in one transaction so the two
// never disagree.
router.post('/:id/events', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { status, note } = req.body;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const shipmentResult = await client.query(
      'SELECT status FROM shipments WHERE id = $1 FOR UPDATE',
      [id]
    );

    if (shipmentResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Shipment not found' });
    }

    const currentStatus = shipmentResult.rows[0].status;

    if (!isValidTransition(currentStatus, status)) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        error: `Cannot move a shipment from ${currentStatus} to ${status}`,
      });
    }

    const eventResult = await client.query(
      `INSERT INTO shipment_events (shipment_id, status, note)
       VALUES ($1, $2, $3)
       RETURNING id, status, note, occurred_at`,
      [id, status, note || null]
    );

    await client.query('UPDATE shipments SET status = $1 WHERE id = $2', [status, id]);

    await client.query('COMMIT');
    res.status(201).json(eventResult.rows[0]);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}));

module.exports = router;
