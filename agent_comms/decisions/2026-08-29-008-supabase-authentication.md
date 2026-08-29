# Architectural Decision Record (ADR)
## DEC-2026-08-29-008: Supabase Auth, JWT Authorization & Dindi Leader Approval Workflow

- **Status**: Approved & Implemented
- **Date**: 2026-08-29
- **Decision Authority**: Lead Integration Architect (Satyajit Agent)
- **Impacted Modules**: Pilgrim, Dindi Leader, Police / Authority, NGO Volunteer, Local Citizen, Admin Control Plane

---

## Context & Problem Statement

All 5 developer modules and the Admin Control Plane require production-style authentication and role authorization without hardcoding credentials or trusting unauthenticated client headers.

---

## Decisions Made

1. **Supabase Auth as Canonical Identity**:
   Use email + password via Supabase Auth (`auth.users`). Passwords are not stored in PostgreSQL `profiles` and are never committed to Git.

2. **1:1 UUID Identity Mapping**:
   `auth.users.id` matches `profiles.id` exactly for all personas.

3. **JWT Verification & Role Middleware**:
   Express gateway validates `Authorization: Bearer <access_token>` in `backend/src/middleware/auth.js` and derives `req.user = { id, email, role, status, profile }`.

4. **Dindi Leader Approval Workflow**:
   - Dindi Leaders register with `role = 'dindi_leader'`, `status = 'pending'`.
   - Pending leaders cannot create or manage Dindis (`403 Forbidden`).
   - Admin reviews applications at `GET /api/admin/dindi-leaders` and approves (`PATCH /api/admin/dindi-leaders/:id/approve` -> `status = 'active'`).
   - Approved leaders gain full Dindi management privileges. All admin actions log to `admin_audit_logs`.

---

## Module Developer Guidance

- **Satyajit (Pilgrim)**: Uses authenticated pilgrim identity (`satyajit@mazapandurang.local`).
- **Sanket (Dindi Leader)**: Requires Admin approval (`status = 'active'`) before creating/managing Dindis.
- **Yogeshwari (Police)**: Uses authenticated police identity for traffic & emergency management.
- **Shrutika (NGO Volunteer)**: Uses authenticated NGO identity; services require Admin 2-gate publication.
- **Gauri (Local Citizen)**: Uses authenticated citizen identity for public reporting & traffic updates.
- **Admin**: Controls verification, approval, publication, moderation, suspension, and audit.
