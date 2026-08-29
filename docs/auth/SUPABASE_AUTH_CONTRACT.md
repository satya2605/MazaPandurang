# Supabase Auth & Role-Based Identity Contract

This document defines the **SUPABASE AUTHENTICATION & ROLE IDENTITY CONTRACT** for the Maza Pandurang application.

---

## 🔐 1. Core Authentication Architecture

1. **Supabase Auth as Identity Source**:
   All authentication identity is maintained by Supabase Auth (`auth.users`). Passwords are hashed and managed strictly by Supabase Auth. Passwords MUST NOT be stored in `profiles` or committed to Git.

2. **1:1 UUID Mapping (`auth.users.id = profiles.id`)**:
   Every authenticated user has a corresponding row in `profiles` with identical UUID.

3. **6 Initial Development Personas**:
   - `satyajit@mazapandurang.local` (`pilgrim`): `00000000-0000-0000-0000-000000000001`
   - `sanket@mazapandurang.local` (`dindi_leader`): `00000000-0000-0000-0000-000000000002`
   - `yogeshwari@mazapandurang.local` (`police_authority`): `00000000-0000-0000-0000-000000000003`
   - `shrutika@mazapandurang.local` (`ngo_volunteer`): `00000000-0000-0000-0000-000000000004`
   - `gauri@mazapandurang.local` (`local_citizen`): `00000000-0000-0000-0000-000000000005`
   - `admin@mazapandurang.local` (`admin`): `00000000-0000-0000-0000-000000000006`

4. **JWT Verification Middleware**:
   Express gateway validates `Authorization: Bearer <supabase-jwt>` via `backend/src/middleware/auth.js`.
   Attaches `req.user = { id, email, role, status, profile }`.

---

## 🏛️ 2. Dindi Leader Registration & Admin Approval Workflow

1. **Signup**: User registers with `role = 'dindi_leader'`, `status = 'pending'`.
2. **Apply Endpoint**: `POST /api/dindi-leader/apply` submits leader application details.
3. **Pending State Restrictions**: Pending leaders receive `403 Pending Approval` if attempting to create Dindis (`POST /api/dindis`).
4. **Admin Approval**: Admin reviews application at `/api/admin/dindi-leaders` and approves (`PATCH /api/admin/dindi-leaders/:id/approve` -> `profiles.status = 'active'`). Action is logged in `admin_audit_logs`.
5. **Active State**: Approved leaders receive full Dindi creation & management permissions (`POST /api/dindis` sets `leader_id = req.user.id`).
