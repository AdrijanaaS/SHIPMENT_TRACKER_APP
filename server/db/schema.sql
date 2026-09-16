-- Dropping first (in dependency order) makes this script safe to re-run any
-- time you want a clean slate while learning/testing.
DROP TABLE IF EXISTS shipment_events;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  id      SERIAL PRIMARY KEY,
  name    TEXT NOT NULL,
  email   TEXT NOT NULL,
  address TEXT NOT NULL
);

-- The 7 statuses a shipment can be in. Kept as TEXT + CHECK (not a native
-- Postgres ENUM) so the allowed values are easy to read and edit here.
CREATE TABLE shipments (
  id            SERIAL PRIMARY KEY,
  customer_id   INTEGER NOT NULL REFERENCES customers(id),
  destination   TEXT NOT NULL,
  promised_date DATE NOT NULL,
  status        TEXT NOT NULL DEFAULT 'ORDER_CONFIRMED'
                CHECK (status IN (
                  'ORDER_CONFIRMED', 'PICKED_UP', 'DEPARTED',
                  'ARRIVED_AT_HUB', 'OUT_FOR_DELIVERY', 'DELIVERED', 'EXCEPTION'
                )),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One row per transport event. Recording an event here is the ONLY way a
-- shipment's status changes (enforced by the server, not by this table) —
-- shipments.status is always just the status of the most recent event.
CREATE TABLE shipment_events (
  id           SERIAL PRIMARY KEY,
  shipment_id  INTEGER NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
  status       TEXT NOT NULL
               CHECK (status IN (
                 'ORDER_CONFIRMED', 'PICKED_UP', 'DEPARTED',
                 'ARRIVED_AT_HUB', 'OUT_FOR_DELIVERY', 'DELIVERED', 'EXCEPTION'
               )),
  note         TEXT,
  occurred_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Supports both "list shipments by status" and the "late" computation
-- (status <> 'DELIVERED' AND promised_date < CURRENT_DATE) without a full scan.
CREATE INDEX idx_shipments_status_promised ON shipments (status, promised_date);
CREATE INDEX idx_shipment_events_shipment_id ON shipment_events (shipment_id);
