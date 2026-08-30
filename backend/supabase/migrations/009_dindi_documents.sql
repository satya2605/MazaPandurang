-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 009
-- Add Leader Photo & Dindi Registration Document Columns to Dindis
-- Ensure Storage Buckets exist for Dindi verification
-- ========================================================

ALTER TABLE public.dindis
  ADD COLUMN IF NOT EXISTS document_url VARCHAR(1024),
  ADD COLUMN IF NOT EXISTS leader_image_url VARCHAR(1024);

INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('dindi-documents', 'dindi-documents', true),
  ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;
