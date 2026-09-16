-- Run after schema.sql. Dates are relative to "now" (CURRENT_DATE / NOW())
-- so the data still makes sense — some shipments still late, some still
-- on time — no matter what day you actually run this.

INSERT INTO customers (name, email, address) VALUES
  ('Acme Co',             'orders@acme.example.com',       '100 Industrial Way, Springfield, IL'),
  ('Globex Corporation',  'shipping@globex.example.com',   '22 Innovation Drive, Riverside, CA'),
  ('Initech',             'procurement@initech.example.com','5 Office Park, Austin, TX'),
  ('Wayne Enterprises',   'supply@wayne.example.com',      '1 Wayne Tower, Gotham, NJ'),
  ('Stark Industries',    'logistics@stark.example.com',   '200 Malibu Point, Malibu, CA'),
  ('Hooli',               'shipping@hooli.example.com',    '400 Main Street, Palo Alto, CA'),
  ('Soylent Corp',        'orders@soylent.example.com',    '77 Green Street, New York, NY'),
  ('Umbrella Logistics',  'dispatch@umbrella.example.com', '9 Raccoon Blvd, Cleveland, OH');

-- Each block: create one shipment, then insert the event history that led
-- to its current status. shipments.status is set to match the shipment's
-- last event, exactly like the app itself will keep them in sync.

-- 1: delivered, on time
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Chicago, IL', CURRENT_DATE + INTERVAL '-12 days', 'DELIVERED'
  FROM customers WHERE name = 'Acme Co' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '20 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '18 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '16 days' FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '14 days' FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '13 days' FROM s UNION ALL
SELECT id, 'DELIVERED',       NULL, NOW() - INTERVAL '12 days' FROM s;

