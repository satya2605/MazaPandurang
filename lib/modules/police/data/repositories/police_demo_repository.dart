import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../../../core/auth/auth_service.dart';
import '../models/police_user.dart';
import '../models/emergency_request.dart';
import '../models/traffic_alert.dart';
import '../models/lost_person_case.dart';
import '../models/lost_person_sighting.dart';
import '../models/service_report.dart';
import '../models/map_poi.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PoliceDemoRepository
///
/// Single in-memory data source for the Police module demo.
/// All lists are mutable so state transitions work live during the demo.
/// Replace with ApiPoliceRepository when the backend is ready.
/// ─────────────────────────────────────────────────────────────────────────────
class PoliceDemoRepository {
  PoliceDemoRepository._();
  static final PoliceDemoRepository instance = PoliceDemoRepository._();

  // ── Demo Credentials ────────────────────────────────────────────────────────
  static const String demoPoliceId = 'POLICE001';
  static const String demoPassword = 'demo123';

  PoliceUser get currentUser {
    final profile = AuthService().currentProfile;
    if (profile != null) {
      final name = profile['display_name'] ?? profile['name'] ?? 'Police Officer';
      final role = (profile['role'] ?? 'POLICE_OFFICER').toString();
      final status = (profile['status'] ?? 'ACTIVE').toString().toUpperCase();
      final id = profile['id']?.toString() ?? 'usr-001';
      final policeId = profile['police_id']?.toString() ??
          'POL-MH-${id.substring(0, min(8, id.length)).toUpperCase()}';
      final station = profile['station_name']?.toString() ??
          profile['station']?.toString() ??
          'Pandharpur Sector Police';
      return PoliceUser(
        id: id,
        policeId: policeId,
        name: name.toString(),
        station: station,
        role: role,
        status: status,
      );
    }
    return const PoliceUser(
      id: 'usr-001',
      policeId: 'POLICE001',
      name: 'Officer Patil',
      station: 'Pune Traffic Division',
      role: 'TRAFFIC_OFFICER',
      status: 'ACTIVE',
    );
  }

  bool validateCredentials(String policeId, String password) {
    return policeId == demoPoliceId && password == demoPassword;
  }

  // ── Medical Camp Locations (used for nearest-camp calculation) ───────────────
  final List<({String id, String name, LatLng position, int capacity})>
  medicalCamps = [
    (
      id: 'camp-01',
      name: 'Wari Seva Medical Camp 01',
      position: const LatLng(18.2529, 74.1487),
      capacity: 30,
    ),
    (
      id: 'camp-02',
      name: 'Wari Seva Medical Camp 02',
      position: const LatLng(18.0996, 74.3390),
      capacity: 20,
    ),
    (
      id: 'camp-03',
      name: 'Wari Seva Medical Camp 03',
      position: const LatLng(17.9007, 74.8050),
      capacity: 25,
    ),
  ];

  /// Returns the name and distance (km) of the nearest medical camp.
  ({String id, String name, double distanceKm}) findNearestMedicalCamp(
    double lat,
    double lng,
  ) {
    const distance = Distance();
    var nearest = medicalCamps.first;
    double nearestDist = double.maxFinite;
    for (final camp in medicalCamps) {
      final d = distance.as(
        LengthUnit.Kilometer,
        LatLng(lat, lng),
        camp.position,
      );
      if (d < nearestDist) {
        nearestDist = d;
        nearest = camp;
      }
    }
    return (
      id: nearest.id,
      name: nearest.name,
      distanceKm: (nearestDist * 10).round() / 10,
    );
  }

