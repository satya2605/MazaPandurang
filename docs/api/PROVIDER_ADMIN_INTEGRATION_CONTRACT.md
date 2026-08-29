# Provider Submissions & Admin Control Plane Integration Contract

## Overview
This document specifies the integration contract between provider client modules (NGO Module & Dindi Leader Module) and the Admin Control Plane for moderation, retrieval, approval, rejection, and public visibility.

---

## Architecture Flow

```
NGO MODULE
    │
    │ POST /api/ngos
    ▼
canonical `ngos` (status = 'pending')
    │
    ├── Admin GET /api/admin/ngos?status=pending
    │
    ▼ Admin Moderation
  PATCH /api/admin/ngos/:id/approve  ──► status = 'approved'
  PATCH /api/admin/ngos/:id/reject   ──► status = 'rejected'
    │
    ▼ Public Exposure
  GET /api/ngos                      ──► Only 'approved' NGOs returned
```

```
DINDI LEADER MODULE
    │
    │ POST /api/dindi-leader/apply
    ▼
canonical `profiles` (role = 'dindi_leader', status = 'pending')
    │
    ├── Admin GET /api/admin/dindi-leaders?status=pending
    │
    ▼ Admin Moderation (Independent from Dindi approval)
  PATCH /api/admin/dindi-leaders/:id/approve  ──► status = 'active'
  PATCH /api/admin/dindi-leaders/:id/reject   ──► status = 'rejected'
  PATCH /api/admin/dindi-leaders/:id/suspend  ──► status = 'suspended'
```

```
DINDI MODULE
    │
    │ POST /api/dindis
    ▼
canonical `dindis` (status = 'Pending')
    │
    ├── Admin GET /api/admin/dindis?status=Pending
    │
    ▼ Admin Moderation
  PATCH /api/admin/dindis/:id/approve  ──► status = 'Active'
  PATCH /api/admin/dindis/:id/reject   ──► status = 'Rejected'
  PATCH /api/admin/dindis/:id/suspend  ──► status = 'Suspended'
    │
    ▼ Public Exposure
  GET /api/dindis                      ──► Only 'Active' Dindis returned
```

---

## Independent Approval Lifecycle Rules
1. **Dindi Leader Approval**: Approving a Dindi Leader updates `profiles.status` to `'active'`. Dindi approval remains an independent moderation step.
2. **Dindi Approval**: Approving a Dindi updates `dindis.status` to `'Active'`.
3. **NGO Approval**: Approving an NGO updates `ngos.status` to `'approved'`.
4. **Public Filtering**:
   - `GET /api/ngos` returns ONLY `status = 'approved'` NGOs to public callers.
   - `GET /api/dindis` returns ONLY `status = 'Active'` Dindis to public callers.
5. **Audit Trail Logging**: All moderation actions create an audit log entry in `admin_audit_logs`.
