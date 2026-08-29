# Architectural Decision Record — DEC-2026-08-29-012: Provider Submissions & Admin Control Plane Integration

- **Status**: APPROVED
- **Date**: 2026-08-29
- **Deciders**: Shared Platform Lead, Admin Control Plane Team, NGO Lead, Dindi Leader Lead

## Context
NGO applications, Dindi Leader applications, and Dindi registrations are submitted by provider client modules into canonical Supabase tables (`ngos`, `profiles`, `dindis`). The Admin Control Plane requires seamless retrieval, moderation, approval, rejection, and public publishing without duplicating tables or altering client module logic.

## Decisions
1. **Independent Approvals**:
   - Dindi Leader approval: `PATCH /api/admin/dindi-leaders/:id/approve` sets `profiles.status = 'active'`. (Does NOT auto-approve Dindis; Dindi approval is an independent step).
   - Dindi approval: `PATCH /api/admin/dindis/:id/approve` sets `dindis.status = 'Active'`.
   - NGO approval: `PATCH /api/admin/ngos/:id/approve` sets `ngos.status = 'approved'`.
2. **Server-Enforced Public Exposure**:
   - Public `GET /api/ngos` returns ONLY `status = 'approved'` NGOs.
   - Public `GET /api/dindis` returns ONLY `status = 'Active'` Dindis.
3. **Audit Log Trail**: Every moderation action records audit log entries in `admin_audit_logs`.
4. **Zero Client Module Intrusion**: `lib/modules/ngo/` and `lib/modules/dindi/` were untouched.
