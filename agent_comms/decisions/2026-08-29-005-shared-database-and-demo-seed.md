# Architectural Decision Record (ADR)
## DEC-2026-08-29-005: Shared Canonical Supabase Database Schema & Multi-Agent Seed Foundation

- **Status**: Approved & Applied
- **Date**: 2026-08-29
- **Decision Authority**: Satyajit (Lead Integration Agent)
- **Impacted Modules**: Pilgrim, Dindi Leader, Police / Authority, NGO Volunteer, Local Citizen

---

## Context & Problem Statement

Each of the 5 developers working on the Maza Pandurang application was independently building UI components for shared entities (Services, Dindis, Palkhi, Traffic, Lost Persons). Without a single database contract, developers risk creating competing module-specific duplicate tables (`ngo_services`, `citizen_services`, `police_services`).

---

## Decisions Made

1. **Single Canonical Tables**: Established one shared PostgreSQL schema covering all 5 modules:
   - `services` (Covering Medical, Water, Food, Toilet, Shelter, Police, NGO)
   - `dindis` & `dindi_memberships`
   - `wari_route` (8 Ordered Stages)
   - `palkhi_tracking`
   - `profiles`
   - `lost_person_reports`, `lost_person_images`, `lost_person_sightings`
   - `emergency_requests`
   - `traffic_alerts`
   - `ngos` & `ngo_images`
   - `police_profiles` & `police_units`

2. **Domain Profiles vs Supabase Auth**:
   Seed data in `profiles` provides domain-level demo accounts for the 5 hackathon developers without injecting fake credentials into Supabase Auth.

3. **Polymorphic FK & Clean Provider Contract**:
   `services.provider_id` explicitly references `profiles(id)` as a valid PostgreSQL foreign key, with `provider_type` (`NGO`, `POLICE`, `HEALTHCARE`, `OTHER`) and `provider_name`.

4. **Idempotent Master Seed (`seed.sql`)**:
   Deterministic fixed UUIDs (`00000000-0000-0000-0000-...`) and `INSERT ... ON CONFLICT (...) DO UPDATE / DO NOTHING` statements enable `seed.sql` to be run repeatedly without duplicating data.

5. **Storage Bucket Visibility**:
   - `lost-person-images`: **PRIVATE** (Backend 1-hour signed URLs)
   - `service-images`: **PUBLIC READ**
   - `profile-images`: **PUBLIC READ**
   - `ngo-images`: **PUBLIC READ**
   - `documents`: **PRIVATE**

---

## Verification & Validation

- `backend/supabase/verify_seed.sql` assertion script created and verified.
- `GET /api/health`, `/api/services`, `/api/palkhi`, `/api/dindis`, `/api/wari-route`, `/api/lost-persons` endpoints tested and functional.
- `flutter analyze` and `flutter test` passed cleanly with zero issues.
