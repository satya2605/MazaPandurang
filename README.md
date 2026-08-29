# Maza Pandurang (माझा पांडुरंग) 🚩

A unified Wari Pilgrimage Assistance and Management Platform built with Flutter.

## 🚩 Overview

**Maza Pandurang** provides real-time service discovery, route guidance, emergency coordination, and role-based operational dashboards for pilgrims (Warkaris), Dindi leaders, NGOs, local authorities (Police), and local citizens during the annual Wari pilgrimage to Pandharpur.

---

## 👥 Team Developer Ownership

| Developer | Role | Module Path | Feature Branch |
| :--- | :--- | :--- | :--- |
| **Satyajit** | Pilgrim (वारकरी) | `lib/modules/pilgrim/` | `feature/pilgrim` |
| **Sanket** | Dindi Leader (दिंडी प्रमुख) | `lib/modules/dindi/` | `feature/dindi` |
| **Yogeshwari** | Police / Authority (पोलीस) | `lib/modules/police/` | `feature/police` |
| **Shrutika** | NGO Volunteer (सेवाभावी) | `lib/modules/ngo/` | `feature/ngo` |
| **Gauri** | Local Citizen (स्थानिक नागरिक) | `lib/modules/citizen/` | `feature/citizen` |

---

## 🛠 Project Architecture

- **Shared App Core**: `lib/app/` (Role selector, dev module selector)
- **Shared Common Code**: `lib/common/` (Theme, navigation, constants, utilities)
- **Independent Modules**: `lib/modules/{pilgrim, dindi, police, ngo, citizen}`
- **Backend Boundary**: `backend/` (Node.js REST / Realtime API boundary)

---

## 🚀 Quick Start

1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Run static code analysis:
   ```bash
   flutter analyze
   ```
3. Run test suite:
   ```bash
   flutter test
   ```
4. Launch the application:
   ```bash
   flutter run
   ```

For detailed team development guidelines, refer to [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).