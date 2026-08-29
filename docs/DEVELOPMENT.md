# Maza Pandurang — Development & Team Ownership Guide

This document establishes the architecture rules, Git workflow, module ownership boundaries, and testing protocols for the five-person team developing the **Maza Pandurang** application.

---

## 1. Team Module Ownership

Each developer owns a single module folder inside `lib/modules/`. Developers must normally modify **only** their assigned module directory:

- **Satyajit** → `lib/modules/pilgrim/` (`feature/pilgrim`)
- **Sanket** → `lib/modules/dindi/` (`feature/dindi`)
- **Yogeshwari** → `lib/modules/police/` (`feature/police`)
- **Shrutika** → `lib/modules/ngo/` (`feature/ngo`)
- **Gauri** → `lib/modules/citizen/` (`feature/citizen`)

---

## 2. Common Code & Shared Core Rules

- **Common Directory**: `lib/common/` (Theme, shared constants, routes, navigation, shared models).
- **App Directory**: `lib/app/` (Root widget, main navigation, role selector, dev module selector).

### Coordination Rule
`lib/common/` and `lib/app/` are shared by all 5 developers.
- Do **not** place module-specific business logic in `lib/common/`.
- Any changes to `lib/common/` or `lib/app/` require team coordination to avoid merge conflicts.

---

## 3. Module Integration Contract Rule

> **CRITICAL RULE**: Modules must communicate through approved contracts/interfaces and shared models in `lib/common/` where appropriate. Developers must **not** depend directly on another module's internal widgets, services, or implementation details.

### Example:
- **Pilgrim** needs Dindi information.
- **DO NOT**: Directly import `package:maza_pandurang/modules/dindi/...` internal files into Pilgrim code.
- **DO**: Define a shared contract/interface in `lib/common/models/` or `lib/common/services/` after discussing with the Dindi owner (Sanket) and Project Manager.

---

## 4. Git Branching & Synchronization

### Branches
- `main` — Production/stable branch. **Never commit or push directly to `main`**.
- `feature/pilgrim`
- `feature/dindi`
- `feature/police`
- `feature/ngo`
- `feature/citizen`

### Git Rules
1. **Never use force push** (`git push --force`).
2. **Never rewrite shared history**.
3. Sync feature branches with `main` before starting tasks:
   ```bash
   git status
   git fetch origin
   git checkout main
   git pull --ff-only
   git checkout <your-feature-branch>
   ```
4. Push only your assigned feature branch.
5. Merge into `main` requires team review and approval.

---

## 5. Development Workflow (10 Steps)

1. **INSPECT**: Inspect project status, git branch, and relevant files before starting.
2. **SYNC**: Safely fetch and sync with remote `main`.
3. **PLAN**: Create an implementation plan and get Project Manager approval before writing feature code.
4. **IMPLEMENT**: Build the approved scope without scope bloat or cross-module editing.
5. **TEST**: Run formatting, static analysis, and test suites.
6. **FIX**: Fix all compiler errors and analyzer warnings before committing.
7. **REVIEW**: Check `git diff` for accidental files, secrets, or debug prints.
8. **COMMIT**: Create focused, descriptive commit messages (e.g., `feat(pilgrim): add service discovery screen`).
9. **PUSH**: Push your feature branch to remote.
10. **MERGE**: Submit branch for team integration.

---

## 6. Testing & Quality Gate

Every task must pass the following checks before committing:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Do not push code with analyzer errors or failing unit/widget tests.
