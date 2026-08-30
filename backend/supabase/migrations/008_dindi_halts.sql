-- Migration 008: Dindi Multi-Day Halts Table
CREATE TABLE IF NOT EXISTS public.dindi_halts (
    id VARCHAR(255) PRIMARY KEY,
    dindi_id VARCHAR(255) NOT NULL REFERENCES public.dindis(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL CHECK (day_number > 0),
    halt_date VARCHAR(50) NOT NULL,
    location_name VARCHAR(255) NOT NULL,
    approx_latitude DOUBLE PRECISION,
    approx_longitude DOUBLE PRECISION,
    next_destination VARCHAR(255),
    expected_arrival VARCHAR(50),
    expected_departure VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (dindi_id, day_number)
);

CREATE INDEX IF NOT EXISTS idx_dindi_halts_dindi_id ON public.dindi_halts(dindi_id);
CREATE INDEX IF NOT EXISTS idx_dindi_halts_date ON public.dindi_halts(halt_date);
