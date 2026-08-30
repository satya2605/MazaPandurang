# Palkhi Administration & Data Boundary Contract

This document defines the architectural boundary, API contract, and operational model for **Palkhi** entities in Maza Pandurang.

---

## 1. Domain Entity Boundary: Palkhi vs Dindi

- **Palkhi**:
  - Centrally administered procession entity (*Sant Dnyaneshwar Maharaj Palkhi*, *Sant Tukaram Maharaj Palkhi*).
  - Managed by Platform Administrator via `/api/admin/palkhis`.
  - Has a multi-day scheduled halt itinerary (`palkhi_halts`).
  - Read-only for Pilgrims via `/api/palkhi`.

- **Dindi**:
  - Independent troupe managed by a Dindi Leader.
  - Moderated by Admin via `/api/admin/dindis`.
  - Exclusively consumed via `/api/dindis`.
  - **Must NOT appear inside Palkhi screens or Palkhi endpoints.**

---

## 2. Palkhi Data Model & Endpoints

### Public Read API
- **Endpoint**: `GET /api/palkhi`
- **Visibility**: Only Palkhis with `is_published = true` and `status = 'ACTIVE'`.
- **Response Format**:
```json
[
  {
    "id": "PALKHI-001",
    "name": "Sant Dnyaneshwar Maharaj Palkhi",
    "saint": "Sant Dnyaneshwar Maharaj",
    "start_point": "Alandi",
    "destination": "Pandharpur",
    "status": "ACTIVE",
    "is_published": true,
    "current_location": {
      "latitude": 18.3411,
      "longitude": 74.0305,
      "current_stage": "Saswad Stay",
      "next_stop": "Jejuri",
      "last_updated": "2026-08-30T06:00:00Z"
    },
    "halts": [
      {
        "id": "HALT-001",
        "day_number": 1,
        "halt_date": "2026-06-18",
        "location_name": "Alandi Departure",
        "approx_latitude": 18.6772,
        "approx_longitude": 73.8967,
        "expected_arrival": "06:00",
        "expected_departure": "10:00",
        "next_destination": "Pune"
      }
    ]
  }
]
```

### Admin Control Plane APIs
- `GET /api/admin/palkhis` (List all Palkhis including unpublished)
- `POST /api/admin/palkhis` (Create Palkhi)
- `PUT /api/admin/palkhis/:id` (Update Palkhi metadata)
- `PATCH /api/admin/palkhis/:id/publish` (Publish Palkhi)
- `PATCH /api/admin/palkhis/:id/unpublish` (Unpublish Palkhi)
- `POST /api/admin/palkhis/:id/halts` (Add scheduled halt)
- `PUT /api/admin/palkhi-halts/:haltId` (Update halt)
- `DELETE /api/admin/palkhi-halts/:haltId` (Delete halt)
