# SANKET — Module Status

- **Owner**: Sanket
- **Role**: Dindi Leader Module
- **Module Directory**: `lib/modules/dindi/`
- **Branch**: `feature/dindi`
- **Status**: `COMPLETE & REAL-DATA VERIFIED`

---

## 1. Feature Implementation Status

### A. Real Database Source of Truth & Zero-Fake-Data Compliance: `COMPLETE`
- **Elimination of Fallbacks**: `SupabaseDindiRepository` has zero in-memory fallback delegates; production runtime is strictly bound to live Supabase PostgreSQL database endpoints.
- **Empty Database State**: When the database has 0 Dindis, 0 members, or 0 pending requests, the UI displays genuine empty states (`No Dindis Found`, `No Dindis Registered Yet`, `No members found`) without injecting hardcoded mock strings (e.g. "Shree Tukaram Maharaj Dindi No. 12", join code "TK12W4", 42 members).
- **Authentication Source**: `AuthDindiIdentityProvider` dynamically extracts authenticated user profile details from `AuthService().currentProfile`.

### B. Dindi Leader Onboarding & Gatekeeping Flow: `COMPLETE`
- **Registration / Onboarding UI**: `DindiLeaderApplyScreen` allows normal users to apply as a Dindi Leader (`POST /api/dindi-leader/apply`).
- **Gatekeeper**: `DindiGatekeeperScreen` intercepts routing based on `AuthService` profile and role approval status:
  - `pending` $\to$ `DindiPendingApprovalScreen` (displays submitted route/troupe details, "Awaiting Admin Approval" banner, live "Check Approval Status" action, locked management controls).
  - `suspended` $\to$ `DindiSuspendedScreen` (locks controls, explains administrative suspension).
  - `active` $\to$ `MyDindisScreen` (unlocked management dashboard).

### C. Multi-Dindi Management & State Isolation: `COMPLETE`
- Multiple Dindi switching via `MyDindisScreen`.
- Selected Dindi state isolation for members and live status in `DindiStateService`.

### D. Dindi CRUD & REST Integration: `COMPLETE`
- `GET /api/dindis?leader_id=...` (Leader view: lists all owned Dindis).
- `GET /api/dindis` (Public discovery: filtered strictly to `status = 'Active'` Dindis; pending/suspended are hidden).
- `GET /api/dindis/:id` (Details view).
- `POST /api/dindis` (Creates Dindi; requires `status = 'active'`, derives `leader_id` authoritatively).
- `PATCH /api/dindis/:id` (Updates halt, lifecycle status, road status; enforces leader ownership).

### E. Live Member Management & Two-Way Approval: `COMPLETE`
- `GET /api/dindis/:id/members` (Fetches pending requests & active members with joined profile details).
- `POST /api/dindis/:id/join` (Varkari join request; starts in `pending` status, rejects duplicate active/pending requests with 409).
- `PATCH /api/dindi-memberships/:id` (Leader approves with `status = 'active'` or rejects with `status = 'rejected'`; enforces leader ownership).

### F. Dindi Lifecycle & Road Status Control: `COMPLETE`
- Operational lifecycle status (`Active`, `Halted`, `Completed`) in `DindiProfileScreen`.
- Road condition status (`Clear & Moving`, `Slow`, `Crowded`, `Temporarily Blocked`).

---

## 2. Approval Lifecycles

### A. Admin Approval Lifecycle
1. **User Registers / Applies**: `POST /api/dindi-leader/apply` $\to$ `profiles.role = 'dindi_leader'`, `profiles.status = 'pending'`.
2. **Pending Restrictions**: Cannot create/manage Dindis (HTTP 403 `PENDING_APPROVAL`). Dindi management UI locked.
3. **Admin Review & Approval**: Admin approves via `PATCH /api/admin/dindi-leaders/:id/approve` $\to$ `profiles.status = 'active'`.
4. **Active State**: Full management unlocked (`POST /api/dindis`, `PATCH /api/dindis/:id`).
5. **Suspension**: Admin suspends via `PATCH /api/admin/dindi-leaders/:id/suspend` $\to$ `profiles.status = 'suspended'`, Dindis set to `Suspended`.

### B. Dindi Membership Approval Lifecycle
1. **Varkari Discovers Active Dindi**: Discovers active Dindis via `GET /api/dindis`.
2. **Submit Join Request**: `POST /api/dindis/:id/join` $\to$ `dindi_memberships.status = 'pending'`.
3. **Leader Moderation**: Leader reviews pending list in `DindiMembersScreen`.
4. **Accept**: `PATCH /api/dindi-memberships/:id` with `status: 'active'` $\to$ member becomes active.
5. **Reject**: `PATCH /api/dindi-memberships/:id` with `status: 'rejected'` $\to$ member not added to active tally.

---

## 3. External Dependencies
- **Pilgrim Module Join UI**: Satyajit (`lib/modules/pilgrim/`) provides the interactive "Join Dindi by Code" UI modal. Backend endpoints are 100% operational.

---

## 4. Verification Results
- `flutter analyze`: 0 issues found
- `flutter test`: 80/80 tests passing across all modules
- `node backend/src/test_api_suite.js`: 24/24 Master platform API & security tests passing
- `node backend/scripts/test_dindi_onboarding_and_auth.js`: 14/14 Onboarding, authorization, and membership lifecycle tests passing
- `node backend/scripts/test_live_member_rest.js`: 6/6 Live member REST integration tests passing

- **Last Updated**: 2026-08-29 23:12:00 IST
