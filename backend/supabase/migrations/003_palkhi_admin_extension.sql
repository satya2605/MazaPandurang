-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 003
-- Palkhi Administration Registry & Privileged Location Operator
-- ========================================================

-- 1. EXTEND USER ROLE ENUM WITH PALKHI_OPERATOR ROLE
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'palkhi_operator';

-- 2. EXTEND PALKHI TRACKING WITH ADMINISTRATIVE REGISTRY FIELDS
ALTER TABLE palkhi_tracking
ADD COLUMN IF NOT EXISTS saint VARCHAR(255) DEFAULT 'Sant Dnyaneshwar Maharaj',
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS start_point VARCHAR(255) DEFAULT 'Alandi',
ADD COLUMN IF NOT EXISTS destination VARCHAR(255) DEFAULT 'Pandharpur',
ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE',
ADD COLUMN IF NOT EXISTS is_published BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS assigned_operator_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- 3. INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_palkhi_tracking_operator ON palkhi_tracking(assigned_operator_id);
CREATE INDEX IF NOT EXISTS idx_palkhi_tracking_published ON palkhi_tracking(is_published, status);
