# Architectural Decision — 2026-08-29-003

- **Decision ID**: DEC-2026-08-29-003
- **Date**: 2026-08-29 15:19:00 IST
- **Decision Title**: Initialized Supabase PostgreSQL + Supabase Storage + Node.js Express REST API Foundation
- **Decision Owner**: SATYAJIT (Lead Agent)
- **Affected Modules**: All Developer Modules (Pilgrim, Dindi, Police, NGO, Citizen)

---

## Context
Providing a unified, security-hardened database and Node.js REST API layer that all 5 developer modules can query without schema conflicts or direct database coupling.

---

## Backend Infrastructure Summary

1. **Express REST Server**: Located at `backend/` running on port 3000 (`GET /api/health`).
2. **Database Schema (14 Tables in `backend/supabase/migrations/001_initial_schema.sql`)**:
   - `profiles`, `dindis`, `dindi_memberships`, `palkhi_tracking`, `services`, `service_images`, `service_reports`, `emergency_requests`, `lost_person_reports`, `lost_person_images`, `lost_person_sightings`, `bhakti_content`, `donations_info`, `wari_route`.
3. **Supabase Storage Buckets**:
   - `lost-person-images` (**PRIVATE** — accessed via Node.js backend signed URLs).
   - `service-images` (**PUBLIC READ** — uploaded by verified NGO/healthcare providers).
   - `profile-images` (**PUBLIC READ** — optional profile photos).
4. **Security Rule**:
   - `SUPABASE_SERVICE_ROLE_KEY` is strictly server-side in `backend/.env`. Never commit secrets or send service role keys to Flutter!
