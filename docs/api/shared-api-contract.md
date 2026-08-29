# Shared REST API Data Access Contract

This document specifies the complete REST API contract provided by the Node.js Express backend gateway (`http://localhost:3000/api`) for all 5 developer modules (**Satyajit** [Pilgrim], **Sanket** [Dindi Leader], **Yogeshwari** [Police], **Shrutika** [NGO Volunteer], and **Gauri** [Local Citizen]).

---

## 1. Primary Shared API Endpoints

### System & Health
- `GET /api/health` — Backend API status, DB connection check, & Storage bucket status

### User Profiles
- `GET /api/profiles/:id` — Fetch domain profile details by ID
- `PATCH /api/profiles/:id` — Update domain profile details

### Seva Facilities & Reports
- `GET /api/services` — Query Seva facilities (Optional filters: `category`, `status`, `search`)
- `GET /api/services/nearest` — Haversine distance-sorted facility query (`latitude`, `longitude`, `limit`)
- `GET /api/services/:id` — Fetch single Seva facility detail
- `POST /api/services` — Register new Seva facility (NGO / Police / Healthcare)
- `PATCH /api/services/:id` — Update Seva facility details, availability status, or operating info
- `GET /api/services/:id/images` — Fetch facility photo gallery
- `POST /api/service-reports` — Submit citizen report regarding facility location/status issue
- `GET /api/service-reports` — Query service reports (Filter: `status`, `service_id`)
- `PATCH /api/service-reports/:id` — Review/resolve service report (Admin / Police / Provider)

### Dindis & Memberships
- `GET /api/dindis` — List Dindis with leader details & member counts
- `GET /api/dindis/:id` — Fetch single Dindi detail
- `POST /api/dindis` — Register new Dindi (Dindi Leader)
- `PATCH /api/dindis/:id` — Update Dindi location, current halt, road status
- `GET /api/dindis/:id/members` — List members for a Dindi
- `POST /api/dindis/:id/join` — Submit Dindi join request (Status defaults to `pending`)
- `PATCH /api/dindi-memberships/:id` — Review/update Dindi membership status (`pending`/`active`/`rejected`)

### Palkhi, Route & Places
- `GET /api/palkhi` — Fetch live Palkhi position & current stage
- `GET /api/palkhi/locations` — Fetch historical/simulated location history
- `GET /api/wari-route` — Fetch 8 ordered Wari route stages (Alandi → Pune → Dive Ghat → Saswad → Jejuri → Lonand → Phaltan → Pandharpur)
- `GET /api/city-places` — Fetch curated Wari city places (Filter: `category`)
- `GET /api/routes` — Fetch application routes (Filter: `type`)

### Police & Emergency SOS
- `GET /api/traffic-alerts` — List active traffic diversions & road blocks
- `POST /api/traffic-alerts` — Create police traffic alert
- `PATCH /api/traffic-alerts/:id` — Update/resolve traffic alert
- `GET /api/emergencies` — List emergency SOS requests (Filter: `status`)
- `POST /api/emergencies` — Submit emergency SOS request
- `PATCH /api/emergencies/:id` — Resolve or dispatch emergency SOS request
- `GET /api/police/units` — List police patrol units & status

### Lost Persons Workflow
- `GET /api/lost-persons` — List approved missing person cases (`is_approved_by_admin = true`)
- `POST /api/lost-persons` — Submit missing person report (`status = 'missing'`, `is_approved_by_admin = false`, pending review)
- `PATCH /api/lost-persons/:id` — Approve missing person report or update case status
- `POST /api/lost-persons/:id/sightings` — Submit sighting location
- `GET /api/lost-persons/:id/sightings` — List sightings for a case
- `GET /api/lost-persons/:id/photo-url` — Generate 1-hour signed URL for private photo

### NGO Facilities & Gallery
- `GET /api/ngos` — List approved NGOs
- `GET /api/ngos/:id` — Fetch NGO details
- `POST /api/ngos` — Register NGO organization
- `PATCH /api/ngos/:id` — Update NGO profile / verification status
- `GET /api/ngos/:id/images` — List NGO activity gallery photos

### Devotional Content & Support
- `GET /api/bhakti` — List devotional streams & media
- `GET /api/donations-info` — Fetch app support & donation metadata

---

## 2. Pilgrim Module API Rule

> **Pilgrim does not receive a separate API namespace (no `/api/pilgrim/...`). Pilgrim consumes the canonical shared endpoints according to the resource ownership matrix.**
