# Architectural Decision Record — DEC-2026-08-29-010: Pilgrim Live Wari Map & Location Intelligence

- **Status**: APPROVED
- **Date**: 2026-08-29
- **Deciders**: Platform Architecture Team, Satyajit (Pilgrim Module Lead)

## Context
The Pilgrim module requires a real-time, location-aware navigation dashboard integrating Palkhi tracking, route stages, verified Seva facilities, traffic alerts, Dindis, and Tilak AI context.

## Decision
1. **Single Source of Truth**: Consumes existing shared REST APIs (`/api/palkhi`, `/api/wari-route`, `/api/services`, `/api/traffic-alerts`, `/api/dindis`, `/api/ai/tilak/chat`) via shared `ApiClient`.
2. **Graceful Permission Handling**: `LocationService` manages GPS status. If permission is denied or unavailable, the map renders cleanly without crashing.
3. **Interactive Marker Cards**: `MapMarkerCard` provides bottom sheet actions (`Track Palkhi`, `Directions`, `Ask Tilak`, `Join Dindi`).

## Required Shared Database Fields & Contracts
- `palkhi_tracking`: `name`, `current_stage`, `next_stop`, `latitude`, `longitude`, `updated_at`
- `wari_route`: `id`, `stage_name`, `sequence_order`, `latitude`, `longitude`
- `services`: `id`, `name`, `category`, `address`, `contact_phone`, `availability_status`, `latitude`, `longitude`, `is_verified`, `is_active`
- `traffic_alerts`: `id`, `alert_code`, `title`, `description`, `type`, `severity`, `status`, `latitude`, `longitude`
- `dindis`: `id`, `dindi_number`, `name`, `leader_name`, `member_count`, `status`
