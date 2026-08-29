-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 004
-- NGO Enhanced Service Fields, Medical Emergency & Persistence
-- ========================================================

-- Extend services table with comprehensive capacity, contact, accessibility, emergency support and category details
ALTER TABLE services
ADD COLUMN IF NOT EXISTS capacity TEXT,
ADD COLUMN IF NOT EXISTS operating_hours TEXT,
ADD COLUMN IF NOT EXISTS alternate_contact_phone VARCHAR(50),
ADD COLUMN IF NOT EXISTS whatsapp_available BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS wheelchair_accessible BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS drinking_water_available BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS seating_available BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS accessible_toilet BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS senior_citizen_friendly BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS important_instructions TEXT,
ADD COLUMN IF NOT EXISTS emergency_support_available BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS ambulance_available BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS emergency_contact_phone VARCHAR(50),
ADD COLUMN IF NOT EXISTS ambulance_contact_phone VARCHAR(50),
ADD COLUMN IF NOT EXISTS emergency_instructions TEXT,
ADD COLUMN IF NOT EXISTS category_details JSONB DEFAULT '{}'::jsonb;
