-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 007
-- Multi-Day Planned Halt Schedule for Palkhi Registry
-- ========================================================

-- 1. CREATE PALKHI HALTS TABLE
CREATE TABLE IF NOT EXISTS palkhi_halts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  palkhi_id VARCHAR(255) NOT NULL REFERENCES palkhi_tracking(id) ON DELETE CASCADE,
  day_number INT NOT NULL CHECK (day_number > 0),
  halt_date DATE NOT NULL,
  location_name VARCHAR(255) NOT NULL,
  approx_latitude NUMERIC(10, 6) CHECK (approx_latitude BETWEEN -90 AND 90),
  approx_longitude NUMERIC(10, 6) CHECK (approx_longitude BETWEEN -180 AND 180),
  next_destination VARCHAR(255),
  expected_arrival VARCHAR(100),
  expected_departure VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_palkhi_day UNIQUE (palkhi_id, day_number)
);

-- 2. INDEXES FOR FAST QUERYING
CREATE INDEX IF NOT EXISTS idx_palkhi_halts_palkhi_id ON palkhi_halts(palkhi_id);
CREATE INDEX IF NOT EXISTS idx_palkhi_halts_date ON palkhi_halts(halt_date);
