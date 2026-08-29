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

## 🛠️ Multi-Agent Platform Boundaries

### Shared Platform Owner (Satyajit Lead Agent / Architecture)
- Supabase Auth & JWT verification middleware (`backend/src/middleware/auth.js`)
- Admin Control Plane (`/api/admin/*`) & Audit Logging (`admin_audit_logs`)
- Centralized Flutter `AuthService` (`lib/core/auth/auth_service.dart`) & `ApiClient` (`lib/core/api/api_client.dart`)
- Shared Navigation & Route Registry (`lib/common/navigation/app_routes.dart`)
- Database Schema, Migrations, and Idempotent Provisioning (`backend/scripts/provision-demo-users.js`)
- Shared Technical Contracts (`docs/auth/`, `docs/api/`, `docs/database/`, `agent_comms/`)

### Module Developers
- **Satyajit — Pilgrim (`lib/modules/pilgrim/`)**: Pilgrim UI, map routes, service discovery, Bhakti playback.
- **Sanket — Dindi Leader (`lib/modules/dindi/`)**: Dindi Leader UI, group announcements, live tracking (unlocked after Admin approval).
- **Yogeshwari — Police / Authority (`lib/modules/police/`)**: Police UI, traffic alerts, emergency SOS dispatch.
- **Shrutika — NGO Volunteer (`lib/modules/ngo/`)**: NGO UI, facility registration, volunteer coordination.
- **Gauri — Local Citizen (`lib/modules/citizen/`)**: Citizen UI, traffic/parking guidance, missing person reporting.

> **Module Agent Rules**: Module agents must NOT create duplicate `services`, `dindis`, `users`, or `auth` tables, nor bypass the Express REST gateway.