  // ── Emergencies ─────────────────────────────────────────────────────────────
  late final List<EmergencyRequest> emergencies = [
    EmergencyRequest(
      id: 'EM-101',
      type: EmergencyType.medical,
      latitude: 18.2531,
      longitude: 74.1490,
      locationDescription: 'Near Alandi Checkpoint',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: EmergencyStatus.resolved,
      nearestMedicalCampId: 'camp-01',
      assignedUnit: 'Police Unit P-01',
      description: 'Elderly pilgrim reported collapsed at checkpoint.',
    ),
    EmergencyRequest(
      id: 'EM-102',
      type: EmergencyType.medical,
      latitude: 17.9010,
      longitude: 74.8055,
      locationDescription: 'Near Dindi 128, Jejuri Road',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 43)),
      status: EmergencyStatus.newCase,
      nearestMedicalCampId: 'camp-03',
      description: 'Person unconscious near Dindi procession.',
    ),
    EmergencyRequest(
      id: 'EM-103',
      type: EmergencyType.stampede,
      latitude: 18.0995,
      longitude: 74.3395,
      locationDescription: 'Jejuri Main Gate',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      status: EmergencyStatus.assigned,
      nearestMedicalCampId: 'camp-02',
      assignedUnit: 'Police Unit P-03',
      description: 'Crowd surge reported at main temple gate.',
    ),
  ];

  // ── Traffic Alerts ───────────────────────────────────────────────────────────
  late final List<TrafficAlert> trafficAlerts = [
    TrafficAlert(
      id: 'TA-01',
      title: 'Pune–Saswad Road',
      description: 'Full road closure due to Palkhi procession movement.',
      type: TrafficAlertType.diversion,
      latitude: 18.3519,
      longitude: 74.0399,
      severity: TrafficSeverity.high,
      status: TrafficAlertStatus.active,
      createdBy: 'POLICE001',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TrafficAlert(
      id: 'TA-02',
      title: 'Alandi Road',
      description: 'Road blocked for Dindi march.',
      type: TrafficAlertType.roadBlock,
      latitude: 18.6747,
      longitude: 73.8997,
      severity: TrafficSeverity.high,
      status: TrafficAlertStatus.active,
      createdBy: 'POLICE001',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    TrafficAlert(
      id: 'TA-03',
      title: 'Jejuri Highway',
      description: 'Heavy pilgrim foot traffic causing slow vehicle movement.',
      type: TrafficAlertType.slow,
      latitude: 18.0996,
      longitude: 74.3390,
      severity: TrafficSeverity.medium,
      status: TrafficAlertStatus.active,
      createdBy: 'POLICE002',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    TrafficAlert(
      id: 'TA-04',
      title: 'Saswad–Jejuri Link Road',
      description: 'Alternate route diverted due to VIP movement.',
      type: TrafficAlertType.diversion,
      latitude: 18.0460,
      longitude: 74.0360,
      severity: TrafficSeverity.medium,
      status: TrafficAlertStatus.active,
      createdBy: 'POLICE001',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    TrafficAlert(
      id: 'TA-05',
      title: 'Pandharpur NH65',
      description: 'Slow movement near toll plaza.',
      type: TrafficAlertType.slow,
      latitude: 17.6833,
      longitude: 75.3333,
      severity: TrafficSeverity.low,
      status: TrafficAlertStatus.active,
      createdBy: 'POLICE003',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  void addTrafficAlert(TrafficAlert alert) => trafficAlerts.insert(0, alert);

  // ── Lost Person Cases ────────────────────────────────────────────────────────
  late final List<LostPersonCase> lostPersonCases = [
    LostPersonCase(
      id: 'LP-101',
      name: 'Ramabai Shinde',
      description:
          'Female, ~60 years, wearing green saree, last seen near Alandi.',
      lastSeenLatitude: 18.6747,
      lastSeenLongitude: 73.8997,
      lastSeenDescription: 'Alandi Pilgrim Gate',
      broadcastRadiusKm: 3.0,
      status: LostPersonStatus.pendingApproval,
      adminApproval: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      sightingCount: 0,
    ),
    LostPersonCase(
      id: 'LP-102',
      name: 'Vitthal Kamble',
      description:
          'Male, ~45 years, wearing saffron dhoti, carrying a dhol.',
      lastSeenLatitude: 18.0460,
      lastSeenLongitude: 74.0360,
      lastSeenDescription: 'Saswad Bus Stand',
      broadcastRadiusKm: 2.0,
      status: LostPersonStatus.approved,
      adminApproval: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      sightingCount: 3,
    ),
  ];

  // ── Lost Person Sightings ────────────────────────────────────────────────────
  late final List<LostPersonSighting> sightings = [
    LostPersonSighting(
      id: 'SG-01',
      caseId: 'LP-102',
      latitude: 18.0461,
      longitude: 74.0362,
      locationDescription: 'Saswad Bus Stand Entrance',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
      reporterMessage: 'Person was seen near the entrance, asked for water.',
      status: SightingStatus.verified,
    ),
    LostPersonSighting(
      id: 'SG-02',
      caseId: 'LP-102',
      latitude: 18.0470,
      longitude: 74.0380,
      locationDescription: 'Near Saswad Chatrapati Chowk',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
      reporterMessage: 'Walking towards Jejuri road.',
      status: SightingStatus.reported,
    ),
    LostPersonSighting(
      id: 'SG-03',
      caseId: 'LP-102',
      latitude: 18.0510,
      longitude: 74.0410,
      locationDescription: 'Jejuri Road Km-4 Marker',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      reporterMessage: 'Seen sitting under a tree, appeared tired.',
      status: SightingStatus.reported,
    ),
  ];

  List<LostPersonSighting> sightingsForCase(String caseId) =>
      sightings.where((s) => s.caseId == caseId).toList();

  // ── Service Reports ──────────────────────────────────────────────────────────
  late final List<ServiceReport> serviceReports = [
    ServiceReport(
      id: 'SR-01',
      serviceId: 'svc-ngo-01',
      serviceName: 'Wari Seva Medical Camp 01',
      reportedBy: 'Pilgrim User',
      reason: ServiceReportReason.incorrectLocation,
      notes: 'Camp shown on map is 500m away from actual location.',
      latitude: 18.2529,
      longitude: 74.1487,
      status: ServiceReportStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ServiceReport(
      id: 'SR-02',
      serviceId: 'svc-ngo-04',
      serviceName: 'Pandharpur Annadaan Seva',
      reportedBy: 'Dindi Leader',
      reason: ServiceReportReason.closedService,
      notes: 'Camp is closed but showing as Open in app.',
      latitude: 17.6830,
      longitude: 75.3330,
      status: ServiceReportStatus.open,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ServiceReport(
      id: 'SR-03',
      serviceId: 'svc-ngo-07',
      serviceName: 'Jejuri Rest Stop Shelter',
      reportedBy: 'Pilgrim User',
      reason: ServiceReportReason.wrongAvailability,
      notes: 'Shelter capacity shown as 50 but actual capacity is much less.',
      latitude: 18.0990,
      longitude: 74.3385,
      status: ServiceReportStatus.inReview,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ServiceReport(
      id: 'SR-04',
      serviceId: 'svc-ngo-02',
      serviceName: 'Wari Medical Post — Saswad',
      reportedBy: 'Local Citizen',
      reason: ServiceReportReason.incorrectInfo,
      notes: 'Phone number listed is incorrect — no one answers.',
      latitude: 18.0460,
      longitude: 74.0360,
      status: ServiceReportStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // ── Map POIs ─────────────────────────────────────────────────────────────────
  List<MapPoi> get allMapPois => [
    // Palkhi
    const MapPoi(
      id: 'palkhi-main',
      label: 'Sant Dnyaneshwar Palkhi',
      type: MapPoiType.palkhi,
      position: LatLng(18.0996, 74.3390),
      detail: 'Main Palkhi procession',
      status: 'ON ROUTE',
    ),
    // Dindis
    const MapPoi(
      id: 'dindi-101',
      label: 'Dindi 101',
      type: MapPoiType.dindi,
      position: LatLng(18.2531, 74.1490),
      detail: '~120 members',
      status: 'MARCHING',
    ),
    const MapPoi(
      id: 'dindi-124',
      label: 'Dindi 124',
      type: MapPoiType.dindi,
      position: LatLng(18.0470, 74.0380),
      detail: '~85 members',
      status: 'RESTING',
    ),
    const MapPoi(
      id: 'dindi-128',
      label: 'Dindi 128',
      type: MapPoiType.dindi,
      position: LatLng(17.9010, 74.8055),
      detail: '~200 members',
      status: 'MARCHING',
    ),
    // Medical Camps
    const MapPoi(
      id: 'camp-01',
      label: 'Medical Camp 01',
      type: MapPoiType.medical,
      position: LatLng(18.2529, 74.1487),
      detail: 'Wari Seva Medical Camp 01 · Capacity: 30',
      status: 'OPEN',
    ),
    const MapPoi(
      id: 'camp-02',
      label: 'Medical Camp 02',
      type: MapPoiType.medical,
      position: LatLng(18.0996, 74.3390),
      detail: 'Wari Seva Medical Camp 02 · Capacity: 20',
      status: 'OPEN',
    ),
    const MapPoi(
      id: 'camp-03',
      label: 'Medical Camp 03',
      type: MapPoiType.medical,
      position: LatLng(17.9007, 74.8050),
      detail: 'Wari Seva Medical Camp 03 · Capacity: 25',
      status: 'OPEN',
    ),
    // Police Posts
    const MapPoi(
      id: 'police-01',
      label: 'Police Post — Alandi',
      type: MapPoiType.police,
      position: LatLng(18.6747, 73.8997),
      detail: 'Traffic control & crowd monitoring',
      status: 'ACTIVE',
    ),
    const MapPoi(
      id: 'police-02',
      label: 'Police Post — Saswad',
      type: MapPoiType.police,
      position: LatLng(18.0460, 74.0360),
      detail: 'Highway diversion management',
      status: 'ACTIVE',
    ),
    // Traffic Blocks
    const MapPoi(
      id: 'traffic-ta01',
      label: 'DIVERSION: Pune–Saswad Road',
      type: MapPoiType.traffic,
      position: LatLng(18.3519, 74.0399),
      detail: 'Palkhi movement — full closure',
      status: 'DIVERSION',
    ),
    const MapPoi(
      id: 'traffic-ta02',
      label: 'BLOCKED: Alandi Road',
      type: MapPoiType.traffic,
      position: LatLng(18.6747, 73.8997),
      detail: 'Dindi march',
      status: 'BLOCKED',
    ),
    // Emergency
    const MapPoi(
      id: 'em-102',
      label: 'EMERGENCY: EM-102',
      type: MapPoiType.emergency,
      position: LatLng(17.9010, 74.8055),
      detail: 'Medical Emergency — NEW',
      status: 'NEW',
    ),
  ];

  // ── Dashboard Counts ─────────────────────────────────────────────────────────
  int get activeEmergencyCount =>
      emergencies
          .where(
            (e) =>
                e.status != EmergencyStatus.resolved,
          )
          .length;

  int get openIncidentCount =>
      emergencies.where((e) => e.status == EmergencyStatus.newCase).length +
      trafficAlerts
          .where((t) => t.status == TrafficAlertStatus.active)
          .length;

  int get activeTrafficAlertCount =>
      trafficAlerts.where((t) => t.status == TrafficAlertStatus.active).length;

  int get activeLostPersonCount =>
      lostPersonCases
          .where((l) => l.status != LostPersonStatus.resolved)
          .length;

  String get nextTrafficAlertId {
    final rand = Random();
    return 'TA-${(trafficAlerts.length + rand.nextInt(90) + 10)}';
  }
}
