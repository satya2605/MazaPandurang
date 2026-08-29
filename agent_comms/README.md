# Maza Pandurang — Multi-Agent Communication Protocol

This directory defines the durable, asynchronous communication framework for the 5 AI agents paired with the development team.

---

## 🤖 Agent Identities & Team Structure

| Agent ID | Human Developer | Assigned Module | Authority & Role |
| :--- | :--- | :--- | :--- |
| **`SATYAJIT`** | Satyajit | Pilgrim (`lib/modules/pilgrim/`) | **Lead Agent** (Cross-module decision authority) |
| **`SANKET`** | Sanket | Dindi Leader (`lib/modules/dindi/`) | Module Owner |
| **`YOGESHWARI`** | Yogeshwari | Police / Authority (`lib/modules/police/`) | Module Owner |
| **`SHRUTIKA`** | Shrutika | NGO Volunteer (`lib/modules/ngo/`) | Module Owner |
| **`GAURI`** | Gauri | Local Citizen (`lib/modules/citizen/`) | Module Owner |

---

## 👑 Lead Agent Authority

`SATYAJIT` is designated as the **Lead Agent** with final decision authority over:
- Cross-module architecture & shared data contracts (`lib/common/models/`)
- Modifications to the shared `lib/common/` folder
- Multi-module navigation contracts & app route definitions
- API contracts affecting multiple developer modules
- Authentication & security architecture affecting multiple modules
- Major technology decisions and conflicting module requirements

*Note: Module owners retain complete autonomy over internal implementation details inside their assigned module directories when those changes do not impact other modules.*

---

## 📁 Directory Structure

```text
agent_comms/
├── README.md                  # This protocol specification
├── requests/                  # Cross-module communication requests
│   ├── satyajit/
│   ├── sanket/
│   ├── yogeshwari/
│   ├── shrutika/
│   └── gauri/
├── responses/                 # Lead agent responses & decision approvals
│   └── satyajit/
├── decisions/                 # Immutable architectural decisions
│   └── 2026-08-29-001-initial-architecture.md
└── status/                    # Module development status files
    ├── satyajit.md
    ├── sanket.md
    ├── yogeshwari.md
    ├── shrutika.md
    └── gauri.md
```

---

## 📢 When Communication is Required

An agent **MUST** initiate a communication request if:
1. It requires another module to expose data or functionality.
2. It proposes adding or modifying code in `lib/common/`.
3. Its implementation alters a shared API contract or model.
4. Its implementation affects navigation owned by another module.
5. It discovers conflicting architectural or security requirements.
6. It proposes a major technology or dependency decision.

An agent **DOES NOT** need communication for ordinary implementation inside its own module.

---

## 🔄 Human-Mediated Communication Workflow

Agents communicate asynchronously through Git-versioned files using human developer mediation:

1. **Request Creation**: Agent writes a request file in `agent_comms/requests/<agent_id>/YYYY-MM-DD-HHmmss-<short-topic>.md`.
2. **Human Notification**: Agent notifies its human developer: *"Agent communication required with SATYAJIT."*
3. **Team Handshake**: Human developer notifies the team / project manager.
4. **Lead Agent Review**: Lead agent (`SATYAJIT`) reads the request from `agent_comms/requests/` and writes a response in `agent_comms/responses/satyajit/`.
5. **Decision Record**: If cross-module impact is high, the lead agent records an immutable decision in `agent_comms/decisions/`.
6. **Execution**: Requesting agent reads the response/decision and proceeds with implementation.

---

## 📝 Request File Format

Save to `agent_comms/requests/<agent_id>/YYYY-MM-DD-HHmmss-<topic>.md`:

```markdown
# Communication Request

Request ID: COMM-2026-08-29-001
From: SANKET
To: SATYAJIT
Date: 2026-08-29 14:35:22 IST
Priority: HIGH
Status: OPEN

## Subject
Dindi location data contract

## Context
The Dindi module needs to expose current Dindi GPS coordinates to the Pilgrim module map.

## Question
Should Dindi expose `latitude`, `longitude`, `timestamp`, `accuracy`, and `status` via a shared contract?

## Proposed Solution
Create a shared `DindiLocation` model inside `lib/common/models/dindi_location.dart`.

## Impact
- Dindi module
- Pilgrim map
- Common models

## Requested Decision
Approve or reject the proposed shared model contract.

## Requested By
Sanket / SANKET agent
```

---

## 📨 Response File Format

Save to `agent_comms/responses/satyajit/YYYY-MM-DD-HHmmss-<topic>.md`:

```markdown
# Communication Response

Request ID: COMM-2026-08-29-001
From: SATYAJIT
To: SANKET
Date: 2026-08-29 14:42:10 IST
Status: RESOLVED

## Decision
APPROVED

## Reason
Pilgrim map requires real-time Dindi coordinates for pilgrim tracking.

## Approved Contract / Implementation
Create `DindiLocation` in `lib/common/models/dindi_location.dart` with fields `dindiId`, `latitude`, `longitude`, `timestamp`, `accuracy`, `status`.

## Integration Instructions
Do not expose internal Dindi services or widgets directly to Pilgrim.

## Authority
SATYAJIT / LEAD AGENT
```

---

## 📜 Immutable Decision Files

Major architectural decisions are stored as individual immutable files in `agent_comms/decisions/YYYY-MM-DD-NNN-<topic>.md`.

- **Rule**: Never edit an existing decision file.
- **Revision Rule**: To change a decision, create a new decision file referencing `Supersedes: YYYY-MM-DD-NNN-<topic>.md`.

---

## 🚦 Communication Priority Levels

- `LOW`: Informational status update. No response required.
- `MEDIUM`: Integration issue requiring coordination before merging.
- `HIGH`: Architecture, shared contract, or blocking dependency issue.
- `CRITICAL`: Security flaw, credential exposure, or major application demo blocker. Notify human developer immediately.
