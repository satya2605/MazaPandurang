# Architectural Decision — 2026-08-29-004

- **Decision ID**: DEC-2026-08-29-004
- **Date**: 2026-08-29 15:44:00 IST
- **Decision Title**: Finalized REST API Endpoint Contracts & Nearest Service Distance Calculation for Maza Pandurang MVP
- **Decision Owner**: SATYAJIT (Lead Agent)
- **Affected Modules**: All Developer Modules (Pilgrim, Dindi, Police, NGO, Citizen)

---

## Context
Standardizing the Node.js Express REST API endpoints and data formats so all 5 developer modules can query the shared backend infrastructure without breaking each other's UI or repositories.

---

## Finalized REST API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/health` | System, database connectivity & storage bucket status check |
| `GET` | `/api/services` | Query services (supports `?category=Medical`) |
| `GET` | `/api/services/nearest` | Query nearest service by `?latitude=...&longitude=...&category=...` |
| `GET` | `/api/services/:id` | Get specific service details by UUID or serviceCode |
| `POST` | `/api/services/:serviceId/reports` | Submit report for incorrect service information |
| `POST` | `/api/services/:serviceId/images` | Upload service facility image (5MB max) |
| `GET` | `/api/palkhi` | Get latest Palkhi tracking stage & coordinates |
| `GET` | `/api/dindis` | List all Dindis |
| `GET` | `/api/dindis/:id` | Get specific Dindi details |
| `GET` | `/api/wari-route` | Get Wari route stages & coordinates |
| `GET` | `/api/bhakti` | Get devotional streaming metadata |
| `GET` | `/api/donations` | Get application support & donation info |
| `POST` | `/api/emergency` | Submit Emergency SOS; calculates & returns nearest medical/police camp |
| `POST` | `/api/lost-persons` | Report missing person (`is_approved_by_admin = false` by default) |
| `GET` | `/api/lost-persons` | List admin-approved lost person reports |
| `GET` | `/api/lost-persons/:id` | Get lost person details & generate temporary signed URL for private photo |
| `POST` | `/api/lost-persons/:id/sightings` | Submit sighting of a missing person |
| `POST` | `/api/lost-persons/:id/images` | Upload missing person photo to private bucket |

---

## Integration Rules for Module Developers
1. **Service Role Secret**: `SUPABASE_SERVICE_ROLE_KEY` is backend-only. Never expose it in client code.
2. **Repository Fallback**: Always wrap HTTP client calls in fallback mechanisms (e.g. `MockPilgrimRepository`) to guarantee demo stability.
