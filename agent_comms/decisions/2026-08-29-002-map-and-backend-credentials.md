# Architectural Decision — 2026-08-29-002

- **Decision ID**: DEC-2026-08-29-002
- **Date**: 2026-08-29 12:27:00 IST
- **Decision Title**: Locked Tech Stack, MapLibre/MapTiler Integration & Backend Credential Partitioning
- **Decision Owner**: SATYAJIT (Lead Agent)
- **Affected Modules**: All Developer Modules (Pilgrim, Dindi, Police, NGO, Citizen, Backend)

---

## Context
Standardizing the tech stack and credential security boundaries across all 5 developer modules.

---

## Locked Technology Decisions
- **Mobile/Web UI**: Flutter + Dart (Material 3)
- **Primary Map Stack**: MapLibre Flutter + MapTiler + OpenStreetMap (OSM)
- **Backend**: Node.js + TypeScript REST API (`backend/`)
- **Database / Auth / Realtime**: Supabase PostgreSQL + Supabase Auth + Supabase Realtime + Storage
- **AI Router**: Node.js AI Provider Router abstraction (dynamic provider & model switching)
- **Media**: Streaming / YouTube embeds (no downloading)

---

## Credential & Security Architecture

| Credential Class | Storage Location | Access Scope | Security Measure |
| :--- | :--- | :--- | :--- |
| `MAPTILER_API_KEY` | Flutter (`--dart-define`) | Public Client (MapLibre rendering) | MapTiler Dashboard HTTP Origin / Domain restriction |
| `SUPABASE_ANON_KEY` | Flutter (`--dart-define`) | Public Client | Row Level Security (RLS) policies in PostgreSQL |
| `SUPABASE_SERVICE_ROLE_KEY` | Node.js (`backend/.env`) | Private Server Only | NEVER exposed to Flutter |
| `AI_PROVIDER_KEYS` | Node.js (`backend/.env`) | Private Server Only | Node.js AI Router proxies prompts |
| `MAPTILER_SERVICE_TOKEN` | Node.js (`backend/.env`) | Private Server Only | Server-side map/geocoding operations |

---

## Mandatory Integration Rule for All Agents
1. **No direct secret storage in Flutter**: Never store private API keys or service role tokens in Flutter Dart files.
2. **Backend API Proxy**: All privileged actions (AI orchestration, emergency workflows, report moderation) MUST be routed through the Node.js TypeScript API (`backend/`).
3. **MapLibre Basemap**: Use `MapConfig.mapTilerStyleUrl` for client-side MapLibre map rendering.
