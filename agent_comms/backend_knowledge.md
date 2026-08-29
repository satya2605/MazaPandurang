# Maza Pandurang — Backend Architecture & Integration Knowledge

> **For All Developer Agents (`SATYAJIT`, `SANKET`, `YOGESHWARI`, `SHRUTIKA`, `GAURI`)**  
> **Last Updated**: 2026-08-29 15:53:00 IST  
> **Lead Architectural Agent**: `SATYAJIT`

---

## 🚀 Overview

The backend is built as a lightweight, security-hardened **Node.js Express REST API** connecting directly to **Supabase PostgreSQL** and **Supabase Storage**.

```text
Flutter Mobile / Web UI
       │
       │ HTTP REST APIs (http://localhost:3000/api/...)
       ▼
Node.js + Express API Server (backend/)
       │
       │ Service Role Key (Backend Only! Never committed to Git)
       ▼
Supabase Infrastructure
  ├── PostgreSQL Database (14 Tables)
  └── Supabase Storage (3 Buckets)
```

---

## 🔒 Security & Environment Rules

1. **Service Role Key Boundary**: `SUPABASE_SERVICE_ROLE_KEY` is loaded ONLY in `backend/.env`. It must **NEVER** be committed to Git, logged in console outputs, returned in API health checks, or included in Flutter code.
2. **Environment File**: `backend/.env` is strictly ignored by `.gitignore`.
3. **Public Map Credentials**: MapTiler API key is separate and passed to Flutter via `--dart-define=MAPTILER_API_KEY=...`.

---

## 🗄 Database Schema (14 Tables)

