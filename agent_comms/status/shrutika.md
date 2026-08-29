# SHRUTIKA — Module Status

- **Owner**: Shrutika
- **Role**: NGO Volunteer Module
- **Module Directory**: `lib/modules/ngo/`
- **Branch**: `feature/ngo`
- **Status**: `INTEGRATED`

## Task Overview
- **Current Task**: Universal NGO / Seva Detail Page Template & Multi-Criteria Filtering Completed
- **Completed**:
  - **Shared API Integration (`ApiClient` & `AuthService`)**:
    - `GET /api/ngos` & `GET /api/ngos/:id` — Live NGO profile retrieval.
    - `POST /api/ngos` — Submits NGO application in `pending` moderation state.
    - `PATCH /api/ngos/:id` — Updates organization profile details.
    - `GET /api/ngos/:id/images` — Fetches NGO gallery verification photos.
    - `GET /api/services?all=true` & `GET /api/services/:id` — Live Seva facility data with dual-table `service_details` joined data.
    - `POST /api/services` — Creates services with `is_verified: false` for admin moderation.
    - `PATCH /api/services/:id` — Updates facility availability and details in real-time.
    - `GET /api/services/:id/images` — Fetches facility photos.
  - **Universal NGO / Seva Detail Page Template**:
    - Consistent, canonical 8-section layout across **ALL** seva categories:
      1. Header (Back button, Service Title, Edit action if authorized, Category badge with theme color & icon).
      2. Live Availability Status Card (Overall status `AVAILABLE`/`LIMITED`/`CLOSED`, relative last updated time, Change Status button, category-specific compact metric badge).
      3. Emergency Support & Ambulance Card (Rendered only when emergency assistance is available).
      4. Dynamic Service-Specific Information Modules (Medical: Bed & Doctor cards; Food: Meals & Menu cards; Shelter: Space capacity & Section breakdown; Water: Jal Seva capacity & Active taps; Clothing: Stock & Distribution items; Sanitation: Bio-toilets & Cleaning schedule; Volunteer: Active staff & Languages; Emergency: Rescue boats & Standby teams).
      5. Seva Overview & Description (Facilities checklist, 24x7 active badge, operating hours).
      6. Location & Coordinates Card (Location name, coordinates, "View on Map" direct action).
      7. Contact & Inquiry Card (Desk phone, alternate helpline, green "Call NGO" action).
      8. Last Updated Footer (Relative timestamp).
  - **Independent Resource Controls & Bottom Sheet Modal**:
    - Real-time modal to update availability and category-appropriate resources dynamically (Beds, Doctors, Ambulances, Meals, Spaces, Water capacity, Emergency flag).
  - **Multi-Criteria Independent Filtering**:
    - `NgoServiceFilter` / `MedicalServiceFilter` supporting independent filtering on Service Type, Live Status, Open Now, Distance, Emergency Support, Bed Availability, Doctor Availability, Ambulance Availability, Food Availability, Shelter Availability, Water Availability.
  - **Image Workflow & Supabase Compatibility**:
    - Multi-image gallery with thumbnail carousel, image compression, and Supabase storage upload.
  - **Testing & Verification**:
    - All 58 test groups in `test/ngo/ngo_module_test.dart` passing with 100% success.
    - `flutter analyze lib/modules/ngo test/ngo` reported 0 issues.
- **Working On**: Ready for review / testing
- **Blocked**: No
- **Needs Communication**: No
- **Last Updated**: 2026-08-30 01:10:00 IST

