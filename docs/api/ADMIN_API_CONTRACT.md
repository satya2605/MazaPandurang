# Admin Control Plane & Workflow API Contract

This document defines the **ADMIN CONTROL PLANE API CONTRACT** for the Maza Pandurang application.

Admin functions as the **verification, moderation, approval, publication, and account governance control plane** over the existing 22 canonical tables.

---

## 🏛️ Architectural Principles

1. **Control Plane over Canonical Data**:
   Admin does **not** duplicate resources or own separate tables (`admin_services`, `admin_ngos`, `admin_dindis`). Admin acts directly on canonical domain tables (`ngos`, `services`, `dindis`, `lost_person_reports`, `service_reports`, `profiles`).

2. **Two-Gate Publication Workflow**:
   - **Gate 1**: Provider Verification (`ngos.status = 'approved'`)
   - **Gate 2**: Service Verification & Publication (`services.is_verified = true AND services.is_active = true`)
   Public endpoints (`GET /api/services`, `GET /api/ngos`, `GET /api/lost-persons`) strictly filter out unapproved/pending resources.

3. **Auditability**:
   Every Admin approval, rejection, or suspension action logs a record in `admin_audit_logs` (`id`, `admin_id`, `action`, `target_type`, `target_id`, `reason`, `created_at`).

4. **Security & Authorization**:
   All `/api/admin/*` endpoints require Admin authorization (`profiles.role = 'admin'`). Non-admin requests receive `403 Forbidden`. Private storage buckets (`documents`, `lost-person-images`) remain private and generate short-lived signed URLs.

---

## 📡 Admin Endpoints Summary

### Dashboard & Audit Logs
- `GET /api/admin/dashboard` — Live system counts (`pending_ngos`, `pending_services`, `pending_dindis`, `pending_lost_person_reports`, `open_service_reports`, `active_emergencies`, `active_traffic_alerts`)
- `GET /api/admin/audit-logs` — List recent moderation audit trail records

### NGO Moderation
- `GET /api/admin/ngos` — Query NGOs (`?status=pending|approved|rejected`)
- `GET /api/admin/ngos/:id` — Detailed NGO inspection with gallery photos & associated services
- `PATCH /api/admin/ngos/:id/approve` — Approve NGO registration
- `PATCH /api/admin/ngos/:id/reject` — Reject NGO registration (with optional `reason`)
- `GET /api/admin/ngos/:id/documents/:documentId/url` — Generate 1-hour signed URL for private verification documents

### Service Moderation & Publication
- `GET /api/admin/services` — Query Seva facilities (`?status=pending|approved`, `category`, `provider_id`)
- `PATCH /api/admin/services/:id/approve` — Verify facility (`is_verified = true`)
- `PATCH /api/admin/services/:id/reject` — Reject facility (`is_verified = false`, `is_active = false`)
- `PATCH /api/admin/services/:id/publish` — Publish facility (`is_active = true`)
- `PATCH /api/admin/services/:id/unpublish` — Unpublish facility (`is_active = false`)

### Dindi Moderation
- `GET /api/admin/dindis` — Query Dindis (`?status=Active|Pending|Suspended`)
- `PATCH /api/admin/dindis/:id/approve` — Approve Dindi (`status = 'Active'`)
- `PATCH /api/admin/dindis/:id/suspend` — Suspend Dindi (`status = 'Suspended'`)

### Lost Person Moderation
- `GET /api/admin/lost-persons` — Query missing person cases (`?status=pending|approved`)
- `PATCH /api/admin/lost-persons/:id/approve` — Approve case for public broadcast (`is_approved_by_admin = true`)
- `PATCH /api/admin/lost-persons/:id/reject` — Reject missing person report

### User Governance
- `GET /api/admin/users` — Query user profiles (`?role=...`, `?status=...`)
- `PATCH /api/admin/users/:id/status` — Update account status (`active` / `suspended`)
