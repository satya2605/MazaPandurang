# Multi-Agent API Integration Contract & Rules

This document is the **MANDATORY API CONTRACT** for all 5 developer agents working on the Maza Pandurang application:

1. **Satyajit** — Pilgrim Module (`lib/modules/pilgrim/`)
2. **Sanket** — Dindi Leader Module (`lib/modules/dindi/`)
3. **Yogeshwari** — Police / Authority Module (`lib/modules/police/`)
4. **Shrutika** — NGO Volunteer Module (`lib/modules/ngo/`)
5. **Gauri** — Local Citizen Module (`lib/modules/citizen/`)

---

## 🚨 DO NOT BYPASS THE API

> **Flutter agents must not directly call Supabase/PostgREST for application data.**
> **All application data access must go through the Node.js Express `/api/*` gateway.**
>
> Agents must not create:
> - `ngo_*` API duplicates
> - `citizen_*` API duplicates
> - `pilgrim_*` API duplicates
> - `police_*` copies of shared resources
> - alternate endpoints for the same database resource
>
> **Use the canonical shared endpoints.**

---

## 📊 API Resource Ownership Matrix

| Resource | Owner Module | Pilgrim (Satyajit) | Dindi (Sanket) | Police (Yogeshwari) | NGO (Shrutika) | Citizen (Gauri) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Profiles** | Shared / System | Read / Own | Read / Own | Read / Own | Read / Own | Read / Own |
| **Services** | Provider / Admin | Read | Read | Manage Own | Manage Own | Read |
| **Service Reports** | Public / Admin | Create | Read | Review / Resolve | Read | Create |
| **Dindis** | Dindi Leader | Read / Join | Manage Own | Read | Read | Read |
| **Dindi Memberships** | Dindi Leader | Read / Join | Manage Own | Read | Read | Read |
| **Palkhi Tracking** | Authorized / Admin | Read | Read | Read | Read | Read |
| **Wari Route** | Admin / System | Read | Read | Read | Read | Read |
| **Traffic Alerts** | Police / Authority | Read | Read | Manage | Read | Read |
| **Emergency SOS** | Police / Authority | Create | Create | Manage | Read | Create |
| **Police Units** | Police / Authority | — | — | Manage | — | — |
| **Lost Persons** | Police / Authority | Read Approved / Sighting | Read Approved / Sighting | Manage / Approve | Read Approved / Sighting | Create / Sighting |
| **NGO Profiles** | NGO Volunteer | Read | Read | Read | Manage Own | Read |
| **Bhakti Content** | Admin / System | Read | Read | Read | Read | Read |

---

## 🔒 Server-Side Authorization & Authorization Rules

1. **Lost Person Workflow**: `POST /api/lost-persons` creates missing person reports with `status = 'missing'` and `is_approved_by_admin = false` (pending review). Only Police/Admin can approve reports (`PATCH /api/lost-persons/:id`). `GET /api/lost-persons` returns approved/active cases only.
2. **Resource Ownership**: Dindi Leaders can only update Dindis they own (`leader_id`). NGO volunteers can only update Seva facilities they manage (`provider_id`).
3. **Private Photo Access**: Private lost person photos must be accessed via signed URLs (`GET /api/lost-persons/:id/photo-url`).
