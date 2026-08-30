# Decision — Palkhi Registry & Multi-Day Halt Planning Architecture

- **Date**: 2026-08-30
- **Author**: Satyajit Bhandari (Lead Platform Integrator)
- **Status**: APPROVED & IMPLEMENTED

## Context & Decision

1. **Palkhi vs Dindi Domain Separation**:
   - Palkhi entities represent central processions (*Sant Dnyaneshwar Maharaj Palkhi*, *Sant Tukaram Maharaj Palkhi*) managed by Platform Admins.
   - Dindis are independent troupes managed by Dindi Leaders.
   - Palkhi screens exclusively consume `/api/palkhi`. Dindis have been completely removed from Palkhi screens.

2. **Idempotent Multi-Day Halt Schedule**:
   - Schema migration `007_palkhi_halts.sql` defines `palkhi_halts` table.
   - Foreign key constraint: `ON DELETE CASCADE` linked to `palkhi_tracking`.
   - Halts ordered by `day_number ASC`.
   - Admin manages Palkhis and halts directly via Admin Control Plane (`+ Add Halt`). No database resets or wipes were performed.
