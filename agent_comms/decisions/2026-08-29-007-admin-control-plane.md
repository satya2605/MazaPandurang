# Architectural Decision Record (ADR)
## DEC-2026-08-29-007: Admin Control Plane, 2-Gate Publication, Audit Trail & Authorization

- **Status**: Approved & Implemented
- **Date**: 2026-08-29
- **Decision Authority**: Lead Architect (Satyajit Agent)
- **Impacted Modules**: Admin, Pilgrim, Dindi Leader, Police / Authority, NGO Volunteer, Local Citizen

---

## Decisions Made

1. **Admin Control Plane over Canonical Schema**:
   Admin is implemented as a verification, moderation, approval, and publication control plane over the 22 canonical database tables without creating duplicate `admin_*` tables.

2. **Two-Gate Publication Model**:
   Services must pass two distinct verification gates before public API exposure:
   - Provider Approved (`ngos.status = 'approved'`)
   - Service Verified & Active (`services.is_verified = true AND services.is_active = true`)

3. **Audit Trail Persistence (`admin_audit_logs`)**:
   Created `admin_audit_logs` table (`id`, `admin_id`, `action`, `target_type`, `target_id`, `reason`, `created_at`) to record every moderation event.

4. **Security & Signed URLs**:
   Server middleware `requireAdminRole` enforces database profile role checks (`profiles.role = 'admin'`). Private documents and photos remain in private buckets (`documents`, `lost-person-images`) and access is granted exclusively through short-lived signed URLs.
