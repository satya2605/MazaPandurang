-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 005
-- Service Details Table Extension for Full Form Persistence
-- ========================================================

CREATE TABLE IF NOT EXISTS service_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  service_capacity TEXT,
  operating_hours TEXT,
  is_open_24_hours BOOLEAN DEFAULT FALSE,
  meals_per_day INTEGER,
  beneficiaries_per_day INTEGER,
  doctors_available INTEGER,
  beds_available INTEGER,
  medicines_available TEXT,
  water_capacity_litres_per_day INTEGER,
  water_taps_count INTEGER,
  available_spaces INTEGER,
  current_occupancy TEXT,
  alternate_contact_phone VARCHAR(50),
  whatsapp_available BOOLEAN DEFAULT FALSE,
  wheelchair_accessible BOOLEAN DEFAULT FALSE,
  drinking_water BOOLEAN DEFAULT FALSE,
  seating_available BOOLEAN DEFAULT FALSE,
  accessible_toilet BOOLEAN DEFAULT FALSE,
  senior_citizen_friendly BOOLEAN DEFAULT FALSE,
  important_instructions TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_service_details_service_id UNIQUE (service_id)
);

CREATE INDEX IF NOT EXISTS idx_service_details_service_id ON service_details(service_id);