Located in DDL Migration: [`backend/supabase/migrations/001_initial_schema.sql`](file:///s:/Vaarithon/backend/supabase/migrations/001_initial_schema.sql)  
Seed Demo Data: [`backend/supabase/seed.sql`](file:///s:/Vaarithon/backend/supabase/seed.sql)

| Table | Purpose & Module Access | Key Fields |
| :--- | :--- | :--- |
| `profiles` | Shared user profiles & roles across all 5 modules | `id`, `role` (`pilgrim`, `dindi_leader`, `police`, `ngo`, `citizen`, `admin`), `display_name`, `phone`, `email` |
| `dindis` | Dindi directory & leader assignments (`SANKET`) | `id`, `dindi_number`, `name`, `leader_id`, `member_count`, `latitude`, `longitude`, `status` |
| `dindi_memberships` | Pilgrim Dindi memberships | `dindi_id`, `pilgrim_id`, `joined_at` |
| `palkhi_tracking` | Authorized Palkhi live position | `id`, `name`, `current_stage`, `next_stop`, `latitude`, `longitude`, `updated_at` |
| `services` | Seva facilities (Medical, Water, Food, Toilet, Shelter, Police, NGO) | `id`, `service_id` (e.g. `SRV-MED-001`), `category`, `name`, `latitude`, `longitude`, `availability_status`, `is_verified` |
| `service_images` | Photos for Seva facilities | `id`, `service_id`, `storage_path` |
| `service_reports` | Public reports on service data issues | `id`, `service_id`, `report_type`, `description`, `status` |
| `emergency_requests` | Emergency SOS requests | `request_code` (e.g. `EMG-178799...`), `emergency_type`, `latitude`, `longitude`, `status` |
| `lost_person_reports` | Missing person reports | `id`, `person_name`, `age`, `description`, `last_seen_location`, `is_approved_by_admin`, `status` |
| `lost_person_images` | Photos of missing persons (**PRIVATE**) | `id`, `lost_person_id`, `storage_path` |
| `lost_person_sightings` | Sighting reports from pilgrims/citizens | `id`, `lost_person_id`, `location_description`, `latitude`, `longitude` |
| `bhakti_content` | Devotional media metadata | `id`, `title`, `marathi_title`, `artist`, `category`, `duration`, `external_url` |
| `donations_info` | Voluntary app support info | `id`, `title`, `slogan`, `description`, `external_donation_url` |
| `wari_route` | Wari route stage coordinates | `id`, `stage_name`, `sequence_order`, `latitude`, `longitude` |

---

## 📦 Supabase Storage Buckets

1. **`lost-person-images`**: **PRIVATE**
   - Stores photos attached to missing person reports.
   - Public access is forbidden.
   - Accessed via backend signed URLs generated on demand (`GET /api/lost-persons/:id`).
2. **`service-images`**: **PUBLIC READ**
   - Stores NGO, medical camp, toilet, and shelter facility photos.
   - Upload restricted to approved providers (`POST /api/services/:serviceId/images`).
3. **`profile-images`**: **PUBLIC READ**
   - Stores optional user and Dindi profile photos.

---

## 🔌 Complete REST API Endpoints (17 Endpoints)

### 🏥 System & Health
- `GET /api/health` → Returns system health, database connection status, and storage configuration.

### ⛺ Services (`SATYAJIT`, `SHRUTIKA`, `GAURI`)
- `GET /api/services` → List all services (supports `?category=Medical`).
- `GET /api/services/nearest` → Calculates nearest service by `?latitude=18.34&longitude=74.03&category=Medical` using Haversine formula.
- `GET /api/services/:id` → Details for specific service.
- `POST /api/services/:serviceId/reports` → Submit report for incorrect service information.
- `POST /api/services/:serviceId/images` → Upload facility photo (Max 5MB: JPG, PNG, WEBP).

### 🚩 Palkhi Live Track (`SATYAJIT`, `SANKET`)
- `GET /api/palkhi` → Get current Palkhi location, stage (`Saswad Stay`), and next stop (`Jejuri`).

### 🚩 Dindis (`SANKET`, `SATYAJIT`)
- `GET /api/dindis` → List all Dindis, member counts, and current status.
- `GET /api/dindis/:id` → Specific Dindi details.

### 🗺 Wari Route (`SATYAJIT`, `ALL`)
- `GET /api/wari-route` → List ordered route stages (Alandi → Pune → Dive Ghat → Saswad → Jejuri → Lonand → Phaltan → Pandharpur).

### 📻 Bhakti Streaming (`SATYAJIT`)
- `GET /api/bhakti` → List devotional media metadata (Abhang, Haripath, Bhajan).

### 🪙 Donations & Support (`ALL`)
- `GET /api/donations` → Get support info and slogan (*"तुमचा छोटासा हातभार, वारीच्या मोठ्या सेवेसाठी."*).

### 🚨 Emergency SOS (`SATYAJIT`, `YOGESHWARI`, `GAURI`)
- `POST /api/emergency` → Submit Emergency SOS (`Medical`, `Police`, `Lost Person`). Automatically computes and returns nearest medical/police facility with distance in km.

### 🔍 Lost Persons (`YOGESHWARI`, `GAURI`, `SATYAJIT`)
- `POST /api/lost-persons` → Submit missing person report (`is_approved_by_admin = false` by default).
- `GET /api/lost-persons` → List admin-approved missing person reports.
- `GET /api/lost-persons/:id` → Fetch report details and generate 1-hour signed URL for private photo.
- `POST /api/lost-persons/:id/sightings` → Record sighting of missing person.
- `POST /api/lost-persons/:id/images` → Upload photo to private `lost-person-images` bucket.

---

## 🛠 How to Run Backend Locally

```bash
# 1. Navigate to backend directory
cd backend

# 2. Install dependencies (if not already installed)
npm install

# 3. Start API Server (Runs on http://localhost:3000)
npm start
```

---

## 💡 Guidelines for Module Developers

1. **Flutter Base URL**: Consume REST endpoints using `http://localhost:3000` or configure `--dart-define=API_BASE_URL=http://localhost:3000`.
2. **Demo Reliability**: Always wrap HTTP calls in your module's repository layer with a fallback mock implementation (e.g. `MockPilgrimRepository`) to guarantee 100% uptime during demo presentations.
3. **No Direct Database Keys**: Never embed Supabase Service Role Keys in Flutter modules.
