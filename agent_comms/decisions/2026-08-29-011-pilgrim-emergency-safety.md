# Architectural Decision Record — DEC-2026-08-29-011: Pilgrim Emergency & Safety Integration

- **Status**: APPROVED
- **Date**: 2026-08-29
- **Deciders**: Platform Architecture Team, Satyajit (Pilgrim Module Lead)

## Context
The Pilgrim module requires a unified emergency assistance workflow connecting pilgrim authentication, GPS location, shared REST API (`/api/emergencies`), Police/Authority dispatch, Tilak AI, and Live Map SOS actions.

## Decisions
1. **Server-Side Identity Enforcement**: `POST /api/emergencies` uses `authenticateJwt` and populates `requester_id = req.user.id`. Client identity override attempts are rejected.
2. **Pilgrim Scope Isolation**: `GET /api/emergencies` isolates pilgrim queries to their own requests.
3. **Police / Admin Authority Control**: `PATCH /api/emergencies/:id` enforces role authorization (`police_authority`, `admin`).
4. **Graceful GPS Fallback**: GPS permission failure does not block SOS dispatch.
5. **Cross-Agent Module Isolation**: No other agent's module directory (`police/`, `dindi/`, `ngo/`, `citizen/`) was modified. Integration contracts are documented via `agent_comms/`.

## Shared Database Schema & Enums
- Table: `emergency_requests` (`id`, `request_code`, `requester_id`, `emergency_type`, `latitude`, `longitude`, `location_name`, `status`, `created_at`, `resolved_at`)
- Enum Types: `Medical`, `Police`, `Lost Person`, `Other`
- Statuses: `pending`, `dispatched`, `resolved`, `cancelled`
