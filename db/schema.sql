CREATE TABLE IF NOT EXISTS captains (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  code_hash TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','paused','deleted')),
  wallet_name TEXT,
  wallet_number TEXT,
  bank_name TEXT,
  bank_account TEXT,
  accountant_whatsapp TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value NUMERIC(14,3) NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ledger_entries (
  id BIGSERIAL PRIMARY KEY,
  captain_id BIGINT NOT NULL REFERENCES captains(id),
  type TEXT NOT NULL CHECK (type IN ('passenger_production','passenger_consumption','order_production','order_consumption','group_floor','commission','manual_credit','manual_debit','payment')),
  amount NUMERIC(14,3) NOT NULL,
  reference_type TEXT,
  reference_id BIGINT,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ledger_captain_created ON ledger_entries(captain_id, created_at DESC);

CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY,
  captain_id BIGINT NOT NULL REFERENCES captains(id),
  customer_name TEXT,
  order_number TEXT UNIQUE,
  value NUMERIC(14,3) NOT NULL DEFAULT 0,
  commission NUMERIC(14,3) NOT NULL DEFAULT 0,
  production_profit NUMERIC(14,3) NOT NULL DEFAULT 0,
  consumption NUMERIC(14,3) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending','in_progress','completed','cancelled')),
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_orders_captain_created ON orders(captain_id, created_at DESC);

CREATE TABLE IF NOT EXISTS payments (
  id BIGSERIAL PRIMARY KEY,
  captain_id BIGINT NOT NULL REFERENCES captains(id),
  amount NUMERIC(14,3) NOT NULL CHECK (amount > 0),
  method TEXT NOT NULL DEFAULT 'cash',
  status TEXT NOT NULL DEFAULT 'paid' CHECK (status IN ('requested','paid','rejected')),
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  paid_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_payments_captain_created ON payments(captain_id, created_at DESC);

INSERT INTO settings(key,value) VALUES
('passenger_production',5),
('passenger_consumption',4.25),
('order_production',1),
('order_consumption',0),
('group_floor',0.5)
ON CONFLICT(key) DO NOTHING;
