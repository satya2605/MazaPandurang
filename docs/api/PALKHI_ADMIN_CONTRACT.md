# API & Security Contract — Central Admin Palkhi Registry & Privileged Location Operator

**Decision / Task ID:** DEC-2026-08-29-013  
**Owner:** Satyajit (Lead Platform & Admin Architect)  
**Target Roles:** Admin (`admin`), Privileged Palkhi Location Operator (`palkhi_operator`), Pilgrim (`pilgrim`), Tilak AI  

---

## 1. Domain Isolation & Architectural Boundary

1. **Palkhi vs. Dindi Domain Isolation**:
   - **Palkhi**: Centrally managed by Admin (`Sant Dnyaneshwar Maharaj Palkhi`, `Sant Tukaram Maharaj Palkhi`). Admin creates, publishes/unpublishes, and assigns a privileged Palkhi Location Operator.
   - **Dindi**: Decentralized, managed by Dindi Leaders via existing submission/approval workflow.
   - Palkhi and Dindi are strictly isolated domain entities in database schemas, REST endpoints, and UI tabs.

2. **Privileged Location Operator Security**:
   - Role `palkhi_operator` added to canonical `user_role` system.
   - Location update endpoint `PATCH /api/palkhi/:id/location` verifies server-side JWT authentication and enforces that `req.user.id === palkhi.assigned_operator_id` (or `req.user.role === 'admin'`).
   - Operators can ONLY update location for their assigned Palkhi(s). Operators CANNOT access `/api/admin/*`, create/delete Palkhis, or modify other domain entities.

3. **Public Exposure & Privacy Protection**:
   - `GET /api/palkhi` returns ONLY `is_published = true` Palkhis for public/pilgrim callers.
   - Default publication state for newly created Palkhis is `is_published = false`.
   - Public API endpoints and Tilak AI NEVER expose `assigned_operator_id`, operator email, or internal administrative metadata to pilgrims.

---

## 2. API Endpoints

### Central Admin Endpoints (`requireAdminRole`)

| Method | Endpoint | Description | Status Code |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/palkhis` | List all Palkhi entities with operator info | 200 OK |
| `GET` | `/api/admin/palkhis/:id` | Get single Palkhi details | 200 OK / 404 |
| `POST` | `/api/admin/palkhis` | Create new Palkhi (defaults `is_published: false`) | 201 Created |
| `PATCH` | `/api/admin/palkhis/:id` | Update metadata or `assigned_operator_id` | 200 OK |
| `PATCH` | `/api/admin/palkhis/:id/publish` | Publish Palkhi to public Live Map & Tilak AI | 200 OK |
| `PATCH` | `/api/admin/palkhis/:id/unpublish` | Unpublish Palkhi from public view | 200 OK |
| `DELETE` | `/api/admin/palkhis/:id` | Delete Palkhi entity | 200 OK |

### Privileged Location Operator Endpoint (`authenticateJwt`)

| Method | Endpoint | Description | Security Check | Status Code |
| :--- | :--- | :--- | :--- | :--- |
| `PATCH` | `/api/palkhi/:id/location` | Update live latitude, longitude, current stage | `req.user.id === assigned_operator_id` | 200 OK / 403 / 404 |

### Public Pilgrim & Tilak AI Endpoint

| Method | Endpoint | Description | Exposure | Status Code |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/palkhi` | Get published Palkhi live position | `is_published = true` ONLY (No operator details) | 200 OK |

---

## 3. Master Test Coverage (60 Tests)

Backend API test suite `backend/src/test_api_suite.js` validates tests 46–60:
- Test 46: Admin listing Palkhis -> 200
- Tests 47–48: Admin creating Palkhi -> 201 (`is_published = false` by default)
- Tests 49–50: Admin operator assignment -> 200
- Test 51: Assigned operator updating location -> 200
- Test 52: Operator updating unassigned Palkhi -> 403 Forbidden / 404
- Tests 53–54: Non-admin accessing `/api/admin/palkhis` -> 403 Forbidden
- Test 55: Public `GET /api/palkhi` hides unpublished Palkhis
- Test 56: Admin publishing Palkhi -> 200
- Tests 57–58: Public `GET /api/palkhi` exposes published Palkhi & preserves operator privacy
- Test 59: Admin unpublishing Palkhi -> 200
- Test 60: Audit trail logging for all Admin Palkhi mutations
