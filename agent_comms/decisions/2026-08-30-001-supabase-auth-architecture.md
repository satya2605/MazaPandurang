# ADR 2026-08-30-001: Platform-Wide Supabase Authentication & Security Architecture

- **Status**: APPROVED & IMPLEMENTED
- **Date**: 2026-08-30
- **Authors**: Satyajit & Antigravity Agent
- **Target Component**: Express API Gateway, Flutter Client Core (`AuthService`, `ApiClient`), Supabase DB Schema

---

## Context & Problem Statement

Prior to this pass, developer modules used legacy header fallbacks (`x-user-id`, `x-admin-id`, `x-admin-role`) for local development testing. As we consolidate the platform into production readiness, identity and role authorization must be enforced authoritatively through real Supabase Authentication (Email + Password and Google Sign-In).

---

## Decisions

1. **Server-Side Identity Supremacy**:
   - Disallow all legacy header overrides (`x-user-id`, `x-admin-id`, `x-admin-role`).
   - Require `Authorization: Bearer <Supabase JWT>` on all protected endpoints.
   - Derive user identity authoritatively from `req.user.id` after JWT verification via `authenticateJwt`.

2. **Non-Destructive Database Policy**:
   - Zero database resets, zero table drops, and zero seed wipes.
   - Implement `006_auth_user_profile_trigger.sql` using `IF NOT EXISTS` check to preserve existing seeded/provisioned profiles (`admin`, `dindi_leader`, `police_authority`, `ngo_volunteer`, `palkhi_operator`).

3. **Supabase Auth Methods**:
   - Email + Password (sign up default role: `pilgrim`, status: `active`).
   - Google OAuth (`OAuthProvider.google`).

4. **Shared Client & AuthService Boundary**:
   - Single canonical `AuthService` (`lib/core/auth/auth_service.dart`).
   - Shared `ApiClient` (`lib/core/api/api_client.dart`) automatically attaches `Authorization: Bearer <token>`.
   - Domain modules consume `ApiClient()` without custom authentication logic.

5. **30-Point Security Test Suite Verification**:
   - Master REST API test suite (`backend/src/test_api_suite.js`) updated with 30 checks covering JWT verification, role authorization, identity derivation, Palkhi operator scoping, and suspended account blocking.

---

## Consequences

- All client spoofing attempts (`user_id`, `leader_id`, `requester_id`, `role`) are rejected or ignored server-side.
- Legacy headers cannot bypass authentication.
- Existing developer personas and privileged roles remain intact.
- Master API suite passed 30/30 (100% success rate).
- Full Flutter test suite passed 148/148 checks cleanly.
