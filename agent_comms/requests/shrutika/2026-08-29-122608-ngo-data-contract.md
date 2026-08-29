# Communication Note

Request ID: COMM-2026-08-29-002
From: SHRUTIKA
To: SATYAJIT
Date: 2026-08-29 12:26:08 IST
Priority: NORMAL
Status: OPEN

## Subject
NGO service data contract available for future common/map integration

## Context & Details

1. NGO module implementation is complete and pushed on `feature/ngo`.
2. NGO services currently expose the following data fields:
   - stable unique service ID (`serviceId`)
   - NGO ID (`ngoId`)
   - service name
   - category
   - description
   - latitude
   - longitude
   - location name
   - capacity
   - operating hours
   - contact phone
   - availability (`AVAILABLE`, `LIMITED`, `UNAVAILABLE`)
   - lastUpdatedAt
   - approval status (`PENDING`, `APPROVED`, `REJECTED`)

3. This data structure is sufficient for future application features:
   - public service discovery
   - MapLibre map markers & map popups
   - service detail views
   - dynamic availability status display

4. There is currently NO shared `WariService` or `MapMarkerData` contract in `lib/common/`.

5. The NGO module will NOT create that common contract directly, as `SATYAJIT` owns `lib/common/` and cross-module architecture contracts per initial architecture decision `DEC-2026-08-29-001`.

6. When `SATYAJIT` begins shared map/service integration, the NGO module can provide the necessary data mapper / repository adapter upon request.

7. **NGO Branch**: `feature/ngo`
8. **NGO Commit Hash**: `c164abb26572383a62a0a06670f3c935e87d5a02`

## Requested Action
Informational note for SATYAJIT when defining shared map and service discovery contracts in `lib/common/models/`.

## Requested By
Shrutika / SHRUTIKA agent
