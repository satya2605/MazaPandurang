# ADR DEC-2026-08-29-013: Admin Palkhi Registry & Privileged Location Operator Management

## Context & Problem Statement

The Maza Pandurang application requires central administration for Palkhi entities (e.g., *Sant Dnyaneshwar Maharaj Palkhi*, *Sant Tukaram Maharaj Palkhi*), distinct from decentralized Dindis. Palkhis must be created, edited, published/unpublished by Admin, and assigned to a privileged Palkhi Location Operator authorized to update live GPS position during Wari.

## Decision Drivers

1. **Strict Palkhi vs. Dindi Domain Isolation**: Palkhi and Dindi are fundamentally different entities. Dindis are managed by Dindi Leaders; Palkhis are centrally administered by Admin.
2. **Privileged Location Operator Security**: Location updates must enforce server-side ownership (`req.user.id === assigned_operator_id`). Location operators must not have Admin access.
3. **Public Exposure & Privacy Safeguards**: Pilgrims and Tilak AI must ONLY see published Palkhi data (`is_published = true`). Operator identity must never be leaked to public endpoints.

## Implemented Architecture

1. **Database Schema Extension** (`backend/supabase/migrations/003_palkhi_admin_extension.sql`):
   - Added `palkhi_operator` enum value to `user_role`.
   - Added `saint`, `description`, `start_point`, `destination`, `status`, `is_published` (default `false`), `assigned_operator_id` (foreign key to `profiles(id)`), `created_at` to `palkhi_tracking`.

2. **Backend API Suite**:
   - Admin CRUD & publication endpoints in `admin.controller.js` / `admin.routes.js`.
   - Privileged location update `PATCH /api/palkhi/:id/location` in `palkhi.controller.js` / `palkhi.routes.js`.
   - Public filter in `getPalkhiTracking` returning only published Palkhis with public field schema.

3. **Tilak AI Integration**:
   - Updated `fetchLiveWariContext` in `tilak.service.js` to query only published Palkhis (`is_published = true`).

4. **Flutter UI**:
   - `AdminPalkhi` model in `admin_models.dart`.
   - Palkhi methods in `admin_repository.dart`.
   - Palkhi Registry moderation tab in `AdminDashboardScreen`.
   - `PalkhiOperatorScreen` dedicated UI for location operators in `lib/modules/operator/screens/palkhi_operator_screen.dart`.

5. **Validation**:
   - Extended master API test suite to 60 tests (All 60 passed).
   - `flutter analyze` clean (0 issues).
   - `flutter test` clean (34/34 tests passed).