-- 2: delivered, one day later than promised (still not "late" — it's done)
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Denver, CO', CURRENT_DATE + INTERVAL '-8 days', 'DELIVERED'
  FROM customers WHERE name = 'Globex Corporation' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '15 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '13 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '11 days' FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '9 days'  FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '8 days'  FROM s UNION ALL
SELECT id, 'DELIVERED',       NULL, NOW() - INTERVAL '7 days'  FROM s;

-- 3: delivered
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Seattle, WA', CURRENT_DATE + INTERVAL '-5 days', 'DELIVERED'
  FROM customers WHERE name = 'Initech' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '10 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '9 days'  FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '8 days'  FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '6 days'  FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '5 days'  FROM s UNION ALL
SELECT id, 'DELIVERED',       NULL, NOW() - INTERVAL '5 days'  FROM s;

-- 4: delivered
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Miami, FL', CURRENT_DATE + INTERVAL '-6 days', 'DELIVERED'
  FROM customers WHERE name = 'Wayne Enterprises' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '12 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '10 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '9 days'  FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '7 days'  FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '6 days'  FROM s UNION ALL
SELECT id, 'DELIVERED',       NULL, NOW() - INTERVAL '6 days'  FROM s;

-- 5: delivered, older shipment
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Boston, MA', CURRENT_DATE + INTERVAL '-20 days', 'DELIVERED'
  FROM customers WHERE name = 'Stark Industries' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '25 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '23 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '22 days' FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '20 days' FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '19 days' FROM s UNION ALL
SELECT id, 'DELIVERED',       NULL, NOW() - INTERVAL '19 days' FROM s;

-- 6: delivered
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Portland, OR', CURRENT_DATE + INTERVAL '-3 days', 'DELIVERED'
  FROM customers WHERE name = 'Hooli' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '9 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '7 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '6 days' FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '4 days' FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '3 days' FROM s UNION ALL
SELECT id, 'DELIVERED',       NULL, NOW() - INTERVAL '3 days' FROM s;

-- 7: just confirmed, not due for a while — on time
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Atlanta, GA', CURRENT_DATE + INTERVAL '5 days', 'ORDER_CONFIRMED'
  FROM customers WHERE name = 'Soylent Corp' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '1 days' FROM s;

-- 8: just confirmed, on time
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Nashville, TN', CURRENT_DATE + INTERVAL '10 days', 'ORDER_CONFIRMED'
  FROM customers WHERE name = 'Umbrella Logistics' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '2 days' FROM s;

-- 9: LATE — never left ORDER_CONFIRMED, promised date already passed
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Detroit, MI', CURRENT_DATE + INTERVAL '-3 days', 'ORDER_CONFIRMED'
  FROM customers WHERE name = 'Acme Co' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '10 days' FROM s;

-- 10: LATE — same story
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Columbus, OH', CURRENT_DATE + INTERVAL '-1 days', 'ORDER_CONFIRMED'
  FROM customers WHERE name = 'Globex Corporation' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '6 days' FROM s;

-- 11: picked up, on time
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Phoenix, AZ', CURRENT_DATE + INTERVAL '3 days', 'PICKED_UP'
  FROM customers WHERE name = 'Initech' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '5 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '2 days' FROM s;

-- 12: LATE — stuck at picked up
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Dallas, TX', CURRENT_DATE + INTERVAL '-2 days', 'PICKED_UP'
  FROM customers WHERE name = 'Wayne Enterprises' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '9 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '6 days' FROM s;

-- 13: LATE — stuck at picked up longer
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'San Diego, CA', CURRENT_DATE + INTERVAL '-7 days', 'PICKED_UP'
  FROM customers WHERE name = 'Stark Industries' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '14 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '10 days' FROM s;

-- 14: departed, on time
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Charlotte, NC', CURRENT_DATE + INTERVAL '2 days', 'DEPARTED'
  FROM customers WHERE name = 'Hooli' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '6 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '4 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '2 days' FROM s;

-- 15: LATE — departed but promised date passed
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Minneapolis, MN', CURRENT_DATE + INTERVAL '-1 days', 'DEPARTED'
  FROM customers WHERE name = 'Soylent Corp' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '8 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '6 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '3 days' FROM s;

-- 16: LATE — departed, further overdue
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Orlando, FL', CURRENT_DATE + INTERVAL '-4 days', 'DEPARTED'
  FROM customers WHERE name = 'Umbrella Logistics' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '12 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '9 days'  FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '6 days'  FROM s;

-- 17: arrived at hub, on time
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Kansas City, MO', CURRENT_DATE + INTERVAL '1 days', 'ARRIVED_AT_HUB'
  FROM customers WHERE name = 'Acme Co' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '7 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '5 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '3 days' FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '1 days' FROM s;

-- 18: LATE — arrived at hub, overdue
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Las Vegas, NV', CURRENT_DATE + INTERVAL '-2 days', 'ARRIVED_AT_HUB'
  FROM customers WHERE name = 'Globex Corporation' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '10 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '8 days'  FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '5 days'  FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '3 days'  FROM s;

-- 19: out for delivery, due today — NOT late (promised_date < CURRENT_DATE is false when equal)
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Houston, TX', CURRENT_DATE, 'OUT_FOR_DELIVERY'
  FROM customers WHERE name = 'Initech' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '6 days'  FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '4 days'  FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '2 days'  FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '1 days'  FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '4 hours' FROM s;

-- 20: out for delivery, on time
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Sacramento, CA', CURRENT_DATE + INTERVAL '1 days', 'OUT_FOR_DELIVERY'
  FROM customers WHERE name = 'Wayne Enterprises' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '5 days'  FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '3 days'  FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '2 days'  FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '1 days'  FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '6 hours' FROM s;

-- 21: LATE — out for delivery but stuck there past the promised date
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Tampa, FL', CURRENT_DATE + INTERVAL '-3 days', 'OUT_FOR_DELIVERY'
  FROM customers WHERE name = 'Stark Industries' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL, NOW() - INTERVAL '11 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL, NOW() - INTERVAL '9 days'  FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL, NOW() - INTERVAL '7 days'  FROM s UNION ALL
SELECT id, 'ARRIVED_AT_HUB',  NULL, NOW() - INTERVAL '5 days'  FROM s UNION ALL
SELECT id, 'OUT_FOR_DELIVERY',NULL, NOW() - INTERVAL '4 days'  FROM s;

-- 22: LATE — exception (damaged), promised date already passed
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Baltimore, MD', CURRENT_DATE + INTERVAL '-6 days', 'EXCEPTION'
  FROM customers WHERE name = 'Hooli' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL,                                   NOW() - INTERVAL '14 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL,                                   NOW() - INTERVAL '12 days' FROM s UNION ALL
SELECT id, 'DEPARTED',        NULL,                                   NOW() - INTERVAL '9 days'  FROM s UNION ALL
SELECT id, 'EXCEPTION',       'Package damaged in transit',           NOW() - INTERVAL '6 days'  FROM s;

-- 23: LATE — exception (undeliverable address)
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'St. Louis, MO', CURRENT_DATE + INTERVAL '-1 days', 'EXCEPTION'
  FROM customers WHERE name = 'Soylent Corp' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL,                                              NOW() - INTERVAL '9 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL,                                              NOW() - INTERVAL '7 days' FROM s UNION ALL
SELECT id, 'EXCEPTION',       'Address undeliverable, awaiting customer reply',  NOW() - INTERVAL '3 days' FROM s;

-- 24: exception, but not late yet (promised date still ahead)
WITH s AS (
  INSERT INTO shipments (customer_id, destination, promised_date, status)
  SELECT id, 'Raleigh, NC', CURRENT_DATE + INTERVAL '4 days', 'EXCEPTION'
  FROM customers WHERE name = 'Umbrella Logistics' RETURNING id
)
INSERT INTO shipment_events (shipment_id, status, note, occurred_at)
SELECT id, 'ORDER_CONFIRMED', NULL,             NOW() - INTERVAL '3 days' FROM s UNION ALL
SELECT id, 'PICKED_UP',       NULL,             NOW() - INTERVAL '2 days' FROM s UNION ALL
SELECT id, 'EXCEPTION',       'Customs hold',   NOW() - INTERVAL '1 days' FROM s;
