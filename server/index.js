require('dotenv').config();
const express = require('express');
const cors = require('cors');

const customersRouter = require('./routes/customers');
const shipmentsRouter = require('./routes/shipments');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/customers', customersRouter);
app.use('/api/shipments', shipmentsRouter);

// Catches anything forwarded by asyncHandler (see lib/asyncHandler.js) so a
// failed query returns a clean 500 instead of crashing the process.
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Shipment Tracker API listening on port ${port}`);
});
