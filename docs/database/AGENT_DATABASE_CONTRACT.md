# Multi-Agent Shared Database Contract & Rules

This document is the **MANDATORY CONTRACT** for all 5 developer agents working on the Maza Pandurang application:

1. **Satyajit** — Pilgrim Module (`lib/modules/pilgrim/`)
2. **Sanket** — Dindi Leader Module (`lib/modules/dindi/`)
3. **Yogeshwari** — Police / Authority Module (`lib/modules/police/`)
4. **Shrutika** — NGO Volunteer Module (`lib/modules/ngo/`)
5. **Gauri** — Local Citizen Module (`lib/modules/citizen/`)

---

## ⛔ CRITICAL RULE: NO DUPLICATE MODULE TABLES

Do **NOT** create duplicate, module-specific copies of shared database entities.

### 🚫 DO NOT CREATE:
- `citizen_services`, `ngo_services`, `police_services`, `pilgrim_services`
- `citizen_dindis`, `police_dindis`, `pilgrim_dindis`
- `citizen_routes`, `pilgrim_routes`, `dindi_routes`
- `citizen_users`, `police_users`, `ngo_users`, `dindi_users`

### ✅ USE THE SINGLE CANONICAL TABLES:
- `services` (Covering Medical, Water, Food, Toilet, Shelter, Police, NGO)
- `dindis` & `dindi_memberships`
- `wari_route` (8 Ordered Stages: Alandi → Pune → Dive Ghat → Saswad → Jejuri → Lonand → Phaltan → Pandharpur)
- `palkhi_tracking`
- `profiles`
- `lost_person_reports`, `lost_person_images`, `lost_person_sightings`
- `emergency_requests`
- `traffic_alerts`

---

## 👥 Persona Profile UUID Mapping

For local testing and seed queries, use these deterministic fixed UUIDs:

- **Admin Persona**: `00000000-0000-0000-0000-000000000000` (`admin`)
- **Satyajit (Pilgrim)**: `00000000-0000-0000-0000-000000000001` (`pilgrim`)
- **Sanket (Dindi Leader)**: `00000000-0000-0000-0000-000000000002` (`dindi_leader`)
- **Yogeshwari (Police)**: `00000000-0000-0000-0000-000000000003` (`police_authority`)
- **Shrutika (NGO Volunteer)**: `00000000-0000-0000-0000-000000000004` (`ngo_volunteer`)
- **Gauri (Local Citizen)**: `00000000-0000-0000-0000-000000000005` (`local_citizen`)

---

## 🔒 Security & API Access Guidelines

1. **Node.js Gateway**: Perform write operations (`POST`, `PUT`, `DELETE`) via the Node.js REST API endpoints rather than direct database writes from Flutter.
2. **Private Storage**: Photos in `lost-person-images` bucket are **PRIVATE**. Access via backend API signed URLs (`GET /api/lost-persons/:id`).
3. **Public Storage**: Facility photos in `service-images`, avatars in `profile-images`, and NGO photos in `ngo-images` are **PUBLIC READ**.
