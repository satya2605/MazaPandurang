# Pilgrim Live Wari Map & Location Intelligence Contract

## Overview
The Pilgrim Live Wari Map is the central navigation and location intelligence dashboard for pilgrims.
It consumes live shared REST APIs to present Palkhi positions, 8 procession route stages, verified public Seva facilities with distance metrics, active traffic alerts, and Dindi troupes.

---

## Shared REST API Consumption

1. **`GET /api/palkhi` & `GET /api/palkhi/locations`**:
   - Consumes live Palkhi position, current stage, next stop, and last update time.
2. **`GET /api/wari-route`**:
   - Consumes canonical 8 Wari route procession stages (`sequence_order` ascending).
3. **`GET /api/services` & `GET /api/services/nearest`**:
   - Consumes verified public facilities (`is_verified = true AND is_active = true`).
   - Receives calculated distance when pilgrim coordinates `(latitude, longitude)` are supplied.
4. **`GET /api/traffic-alerts`**:
   - Consumes active traffic alerts (`status = 'ACTIVE'`).
5. **`GET /api/dindis`**:
   - Consumes active Dindis (`status = 'Active'`).
6. **`POST /api/ai/tilak/chat`**:
   - Contextual Tilak AI launcher passing pilgrim location coordinates.

---

## Public Visibility & Safety Rules

1. **Public Only Enforcement:** The map ONLY displays verified Seva facilities (`is_verified = true AND is_active = true`) and active Dindis (`status = 'Active'`).
2. **Privacy Boundary:** Pilgrim coordinates are used locally for distance calculations and passed to `/api/services/nearest` and `/api/ai/tilak/chat`. Personal user credentials, private documents, or private lost person records are NEVER exposed on the map.
3. **Location Permission Graceful Handling:** If GPS permission is denied or unavailable, all map features (Palkhi tracking, route stages, traffic alerts, services) remain fully functional without crashing.
