# Architectural Decision Record (ADR)
## DEC-2026-08-29-006: Shared Node.js Express REST API Data Access Layer & Multi-Agent Integration Contract

- **Status**: Approved & Implemented
- **Date**: 2026-08-29
- **Decision Authority**: Satyajit (Lead Integration Agent)
- **Impacted Modules**: Pilgrim, Dindi Leader, Police / Authority, NGO Volunteer, Local Citizen

---

## Context & Problem Statement

Following the completion of the 22-table canonical database schema, all 5 developer agents require a standardized, controlled REST API gateway (`http://localhost:3000/api`) to perform read and write operations without bypassing backend business logic or directly calling Supabase PostgREST.

---

## Decisions Made

1. **Controlled REST Gateway (`http://localhost:3000/api`)**:
   All 5 Flutter modules must consume the Express REST API endpoints rather than issuing raw Supabase client calls.

2. **No Separate Pilgrim Namespace**:
   Pilgrim consumes the canonical shared endpoints (`GET /api/services`, `GET /api/dindis`, `GET /api/palkhi`, `GET /api/wari-route`, `POST /api/emergencies`) according to the resource ownership matrix.

3. **Lost Person Workflow Authorization**:
   - `POST /api/lost-persons` creates reports with `is_approved_by_admin = false` (Pending review).
   - Only Police/Admin can approve cases (`PATCH /api/lost-persons/:id`).
   - `GET /api/lost-persons` for public consumers returns approved/active cases only.
   - Private photo access is provided via signed URLs (`GET /api/lost-persons/:id/photo-url`).

4. **Resource Ownership Enforcement**:
   - Dindi Leaders manage their own Dindis (`PATCH /api/dindis/:id`).
   - NGO Volunteers manage their Seva facilities (`PATCH /api/services/:id`).
   - Police manage traffic alerts, patrol units, emergency SOS dispatches, and lost person approvals.

---

## Verification & Validation

- Created reproducible automated test harness (`backend/src/test_api_suite.js`) running against the local server.
- All 18 endpoints returned `200 OK` / `201 Created` with valid JSON payloads.
- `flutter analyze` and `flutter test` passed cleanly with zero issues.
