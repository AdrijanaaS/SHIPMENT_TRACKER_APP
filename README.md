# Shipment Tracker

A tool for an operations team to see where every shipment stands and identify what's
running late.

## Stack

- **Frontend:** Angular, with Angular Material for the UI
- **Backend:** Node.js and Express
- **Database:** PostgreSQL, queried directly via the `pg` library (no ORM)

### Prerequisites

- **Node.js** (LTS) — includes `npm`
- **PostgreSQL**, installed and running locally

### 1. Database

Create the role and database this project expects — matches `server/.env.example`
exactly, so nothing needs editing afterward:

    psql -U postgres -c "CREATE ROLE shipment_tracker WITH LOGIN PASSWORD 'devpassword';"
    psql -U postgres -c "CREATE DATABASE shipment_tracker OWNER shipment_tracker;"

`psql -U postgres` will prompt for your own Postgres superuser password — a
one-time interactive prompt, unrelated to `devpassword` above (which is being
assigned to the new, low-privilege `shipment_tracker` role the app actually
connects as).

> If `psql -U postgres` says that role doesn't exist: some Mac/Linux installs use
> your OS username as the superuser instead of `postgres` — substitute that name.
> If instead it says the role or database already exists, that's harmless — it
> means this step already ran once; continue to the next step.

### 2. Backend

    cd server
    copy .env.example .env      # already matches the database above — no editing needed; Windows cmd.exe
                               # or in Unix terminal: cp .env.example .env
    npm install
    npm run db:setup          # builds the schema and loads seed data — safe to re-run any time
    npm start

Leave this running. The API is now live at `http://localhost:3000`.

### 3. Frontend

Open a second terminal:

    cd client
    npm install
    npm start                 # or: npx ng serve

Once it finishes compiling, open `http://localhost:4200`. You should immediately
see a populated dashboard — 24 seeded shipments across 8 customers, no further
setup required.

## Using the app

**Dashboard (`/`)** — every shipment in one table: customer, destination, status,
promised date, and a badge on anything overdue. A search box, a status filter, and
a "late only" toggle narrow the list; switching the toggle on also re-sorts the
list worst-overdue-first (oldest promised date at the top — late the longest).
Click any row to open it.

**Shipment detail (`/shipments/:id`)** — the customer, destination, promised date,
current status, and the full event history in order. If the shipment isn't
finished or flagged, a "record an event" section offers a button for each status
that's actually legal to move to next, plus an optional note. Skipping a step
isn't possible — only legal next moves are ever offered.

**New shipment (`/shipments/new`)** — pick an existing customer, enter a
destination and promised date, submit. Lands on the new shipment's own detail page.

To reset back to the original seeded data at any point, re-run `npm run db:setup`
in `server/` — it's built to be safe to run repeatedly.

## Data model

Three tables: `customers` (preloaded, read-only from the app), `shipments` (one row
per shipment), and `shipment_events` (an append-only history — see *Design
decisions* below for how the two relate). A shipment moves through a fixed
sequence — `ORDER_CONFIRMED → PICKED_UP → DEPARTED → ARRIVED_AT_HUB →
OUT_FOR_DELIVERY → DELIVERED` — with `EXCEPTION` reachable as a side-branch from
any status before delivery.

## API

| Method & path | Purpose |
|---|---|
| `GET /api/customers` | list customers, for the new-shipment form |
| `GET /api/shipments` | list, with optional `status`, `search`, `lateOnly` filters |
| `GET /api/shipments/:id` | one shipment plus its full event history |
| `POST /api/shipments` | create a shipment for an existing customer |
| `POST /api/shipments/:id/events` | record an event — the only way status changes |

## Design decisions

A shipment's status and its history are treated as the same thing, rather than two
things kept in sync with each other. There is no action that directly sets a
shipment's status — `shipments.status` is defined to always equal the status of its
most recent recorded event, and recording an event (a shipment departed, arrived,
was delivered) *is* the action that moves it forward. This has a direct
consequence for one of the harder questions in the brief — what should happen when
an operator records something that contradicts where a shipment actually is: rather
than detecting and handling that case, it's prevented outright. Every recorded
event is checked against a fixed table of legal next steps for the shipment's
current status, and anything that isn't a legal move is rejected before it reaches
the database.

"Late" is calculated the same way it's asked about — on demand, not stored. A
shipment counts as late once it hasn't been delivered and its promised date has
passed, evaluated fresh on every request rather than kept in a column some
background process would need to update. The comparison is deliberately against
the *current date*, not the current moment — a shipment promised for today
shouldn't read as late the instant midnight passes, only once that day has actually
finished. A promised date is treated purely as a calendar day for this reason, with
no time component; shipments are also assumed to route through a single hub, which
is why the status sequence has one `ARRIVED_AT_HUB` step rather than a repeatable
one.

The interface followed the same instinct toward doing one thing well rather than
several things adequately. A single dashboard, filtered is closer to how someone actually monitoring
shipments would want to work than switching between two screens, and a smaller
surface to build carefully. Customers are preloaded with no management screen of
their own, since nothing about tracking a shipment requires editing who a customer
is. On the data layer, queries are written directly rather than generated by an
ORM — every one of them is something that can be read and explained, because of the familiarity with SQL.

## Known limitations

The shipment list loads every matching row on every request, with no pagination —
workable at the current scale, but the first thing that would need to change before
this could hold real volume. Alongside it, the customer-name search uses a pattern
match that can't use a standard database index, and would be the first query to
visibly slow down as the data grows. The schema is also rebuilt from scratch by the
setup script rather than evolved through versioned migrations, which is a
reasonable simplification for a project with no real persisted data, but not how a
production database would be managed.

A few smaller gaps were identified and knowingly left alone rather than fixed:
there's no way to move a shipment out of `EXCEPTION` back into its normal flow;
there's no automated test suite, with correctness instead verified by hand as the
project was built; the API currently accepts requests from any origin, which is
fine without a deployment target but would need restricting in a real one; and a
few interface details — no loading indicator while a request is in flight, no
visual distinction on the action that flags a shipment as an exception, dashboard
rows that aren't reachable by keyboard — were consciously left for later in favor
of the core functionality.

## With more time

Pagination on the shipment list, a proper indexing strategy for the customer
search, an automated test suite, a way to resolve a shipment out of `EXCEPTION`,
and the ability to edit or cancel a shipment would be the next additions.
