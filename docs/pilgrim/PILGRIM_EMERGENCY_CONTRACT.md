# Pilgrim Emergency & Safety Integration Contract

## Overview
The Pilgrim Emergency & Safety system provides unified, authenticated, location-aware SOS dispatching across the Pilgrim module (`EmergencyScreen`, Live Wari Map, Tilak AI, and Medical Service Cards).

---

## Server-Side Security & Ownership
1. **Supabase JWT Authentication:**
   - `POST /api/emergencies` strictly derives `requester_id` from `req.user.id` (verified Supabase JWT). Client-supplied `requester_id` values are ignored.
   - Unauthenticated requests return `401 Unauthorized`.
2. **Pilgrim Scope Isolation:**
   - `GET /api/emergencies` filters by `requester_id = req.user.id` when called by a pilgrim, ensuring pilgrims can read only their own emergency records.
3. **Police / Admin Authority Control:**
   - `PATCH /api/emergencies/:id` requires `requireRole(['police_authority', 'admin'])`. Pilgrims attempting to patch emergency statuses receive `403 Forbidden`.

---

## Shared Database Schema & Enums
- **Table:** `emergency_requests`
- **Emergency Types:** `'Medical'`, `'Police'`, `'Lost Person'`, `'Other'`
- **Statuses:** `'pending'`, `'dispatched'`, `'resolved'`, `'cancelled'`

---

## Graceful GPS Handling
- Uses `LocationService`. If GPS coordinates are unavailable or denied, `latitude = 18.3411` and `longitude = 74.0305` fallback coordinates are supplied with `location_name = 'Wari Route (Location Unavailable)'`.
- SOS dispatch is NEVER blocked due to missing GPS.
