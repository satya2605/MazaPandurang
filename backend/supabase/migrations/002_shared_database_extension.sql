-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 002
-- Schema Evolution: Multi-Module Cross-Domain Extensions
-- ========================================================

-- Enable PostGIS Extension if not already present
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 1. EXTEND DINDI MEMBERSHIPS STATUS & TIMESTAMPS
ALTER TABLE dindi_memberships 
ADD COLUMN IF NOT EXISTS role VARCHAR(50) NOT NULL DEFAULT 'warkari',
ADD COLUMN IF NOT EXISTS requested_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 2. EXTEND DINDIS METADATA
ALTER TABLE dindis
ADD COLUMN IF NOT EXISTS start_point VARCHAR(255),
ADD COLUMN IF NOT EXISTS destination VARCHAR(255),
ADD COLUMN IF NOT EXISTS current_halt VARCHAR(255),
ADD COLUMN IF NOT EXISTS road_status VARCHAR(50) DEFAULT 'clear',
ADD COLUMN IF NOT EXISTS join_code VARCHAR(50) UNIQUE;

-- 3. EXTEND SERVICES FOR CLEAN PROVIDER FK & CATEGORIES
ALTER TABLE services
ADD COLUMN IF NOT EXISTS provider_type VARCHAR(50) DEFAULT 'NGO',
ADD COLUMN IF NOT EXISTS provider_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- 4. NGO PROFILES & GALLERY IMAGES (Shrutika — NGO Volunteer Module)
CREATE TABLE IF NOT EXISTS ngos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  registration_number VARCHAR(100) NOT NULL,
  contact_person VARCHAR(255),
  phone VARCHAR(50),
  email VARCHAR(255),
  primary_category VARCHAR(100),
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  profile_image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ngo_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ngo_id UUID NOT NULL REFERENCES ngos(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption TEXT,
  display_order INT DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. POLICE PROFILES & UNITS (Yogeshwari — Police / Authority Module)
CREATE TABLE IF NOT EXISTS police_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  police_id VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  designation VARCHAR(100),
  station_name VARCHAR(255),
  phone VARCHAR(50),
  role VARCHAR(50) NOT NULL DEFAULT 'POLICE_OFFICER',
  status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS police_units (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  unit_code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  unit_type VARCHAR(50) NOT NULL DEFAULT 'PATROL',
  status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE',
  latitude NUMERIC(10, 7),
  longitude NUMERIC(10, 7),
  assigned_officer_id UUID REFERENCES police_profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. TRAFFIC ALERTS (Yogeshwari — Police / Authority Module)
CREATE TABLE IF NOT EXISTS traffic_alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  alert_code VARCHAR(50) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(50) NOT NULL DEFAULT 'ROAD_BLOCK',
  severity VARCHAR(50) NOT NULL DEFAULT 'MEDIUM',
  status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  latitude NUMERIC(10, 7),
  longitude NUMERIC(10, 7),
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

-- 7. CITY PLACES & ROUTES (Curated Wari Specific Places)
CREATE TABLE IF NOT EXISTS city_places (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100) NOT NULL,
  description TEXT,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  address TEXT,
  timings VARCHAR(100),
  phone VARCHAR(50),
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. ADDITIONAL INDEXES FOR HIGH-FREQUENCY QUERIES
CREATE INDEX IF NOT EXISTS idx_dindi_memberships_dindi_id ON dindi_memberships(dindi_id);
CREATE INDEX IF NOT EXISTS idx_dindi_memberships_pilgrim_id ON dindi_memberships(pilgrim_id);
CREATE INDEX IF NOT EXISTS idx_service_reports_service_id ON service_reports(service_id);
CREATE INDEX IF NOT EXISTS idx_lost_person_sightings_report ON lost_person_sightings(lost_person_id);
CREATE INDEX IF NOT EXISTS idx_traffic_alerts_status ON traffic_alerts(status, severity);
CREATE INDEX IF NOT EXISTS idx_police_units_status ON police_units(status);

-- 9. ADDITIONAL STORAGE BUCKET CREATION (NGO Images & Documents)
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('ngo-images', 'ngo-images', true),
  ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- 10. ENABLE RLS ON NEW TABLES
ALTER TABLE ngos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ngo_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE police_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE police_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE traffic_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE city_places ENABLE ROW LEVEL SECURITY;

-- 11. RLS POLICIES FOR NEW TABLES
CREATE POLICY "Public Read Approved NGOs" ON ngos FOR SELECT USING (status = 'approved');
CREATE POLICY "Public Read NGO Images" ON ngo_images FOR SELECT USING (is_active = true);
CREATE POLICY "Public Read Traffic Alerts" ON traffic_alerts FOR SELECT USING (status = 'ACTIVE');
CREATE POLICY "Public Read City Places" ON city_places FOR SELECT USING (is_active = true);
