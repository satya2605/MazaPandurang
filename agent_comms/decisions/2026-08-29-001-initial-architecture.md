# Architectural Decision — 2026-08-29-001

- **Decision ID**: DEC-2026-08-29-001
- **Date**: 2026-08-29 10:54:00 IST
- **Decision Title**: Project Architecture, Module Ownership & Multi-Agent Protocol
- **Decision Owner**: SATYAJIT (Lead Agent)
- **Affected Modules**: Pilgrim, Dindi, Police, NGO, Citizen, Common, App

---

## Context
Initial 1-day hackathon setup requiring 5 developers working in parallel with minimal merge conflicts.

---

## Decision Summary
1. **Module Separation**: Each of the 5 developers owns an exclusive folder under `lib/modules/`. Cross-module file edits are strictly prohibited.
2. **Shared Code Boundary**: `lib/common/` holds shared theme, constants, and data contracts. Any change to `lib/common/` requires cross-module communication approval.
3. **Communication Protocol**: Multi-agent communication occurs asynchronously via timestamped files in `agent_comms/`.
4. **Lead Agent Authority**: SATYAJIT holds final approval over shared data contracts and cross-module decisions.

---

## Implementation Requirements
- All feature branch developments must comply with `docs/DEVELOPMENT.md` and `agent_comms/README.md`.
- No developer or agent may modify another developer's branch or module files directly.
