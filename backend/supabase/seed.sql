-- ========================================================
-- MAZA PANDURANG — DATABASE DEMO SEED DATA
-- ========================================================

-- Insert Demo Admin Profile
INSERT INTO profiles (id, role, display_name, phone, email, status)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'admin', 'Maza Pandurang Admin', '+919876543210', 'admin@mazapandurang.org', 'active'),
  ('00000000-0000-0000-0000-000000000002', 'dindi_leader', 'Harkal Maharaj', '+919876543211', 'dindi1@mazapandurang.org', 'active')
ON CONFLICT (id) DO NOTHING;

-- Insert Palkhi Tracking Position
INSERT INTO palkhi_tracking (id, name, current_stage, next_stop, latitude, longitude, updated_at)
VALUES (
  '00000000-0000-0000-0000-000000000010',
  'Sant Dnyaneshwar Maharaj Palkhi',
  'Saswad Stay (सासवड मुक्काम)',
  'Jejuri (जेजुरी)',
  18.3411,
  74.0305,
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Insert Wari Services (Medical, Water, Food, Toilet, Shelter, Police, NGO)
INSERT INTO services (service_id, category, name, description, address, latitude, longitude, contact_phone, availability_status, is_verified)
VALUES 
  ('SRV-MED-001', 'Medical', 'Saswad Emergency Medical Camp', '24/7 First Aid, Ambulance, Free Medication.', 'Saswad Palkhi Ground', 18.3411, 74.0305, '+919822011223', 'Open 24/7', true),
  ('SRV-WTR-002', 'Water', 'Palkhi Marg Clean Water Station', 'Filtered cold drinking water & tanker distribution.', 'Hadapsar Bypass Road', 18.4988, 73.9272, '+919822011224', 'Abundant Supply', true),
  ('SRV-FOD-003', 'Food', 'Annadan Seva Camp - Hadapsar', 'Free Mahaprasad (Khichdi, Tea, Upma) for all Varkaris.', 'Hadapsar Phata', 18.5020, 73.9290, '+919822011225', 'Serving Meals', true),
  ('SRV-TLT-004', 'Toilet', 'Mobile Sanitation Unit #12', 'Clean mobile toilets with continuous water supply.', 'Dive Ghat Entry Point', 18.4100, 73.9700, '+919822011226', 'Open', true),
  ('SRV-SHL-005', 'Shelter', 'Varkari Rain Shelter & Rest Pavilion', 'Covered waterproof tent space with sleeping mats.', 'Saswad Market Yard', 18.3430, 74.0320, '+919822011227', 'Beds Available', true),
  ('SRV-POL-006', 'Police', 'Police Help Desk & Lost Child Cell', '24/7 Police assistance and emergency reporting.', 'Saswad Bus Stand', 18.3400, 74.0290, '112', 'Active 24/7', true)
ON CONFLICT (service_id) DO NOTHING;

-- Insert Nearby Dindis
INSERT INTO dindis (dindi_number, name, leader_id, member_count, current_location_name, latitude, longitude, status)
VALUES 
  ('DND-001', 'Alka Talkies Dindi #1', '00000000-0000-0000-0000-000000000002', 450, 'Moving towards Saswad', 18.3420, 74.0310, 'Active'),
  ('DND-002', 'Mauli Swaranand Dindi #45', NULL, 320, 'Halted at Hadapsar', 18.4990, 73.9280, 'Active')
ON CONFLICT (dindi_number) DO NOTHING;

-- Insert Bhakti Media Metadata
INSERT INTO bhakti_content (title, marathi_title, artist, category, external_url, duration)
VALUES 
  ('Maza Pandurang Abhang', 'माझा पांडुरंग अभंग', 'Pandit Bhimsen Joshi', 'Abhang', 'https://example.com/audio/abhang1.mp3', '04:30'),
  ('Gyaneshwar Mauli Haripath', 'ज्ञानेश्वर माउली हरिपाठ', 'Lata Mangeshkar', 'Abhang', 'https://example.com/audio/haripath.mp3', '06:15'),
  ('Wari Bhakti Bhajan Live', 'वारी भक्ती भजन लाईव्ह', 'Varkari Dindi Troupe', 'Bhajan', 'https://example.com/audio/bhajan.mp3', '05:00')
ON CONFLICT DO NOTHING;

-- Insert Wari Route Stages
INSERT INTO wari_route (stage_name, sequence_order, latitude, longitude)
VALUES 
  ('Alandi (आळंदी)', 1, 18.6772, 73.8967),
  ('Pune Stay (पुणे मुक्काम)', 2, 18.5204, 73.8567),
  ('Dive Ghat (दिवे घाट)', 3, 18.4100, 73.9700),
  ('Saswad Stay (सासवड मुक्काम)', 4, 18.3411, 74.0305),
  ('Jejuri (जेजुरी)', 5, 18.2764, 74.1611),
  ('Lonand (लोणंद)', 6, 18.0415, 74.1906),
  ('Phaltan (फलटण)', 7, 17.9877, 74.4312),
  ('Pandharpur (पंढरपूर धाम)', 8, 17.6777, 75.3283)
ON CONFLICT DO NOTHING;
