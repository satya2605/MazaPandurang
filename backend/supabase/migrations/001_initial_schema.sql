-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 001
-- PostgreSQL + Supabase Storage + Row Level Security (RLS)
-- ========================================================

-- Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. ENUMS
CREATE TYPE user_role AS ENUM (
  'pilgrim',
  'dindi_leader',
  'ngo_volunteer',
  'police_authority',
  'local_citizen',
  'admin'
);

CREATE TYPE service_category_type AS ENUM (
  'Medical',
  'Water',
  'Food',
  'Toilet',
  'Shelter',
  'Police',
  'NGO',
  'Other'
);

CREATE TYPE emergency_type_enum AS ENUM (
  'Medical',
  'Police',
  'Lost Person',
  'Other'
);

CREATE TYPE emergency_status_enum AS ENUM (
  'pending',
  'dispatched',
  'resolved',
  'cancelled'
);

CREATE TYPE report_status_enum AS ENUM (
  'pending',
  'reviewed',
  'resolved',
  'rejected'
);

CREATE TYPE lost_person_status_enum AS ENUM (
  'missing',
  'sighted',
  'found'
);

-- 2. USER PROFILES
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role user_role NOT NULL DEFAULT 'pilgrim',
  display_name VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  email VARCHAR(255),
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. DINDIS
CREATE TABLE IF NOT EXISTS dindis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dindi_number VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  leader_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  member_count INT NOT NULL DEFAULT 1,
  current_location_name VARCHAR(255),
  latitude NUMERIC(10, 7),
  longitude NUMERIC(10, 7),
  status VARCHAR(100) DEFAULT 'Active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. DINDI MEMBERSHIPS
CREATE TABLE IF NOT EXISTS dindi_memberships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pilgrim_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  dindi_id UUID NOT NULL REFERENCES dindis(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(pilgrim_id, dindi_id)
);

-- 5. PALKHI TRACKING
CREATE TABLE IF NOT EXISTS palkhi_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL DEFAULT 'Sant Dnyaneshwar Maharaj Palkhi',
  current_stage VARCHAR(255) NOT NULL,
  next_stop VARCHAR(255) NOT NULL,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  last_updated_by UUID REFERENCES profiles(id),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. SERVICES (Wari Seva)
CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. SRV-MED-001
  category service_category_type NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  contact_phone VARCHAR(50),
  availability_status VARCHAR(100) NOT NULL DEFAULT 'Open 24/7',
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  provider_id UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. SERVICE IMAGES (Dedicated Table for Multiple Facility Images)
CREATE TABLE IF NOT EXISTS service_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. SERVICE REPORTS
CREATE TABLE IF NOT EXISTS service_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES profiles(id),
  report_type VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  status report_status_enum NOT NULL DEFAULT 'pending',
  admin_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- 9. EMERGENCY REQUESTS (SOS)
CREATE TABLE IF NOT EXISTS emergency_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_code VARCHAR(50) NOT NULL UNIQUE,
  requester_id UUID REFERENCES profiles(id),
  emergency_type emergency_type_enum NOT NULL,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  location_name VARCHAR(255),
  status emergency_status_enum NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- 10. LOST PERSON REPORTS
CREATE TABLE IF NOT EXISTS lost_person_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  person_name VARCHAR(255) NOT NULL,
  age INT,
  description TEXT NOT NULL,
  last_seen_location VARCHAR(255) NOT NULL,
  last_seen_latitude NUMERIC(10, 7),
  last_seen_longitude NUMERIC(10, 7),
  reporter_id UUID REFERENCES profiles(id),
  is_approved_by_admin BOOLEAN NOT NULL DEFAULT FALSE,
  status lost_person_status_enum NOT NULL DEFAULT 'missing',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- 11. LOST PERSON IMAGES (Dedicated Table for Private Photos)
CREATE TABLE IF NOT EXISTS lost_person_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lost_person_id UUID NOT NULL REFERENCES lost_person_reports(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. LOST PERSON SIGHTINGS
CREATE TABLE IF NOT EXISTS lost_person_sightings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lost_person_id UUID NOT NULL REFERENCES lost_person_reports(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES profiles(id),
  location_description TEXT NOT NULL,
  latitude NUMERIC(10, 7),
  longitude NUMERIC(10, 7),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. BHAKTI MEDIA METADATA
CREATE TABLE IF NOT EXISTS bhakti_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  marathi_title VARCHAR(255) NOT NULL,
  artist VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL, -- Bhajan, Abhang, Kirtan, Video
  external_url TEXT NOT NULL,
  thumbnail_url TEXT,
  duration VARCHAR(50) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. WARI ROUTE STAGES
CREATE TABLE IF NOT EXISTS wari_route (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  stage_name VARCHAR(255) NOT NULL,
  sequence_order INT NOT NULL,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 15. INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_services_category ON services(category);
CREATE INDEX IF NOT EXISTS idx_services_location ON services(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_dindis_location ON dindis(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_emergency_status ON emergency_requests(status);
CREATE INDEX IF NOT EXISTS idx_lost_person_status ON lost_person_reports(status, is_approved_by_admin);

-- 16. SUPABASE STORAGE BUCKET MIGRATION SETUP
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('lost-person-images', 'lost-person-images', false),
  ('service-images', 'service-images', true),
  ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- 17. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE palkhi_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE dindis ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE lost_person_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE lost_person_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE bhakti_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE wari_route ENABLE ROW LEVEL SECURITY;

-- Public Read Policies
CREATE POLICY "Public Read Services" ON services FOR SELECT USING (true);
CREATE POLICY "Public Read Service Images" ON service_images FOR SELECT USING (true);
CREATE POLICY "Public Read Palkhi" ON palkhi_tracking FOR SELECT USING (true);
CREATE POLICY "Public Read Dindis" ON dindis FOR SELECT USING (true);
CREATE POLICY "Public Read Approved Lost Persons" ON lost_person_reports FOR SELECT USING (is_approved_by_admin = true);
CREATE POLICY "Public Read Bhakti" ON bhakti_content FOR SELECT USING (true);
CREATE POLICY "Public Read Route" ON wari_route FOR SELECT USING (true);
