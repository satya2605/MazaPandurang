# Decision — Dindi Leader Workflow, Approval State Machine & Multi-Day Halt Planning

- **Date**: 2026-08-30
- **Author**: Satyajit Bhandari (Lead Platform Integrator) & Sanket (Dindi Module Lead)
- **Status**: APPROVED & IMPLEMENTED

## Context & Decision

1. **Two-Stage Approval Architecture**:
   - Leader approval and Dindi approval are handled independently by Admin.
   - Profile role transitions to `dindi_leader` (status: `pending`) upon application.
   - Admin approves leader profile $\rightarrow$ Leader creates Dindi (status: `Pending`) $\rightarrow$ Admin approves Dindi $\rightarrow$ Dindi becomes `Active` and Join Code unlocks.

2. **Server-Side Identity Derivation**:
   - `leader_id` is always derived from verified Supabase JWT bearer token (`req.user.id`).
   - Client identity spoofing via headers or body fields is rejected or ignored.

3. **Multi-Day Halt Schedule**:
   - Created database migration `008_dindi_halts.sql` with unique constraint `(dindi_id, day_number)`.
   - Dindi Leaders manage day-by-day scheduled stops via `+ Add Halt` dialog on `DindiDashboardScreen`.
