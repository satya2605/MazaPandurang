# Supabase Authentication & Security Contract

**Maza Pandurang Platform — Version 1.0.0**

This document establishes the canonical contract for Supabase Authentication, JWT verification, role authorization, and server-side identity derivation across the Maza Pandurang platform.

---

## 1. Core Architecture

```
Flutter Client (supabase_flutter)
   │
   ├─► Email/Password Sign In & Sign Up
   └─► Google OAuth Sign In (OAuthProvider.google)
         │
         ▼
Supabase Auth (auth.users)
         │
         ▼ (handle_new_user trigger)
public.profiles (id, email, display_name, role, status)
         │
         ▼ (Supabase JWT access_token)
ApiClient (Authorization: Bearer <token>)
         │
         ▼
Express Gateway (authenticateJwt middleware)
         │
         ▼
req.user = { id, email, role, status, profile }
         │
         ├─► requireRole('admin') / requireRole('police_authority') / requireRole('palkhi_operator')
         └─► Server-derived ownership (leader_id, requester_id, assigned_operator_id)
```

---

## 2. Server-Side Identity Supremacy

- **No Client Spoofing**: Client-supplied headers (`x-user-id`, `x-admin-id`, `x-admin-role`) and request body fields (`user_id`, `requester_id`, `leader_id`, `assigned_operator_id`) are NEVER trusted for identity.
- **Server Identity**: Protected routes derive user identity authoritatively from `req.user.id` after JWT verification via `authenticateJwt`.
- **401 Unauthorized**: Any request lacking a valid `Authorization: Bearer <token>` header on a protected endpoint is rejected with HTTP status `401`.
- **403 Suspended**: Any request from an account with `profile.status === 'suspended'` is rejected with HTTP status `403`.

---

## 3. Profile Preservation & Provisioning Rule

- Database Migration: `006_auth_user_profile_trigger.sql` defines `public.handle_new_user()`.
- **Idempotency Policy**:
  - `IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = NEW.id)`
  - New sign-ups receive default `role: 'pilgrim'`, `status: 'active'`.
  - Existing profiles (e.g. provisioned `admin`, `dindi_leader`, `police_authority`, `ngo_volunteer`, `palkhi_operator`) are **preserved without modification**. Privileged users are NEVER accidentally downgraded to `pilgrim`.

---

## 4. Platform Roles & Authorization Scope

| Role Key | Name | Capabilities | Governance |
| :--- | :--- | :--- | :--- |
| `pilgrim` | Pilgrim | Live Wari Map, Tilak AI, Emergency SOS, Service Discovery, Dindi tracking | Default for all new signups |
| `dindi_leader` | Dindi Leader | Dindi creation, member request moderation, lifecycle status (Active/Halted), road alerts | Applied via `/api/dindi-leader/apply`, approved by Admin |
| `ngo_volunteer` | NGO Volunteer | Seva registration, service availability updates, photo verification, facility rosters | Applied via NGO application, approved by Admin |
| `police_authority` | Police Authority | Police Command dashboard, emergency dispatch state machine, lost person broadcasts, traffic alerts | Provisioned by Admin |
| `local_citizen` | Local Citizen | Local Citizen citizen workflows and Wari feedback | Default / Citizen role |
| `palkhi_operator` | Palkhi Location Operator | Live location updates ONLY for assigned Palkhi | Centrally assigned by Admin |
| `admin` | Administrator | Admin Control Plane, Palkhi Registry, moderation of NGOs, Dindi Leaders, Services, Audit Logs | Centrally managed |

---

## 5. Client Integration Rules (Flutter & Web)

- **AuthService**: Single canonical service in `lib/core/auth/auth_service.dart`. Provides `signInWithEmailPassword()`, `signUpWithEmailPassword()`, `signInWithGoogle()`, `signOut()`, `restoreSession()`, `currentUser`, `currentProfile`, `accessToken`.
- **ApiClient**: Shared client in `lib/core/api/api_client.dart` automatically injects `Authorization: Bearer <accessToken>` into all outgoing API requests. Domain repositories MUST consume `ApiClient()` without implementing custom headers.
- **Login UI**: Centralized entry screen in `lib/core/auth/screens/login_screen.dart` with Email/Password fields, "Continue with Google" button, loading states, and error alerts.
- **Role Routing**: Post-auth routing is driven strictly by `profile.role` returned by the server. UI role selectors are not authorization boundaries.
