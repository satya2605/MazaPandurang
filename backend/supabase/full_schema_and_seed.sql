-- ========================================================
-- MAZA PANDURANG — ALL-IN-ONE SCHEMA & SEED SCRIPT
-- Copy-paste this single script into Supabase SQL Editor & click RUN!
-- ========================================================

-- Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 1. ENUMS
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM (
    'pilgrim',
    'dindi_leader',
    'ngo_volunteer',
    'police_authority',
    'local_citizen',
    'admin'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
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
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE emergency_type_enum AS ENUM (
    'Medical',
    'Police',
    'Lost Person',
    'Other'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE emergency_status_enum AS ENUM (
    'pending',
    'dispatched',
    'resolved',
    'cancelled'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE report_status_enum AS ENUM (
    'pending',
    'reviewed',
    'resolved',
    'rejected'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE lost_person_status_enum AS ENUM (
    'missing',
    'sighted',
    'found'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 2. PROFILES
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
  start_point VARCHAR(255),
  destination VARCHAR(255),
  current_halt VARCHAR(255),
  road_status VARCHAR(50) DEFAULT 'clear',
  join_code VARCHAR(50) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ensure columns exist even if dindis table was created by older baseline migration
ALTER TABLE dindis
ADD COLUMN IF NOT EXISTS start_point VARCHAR(255),
ADD COLUMN IF NOT EXISTS destination VARCHAR(255),
ADD COLUMN IF NOT EXISTS current_halt VARCHAR(255),
ADD COLUMN IF NOT EXISTS road_status VARCHAR(50) DEFAULT 'clear',
ADD COLUMN IF NOT EXISTS join_code VARCHAR(50);

-- 4. DINDI MEMBERSHIPS
CREATE TABLE IF NOT EXISTS dindi_memberships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pilgrim_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  dindi_id UUID NOT NULL REFERENCES dindis(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  role VARCHAR(50) NOT NULL DEFAULT 'warkari',
  requested_at TIMESTAMPTZ DEFAULT NOW(),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(pilgrim_id, dindi_id)
);

ALTER TABLE dindi_memberships
ADD COLUMN IF NOT EXISTS role VARCHAR(50) NOT NULL DEFAULT 'warkari',
ADD COLUMN IF NOT EXISTS requested_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

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

-- 6. SERVICES (Single Canonical Table)
CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_id VARCHAR(50) NOT NULL UNIQUE,
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
  provider_type VARCHAR(50) DEFAULT 'NGO',
  provider_name VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE services
ADD COLUMN IF NOT EXISTS provider_type VARCHAR(50) DEFAULT 'NGO',
ADD COLUMN IF NOT EXISTS provider_name VARCHAR(255);

-- 7. SERVICE IMAGES & REPORTS
CREATE TABLE IF NOT EXISTS service_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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

-- 8. EMERGENCY REQUESTS (SOS Workflow)
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

-- 9. LOST PERSON WORKFLOW
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

CREATE TABLE IF NOT EXISTS lost_person_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lost_person_id UUID NOT NULL REFERENCES lost_person_reports(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS lost_person_sightings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lost_person_id UUID NOT NULL REFERENCES lost_person_reports(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES profiles(id),
  location_description TEXT NOT NULL,
  latitude NUMERIC(10, 7),
  longitude NUMERIC(10, 7),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. BHAKTI & WARI ROUTE
CREATE TABLE IF NOT EXISTS bhakti_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  marathi_title VARCHAR(255) NOT NULL,
  artist VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL,
  external_url TEXT NOT NULL,
  thumbnail_url TEXT,
  duration VARCHAR(50) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wari_route (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  stage_name VARCHAR(255) NOT NULL,
  sequence_order INT NOT NULL,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 11. NGOS & NGO IMAGES
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

-- 12. POLICE PROFILES & UNITS
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

-- 13. TRAFFIC ALERTS & CITY PLACES
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

-- 14. STORAGE BUCKETS
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('lost-person-images', 'lost-person-images', false),
  ('service-images', 'service-images', true),
  ('profile-images', 'profile-images', true),
  ('ngo-images', 'ngo-images', true),
  ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- 15. SEED DATA (DETERMINISTIC & IDEMPOTENT)
INSERT INTO profiles (id, role, display_name, phone, email, status)
VALUES 
  ('00000000-0000-0000-0000-000000000000', 'admin', 'Maza Pandurang Admin', '+919876543200', 'admin@mazapandurang.org', 'active'),
  ('00000000-0000-0000-0000-000000000001', 'pilgrim', 'Satyajit (Pilgrim Lead)', '+919876543210', 'satyajit@mazapandurang.org', 'active'),
  ('00000000-0000-0000-0000-000000000002', 'dindi_leader', 'Sanket Maharaj (Dindi Leader)', '+919876543211', 'sanket@mazapandurang.org', 'active'),
  ('00000000-0000-0000-0000-000000000003', 'police_authority', 'Yogeshwari (Police Officer)', '+919876543212', 'yogeshwari@mazapandurang.org', 'active'),
  ('00000000-0000-0000-0000-000000000004', 'ngo_volunteer', 'Shrutika (NGO Coordinator)', '+919876543213', 'shrutika@mazapandurang.org', 'active'),
  ('00000000-0000-0000-0000-000000000005', 'local_citizen', 'Gauri (Local Citizen)', '+919876543214', 'gauri@mazapandurang.org', 'active')
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  phone = EXCLUDED.phone,
  email = EXCLUDED.email;

INSERT INTO dindis (id, dindi_number, name, leader_id, member_count, current_location_name, latitude, longitude, status, start_point, destination, current_halt, road_status, join_code)
VALUES 
  ('00000000-0000-0000-0000-000000000010', 'DND-001', 'Alka Talkies Dindi #1 (Mauli Prasann)', '00000000-0000-0000-0000-000000000002', 450, 'Saswad Palkhi Ground', 18.3420, 74.0310, 'Active', 'Alandi', 'Pandharpur', 'Saswad Market', 'clear', 'DND123'),
  ('00000000-0000-0000-0000-000000000011', 'DND-002', 'Mauli Swaranand Dindi #45', '00000000-0000-0000-0000-000000000002', 320, 'Hadapsar Bypass', 18.4990, 73.9280, 'Active', 'Pune', 'Pandharpur', 'Hadapsar', 'slow', 'DND456')
ON CONFLICT (id) DO UPDATE SET
  leader_id = EXCLUDED.leader_id,
  member_count = EXCLUDED.member_count;

INSERT INTO dindi_memberships (id, pilgrim_id, dindi_id, status, role, requested_at, joined_at)
VALUES 
  ('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000010', 'active', 'warkari', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

INSERT INTO palkhi_tracking (id, name, current_stage, next_stop, latitude, longitude, last_updated_by, updated_at)
VALUES (
  '00000000-0000-0000-0000-000000000030',
  'Sant Dnyaneshwar Maharaj Palkhi',
  'Saswad Stay (सासवड मुक्काम)',
  'Jejuri (जेजुरी)',
  18.3411,
  74.0305,
  '00000000-0000-0000-0000-000000000000',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  current_stage = EXCLUDED.current_stage;

INSERT INTO ngos (id, user_id, name, registration_number, contact_person, phone, email, primary_category, status)
VALUES 
  ('00000000-0000-0000-0000-000000000050', '00000000-0000-0000-0000-000000000004', 'Seva Varkari Foundation', 'NGO-MH-2026-88', 'Shrutika Volunteer', '+919876543213', 'ngo@mazapandurang.org', 'Medical & Food Seva', 'approved')
ON CONFLICT (id) DO NOTHING;

INSERT INTO ngo_images (id, ngo_id, image_url, caption, display_order)
VALUES 
  ('00000000-0000-0000-0000-000000000051', '00000000-0000-0000-0000-000000000050', 'ngo-images/seva-foundation-01.jpg', 'Annual Medical Seva Camp at Saswad', 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO services (id, service_id, category, name, description, address, latitude, longitude, contact_phone, availability_status, is_verified, provider_id, provider_type, provider_name)
VALUES 
  ('00000000-0000-0000-0000-000000000040', 'SRV-MED-001', 'Medical', 'Saswad Emergency Medical Camp', '24/7 First Aid, Ambulance, Free Medication.', 'Saswad Palkhi Ground', 18.3411, 74.0305, '+919822011223', 'Open 24/7', true, '00000000-0000-0000-0000-000000000004', 'NGO', 'Seva Varkari Foundation'),
  ('00000000-0000-0000-0000-000000000041', 'SRV-WTR-002', 'Water', 'Palkhi Marg Clean Water Station', 'Filtered cold drinking water & tanker distribution.', 'Hadapsar Bypass Road', 18.4988, 73.9272, '+919822011224', 'Abundant Supply', true, '00000000-0000-0000-0000-000000000004', 'NGO', 'Seva Varkari Foundation'),
  ('00000000-0000-0000-0000-000000000042', 'SRV-FOD-003', 'Food', 'Annadan Seva Camp - Hadapsar', 'Free Mahaprasad (Khichdi, Tea, Upma) for all Varkaris.', 'Hadapsar Phata', 18.5020, 73.9290, '+919822011225', 'Serving Meals', true, NULL, 'OTHER', 'Annachhatra Trust'),
  ('00000000-0000-0000-0000-000000000043', 'SRV-TLT-004', 'Toilet', 'Mobile Sanitation Unit #12', 'Clean mobile toilets with continuous water supply.', 'Dive Ghat Entry Point', 18.4100, 73.9700, '+919822011226', 'Open', true, NULL, 'OTHER', 'Municipal Corporation'),
  ('00000000-0000-0000-0000-000000000044', 'SRV-SHL-005', 'Shelter', 'Varkari Rain Shelter & Rest Pavilion', 'Covered waterproof tent space with sleeping mats.', 'Saswad Market Yard', 18.3430, 74.0320, '+919822011227', 'Beds Available', true, NULL, 'OTHER', 'Saswad Gram Panchayat'),
  ('00000000-0000-0000-0000-000000000045', 'SRV-POL-006', 'Police', 'Police Help Desk & Lost Child Cell', '24/7 Police assistance and emergency reporting.', 'Saswad Bus Stand', 18.3400, 74.0290, '112', 'Active 24/7', true, '00000000-0000-0000-0000-000000000003', 'POLICE', 'Saswad Police Station'),
  ('00000000-0000-0000-0000-000000000046', 'SRV-NGO-007', 'NGO', 'NGO Seva & Massage Camp', 'Herbal foot massage and bandage distribution.', 'Saswad Market', 18.3435, 74.0325, '+919765432109', 'Volunteers Active', true, '00000000-0000-0000-0000-000000000004', 'NGO', 'Seva Varkari Foundation')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name;

INSERT INTO service_images (id, service_id, storage_path)
VALUES 
  ('00000000-0000-0000-0000-000000000047', '00000000-0000-0000-0000-000000000040', 'service-images/SRV-MED-001/medical_camp.jpg')
ON CONFLICT (id) DO NOTHING;

INSERT INTO service_reports (id, service_id, reporter_id, report_type, description, status)
VALUES 
  ('00000000-0000-0000-0000-000000000048', '00000000-0000-0000-0000-000000000041', '00000000-0000-0000-0000-000000000005', 'WRONG_AVAILABILITY', 'Water tanker refilling in progress. Temporary 15 min wait.', 'pending')
ON CONFLICT (id) DO NOTHING;

INSERT INTO police_profiles (id, user_id, police_id, name, designation, station_name, phone, role, status)
VALUES 
  ('00000000-0000-0000-0000-000000000060', '00000000-0000-0000-0000-000000000003', 'POL-MH-9988', 'Yogeshwari (Sub-Inspector)', 'Sub-Inspector', 'Saswad Central Station', '+919876543212', 'POLICE_OFFICER', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

INSERT INTO police_units (id, unit_code, name, unit_type, status, latitude, longitude, assigned_officer_id)
VALUES 
  ('00000000-0000-0000-0000-000000000061', 'UNIT-P01', 'Saswad Patrol Unit 1', 'PATROL', 'AVAILABLE', 18.3410, 74.0300, '00000000-0000-0000-0000-000000000060')
ON CONFLICT (id) DO NOTHING;

INSERT INTO traffic_alerts (id, alert_code, title, description, type, severity, status, latitude, longitude, created_by)
VALUES 
  ('00000000-0000-0000-0000-000000000070', 'TRF-001', 'Dive Ghat Heavy Traffic Slowdown', 'Vehicular movement slow due to Palkhi procession climbing ghat.', 'SLOW_TRAFFIC', 'MEDIUM', 'ACTIVE', 18.4100, 73.9700, '00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000071', 'TRF-002', 'Saswad Chowk Road Diversion', 'Heavy vehicles diverted towards Pune-Solapur highway.', 'DIVERSION', 'HIGH', 'ACTIVE', 18.3400, 74.0290, '00000000-0000-0000-0000-000000000003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO emergency_requests (id, request_code, requester_id, emergency_type, latitude, longitude, location_name, status)
VALUES 
  ('00000000-0000-0000-0000-000000000075', 'EMG-1001', '00000000-0000-0000-0000-000000000001', 'Medical', 18.4100, 73.9700, 'Dive Ghat Entry', 'resolved')
ON CONFLICT (id) DO NOTHING;

INSERT INTO lost_person_reports (id, person_name, age, description, last_seen_location, last_seen_latitude, last_seen_longitude, reporter_id, is_approved_by_admin, status)
VALUES 
  ('00000000-0000-0000-0000-000000000080', 'Aarav Patil (Lost Child)', 7, 'Wearing yellow kurta and white pajama. Speaks Marathi.', 'Saswad Market Pavilion', 18.3430, 74.0320, '00000000-0000-0000-0000-000000000005', true, 'missing'),
  ('00000000-0000-0000-0000-000000000081', 'Ganesh Kulkarni (Senior Citizen)', 68, 'Wearing white dhoti and Gandhi cap.', 'Hadapsar Phata', 18.5020, 73.9290, '00000000-0000-0000-0000-000000000005', false, 'missing')
ON CONFLICT (id) DO NOTHING;

INSERT INTO lost_person_images (id, lost_person_id, storage_path)
VALUES 
  ('00000000-0000-0000-0000-000000000082', '00000000-0000-0000-0000-000000000080', 'lost-person-images/00000000-0000-0000-0000-000000000080/photo.jpg')
ON CONFLICT (id) DO NOTHING;

INSERT INTO lost_person_sightings (id, lost_person_id, reporter_id, location_description, latitude, longitude)
VALUES 
  ('00000000-0000-0000-0000-000000000083', '00000000-0000-0000-0000-000000000080', '00000000-0000-0000-0000-000000000001', 'Sighted near Saswad Annadan Seva tent drinking water counter.', 18.3432, 74.0322)
ON CONFLICT (id) DO NOTHING;

INSERT INTO bhakti_content (id, title, marathi_title, artist, category, external_url, thumbnail_url, duration, is_active)
VALUES 
  ('00000000-0000-0000-0000-000000000090', 'Maza Pandurang Abhang', 'माझा पांडुरंग अभंग', 'Pandit Bhimsen Joshi', 'Abhang', 'https://example.com/audio/abhang1.mp3', 'https://example.com/thumb1.jpg', '04:30', true),
  ('00000000-0000-0000-0000-000000000091', 'Gyaneshwar Mauli Haripath', 'ज्ञानेश्वर माउली हरिपाठ', 'Lata Mangeshkar', 'Abhang', 'https://example.com/audio/haripath.mp3', 'https://example.com/thumb2.jpg', '06:15', true),
  ('00000000-0000-0000-0000-000000000092', 'Wari Bhakti Bhajan Live', 'वारी भक्ती भजन लाईव्ह', 'Varkari Dindi Troupe', 'Bhajan', 'https://example.com/audio/bhajan.mp3', 'https://example.com/thumb3.jpg', '05:00', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO wari_route (id, stage_name, sequence_order, latitude, longitude, is_active)
VALUES 
  ('00000000-0000-0000-0000-000000000101', 'Alandi (आळंदी)', 1, 18.6772, 73.8967, true),
  ('00000000-0000-0000-0000-000000000102', 'Pune Stay (पुणे मुक्काम)', 2, 18.5204, 73.8567, true),
  ('00000000-0000-0000-0000-000000000103', 'Dive Ghat (दिवे घाट)', 3, 18.4100, 73.9700, true),
  ('00000000-0000-0000-0000-000000000104', 'Saswad Stay (सासवड मुक्काम)', 4, 18.3411, 74.0305, true),
  ('00000000-0000-0000-0000-000000000105', 'Jejuri (जेजुरी)', 5, 18.2764, 74.1611, true),
  ('00000000-0000-0000-0000-000000000106', 'Lonand (लोणंद)', 6, 18.0415, 74.1906, true),
  ('00000000-0000-0000-0000-000000000107', 'Phaltan (फलटण)', 7, 17.9877, 74.4312, true),
  ('00000000-0000-0000-0000-000000000108', 'Pandharpur (पंढरपूर धाम)', 8, 17.6777, 75.3283, true)
ON CONFLICT (id) DO NOTHING;
