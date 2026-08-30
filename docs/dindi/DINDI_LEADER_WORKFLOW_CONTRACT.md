# Dindi Leader Workflow & Operational Contract

This document defines the architectural boundaries, security contracts, state machines, and API specifications for **Dindi Leaders** and **Dindi Management** in Maza Pandurang.

---

## 1. Domain Separation Contract (Palkhi ≠ Dindi)

- **Palkhi**:
  - Centrally administered procession managed by Platform Admin (`/api/palkhi`).
  - Read-only for pilgrims and Dindi Leaders.
  - Represents the main Saint procession entity (*Sant Dnyaneshwar Maharaj Palkhi*, *Sant Tukaram Maharaj Palkhi*).

- **Dindi**:
  - Independent pilgrim troupe managed by an approved Dindi Leader (`/api/dindis`).
  - Contains troupe members, local route halts, food timings, vehicle information, and member approval workflows.
  - **Dindis are NEVER combined into Palkhi endpoints or UI screens.**

---

## 2. Independent Two-Stage Approval State Machine

```text
                     USER APPLIES
                          ↓
              POST /api/dindi-leader/apply
                          ↓
           PROFILE STATUS: pending, ROLE: dindi_leader
                          ↓
                   ADMIN REVIEW 1
                          ↓
            PATCH /api/admin/dindi-leaders/:id/approve
                          ↓
           PROFILE STATUS: active, ROLE: dindi_leader
                          ↓
                APPROVED LEADER CREATES DINDI
                          ↓
                     POST /api/dindis
                          ↓
                 DINDI STATUS: Pending
                          ↓
                   ADMIN REVIEW 2
                          ↓
              PATCH /api/admin/dindis/:id/approve
                          ↓
                 DINDI STATUS: Active
                          ↓
               JOIN CODE ACTIVATED FOR PILGRIMS
```

- **Unapproved / Pending Dindis**: Join Code remains inactive and unusable. `POST /api/dindis/:id/join` returns HTTP 403 Forbidden.
- **Suspended Dindis**: Live location updates and member joins are blocked (`HTTP 403 Forbidden`).

---

## 3. Authoritative JWT Security Contract

All protected endpoints strictly derive identity and authority from `req.user.id` contained in the verified Supabase JWT Bearer token:

- `leader_id` is assigned server-side (`leader_id = req.user.id`).
- Client-supplied `leader_id`, `user_id`, `x-user-id`, `x-admin-id`, or client role headers are ignored.
- Dindi Leaders can only create, edit, update halts, and approve members for Dindis where `dindi.leader_id === req.user.id`.

---

## 4. Multi-Day Dindi Halt Planning API Contract

- `POST /api/dindis/:id/halts` — Add scheduled halt for Day $N$
- `PUT /api/dindis/halts/:haltId` — Update scheduled halt
- `DELETE /api/dindis/halts/:haltId` — Delete scheduled halt
- `PATCH /api/dindis/:id/location` — Update live GPS coordinates & current halt name

---

## 5. Audit Logging

All administrative actions are logged in `admin_audit_logs`:
- `APPROVE_DINDI_LEADER`, `REJECT_DINDI_LEADER`, `SUSPEND_DINDI_LEADER`
- `APPROVE_DINDI`, `REJECT_DINDI`, `SUSPEND_DINDI`
