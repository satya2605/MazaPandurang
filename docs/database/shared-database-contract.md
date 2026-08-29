# Shared Supabase Database Technical Contract

This document provides the complete technical specification of the shared **Supabase PostgreSQL + Supabase Storage** database architecture for the **Maza Pandurang Wari** application.

---

## 1. Database Architecture & Technology

- **Database Engine**: PostgreSQL 15+ (Supabase Managed)
- **Extensions**: `uuid-ossp`, `postgis`
- **Spatial Coordinates**: PostGIS `GEOGRAPHY(POINT, 4326)` & `NUMERIC(10, 7)` latitude / longitude
- **Storage Buckets**:
  - `lost-person-images` (**PRIVATE**) — Backend 1-Hour Signed URLs
  - `service-images` (**PUBLIC READ**) — Seva facility photos
  - `profile-images` (**PUBLIC READ**) — User / Dindi avatars
  - `ngo-images` (**PUBLIC READ**) — NGO gallery photos
  - `documents` (**PRIVATE**) — Registration certificates

---

## 2. Table Ownership & Permission Matrix

| Table Name | Owner Module | Pilgrim (Satyajit) | Dindi (Sanket) | Police (Yogeshwari) | NGO (Shrutika) | Citizen (Gauri) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| `profiles` | Shared / System | Read / Own | Read / Own | Read / Own | Read / Own | Read / Own |
| `dindis` | Dindi Leader | Read | CRUD Own | Read | Read | Read |
| `dindi_memberships` | Dindi Leader | Read / Join | CRUD Own | Read | Read | Read |
| `palkhi_tracking` | Authorized / Admin | Read | Read | Read | Read | Read |
| `services` | Provider / Admin | Read | Read | Read / Write Own | Read / Write Own | Read |
| `service_images` | Provider / Admin | Read | Read | Read | Read / Write Own | Read |
| `service_reports` | Public / Admin | Create Report | Read | Review / Resolve | Read | Create Report |
| `ngos` | NGO Volunteer | Read | Read | Read | CRUD Own | Read |
| `ngo_images` | NGO Volunteer | Read | Read | Read | CRUD Own | Read |
| `police_profiles` | Police / Authority | — | — | CRUD Own | — | — |
| `police_units` | Police / Authority | — | — | CRUD | — | — |
| `emergency_requests` | Police / Authority | Create SOS | Create SOS | Review / Resolve | Read | Create SOS |
| `traffic_alerts` | Police / Authority | Read | Read | CRUD | Read | Read |
| `lost_person_reports` | Police / Authority | Read Approved | Read Approved | Review / Approve | Read Approved | Create Report |
| `lost_person_images` | Police / Authority | Read Signed | Read Signed | Upload / Manage | Read Signed | Upload Photo |
| `lost_person_sightings` | Police / Authority | Create Sighting | Create Sighting | Review / Resolve | Create Sighting | Create Sighting |
| `wari_route` | Admin / System | Read | Read | Read | Read | Read |
| `bhakti_content` | Admin / System | Read | Read | Read | Read | Read |
| `donations_info` | Admin / System | Read | Read | Read | Read | Read |

---

## 3. Entity Relationship Graph (Foreign Keys)

```text
profiles (id)
   ├── 1:N ──> dindis (leader_id)
   ├── 1:N ──> dindi_memberships (pilgrim_id)
   ├── 1:1 ──> ngos (user_id)
   │             ├── 1:N ──> ngo_images (ngo_id)
   │             └── 1:N ──> services (provider_id)
   ├── 1:1 ──> police_profiles (user_id)
   │             └── 1:N ──> police_units (assigned_officer_id)
   ├── 1:N ──> service_reports (reporter_id)
   ├── 1:N ──> emergency_requests (requester_id)
   ├── 1:N ──> traffic_alerts (created_by)
   ├── 1:N ──> lost_person_reports (reporter_id)
   └── 1:N ──> lost_person_sightings (reporter_id)

dindis (id)
   └── 1:N ──> dindi_memberships (dindi_id)

services (id)
   ├── 1:N ──> service_images (service_id)
   └── 1:N ──> service_reports (service_id)

lost_person_reports (id)
   ├── 1:N ──> lost_person_images (lost_person_id)
   └── 1:N ──> lost_person_sightings (lost_person_id)
```

---

## 4. API Endpoint Mapping

- `GET /api/health` → System status & Database connection
- `GET /api/palkhi` → `palkhi_tracking`
- `GET /api/dindis` → `dindis` + `dindi_memberships`
- `GET /api/services` → `services` + `service_images`
- `GET /api/wari-route` → `wari_route` (8 Ordered Stages)
- `GET /api/bhakti` → `bhakti_content`
- `GET /api/donations` → `donations_info`
- `GET /api/lost-persons` → `lost_person_reports` (`is_approved_by_admin = true`) + `lost_person_images`
