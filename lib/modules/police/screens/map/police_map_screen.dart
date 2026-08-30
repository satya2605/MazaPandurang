import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../pilgrim/models/pilgrim_models.dart'
    hide EmergencyRequest, TrafficAlert, LostPersonSighting;
import '../../../pilgrim/repositories/api_pilgrim_repository.dart';
import '../../../pilgrim/services/map_config.dart';
import '../../data/models/emergency_request.dart' as police_em;
import '../../data/models/lost_person_case.dart';
import '../../data/models/lost_person_sighting.dart';
import '../../data/models/traffic_alert.dart' as police_tr;
import '../../data/repositories/police_demo_repository.dart';

enum PoliceMapFilter {
  all,
  palkhi,
  dindi,
  services,
  police,
  emergency,
  traffic,
  lostPerson,
}

/// Police Live Operations Map
/// Uses MapTiler provider as base map (same as Pilgrim module) and integrates
/// all operational layers: Palkhi route & position, live Dindis, Wari services,
/// police checkposts, active SOS emergencies, traffic alerts, and lost person sightings.
class PoliceMapScreen extends StatefulWidget {
  const PoliceMapScreen({super.key});

  @override
  State<PoliceMapScreen> createState() => _PoliceMapScreenState();
}

class _PoliceMapScreenState extends State<PoliceMapScreen> {
  final MapController _mapController = MapController();
  final ApiPilgrimRepository _pilgrimRepo = ApiPilgrimRepository();
  final PoliceDemoRepository _policeRepo = PoliceDemoRepository.instance;

  PoliceMapFilter _activeFilter = PoliceMapFilter.all;
  bool _isLoading = true;

  static const _policeNavy = Color(0xFF1565C0);
  static const _palkhiOrange = Color(0xFFE65100);

  // Pune–Pandharpur Wari Corridor Center
  static const _initialCenter = LatLng(18.0996, 74.3390);
  static const _initialZoom = 9.5;

  PalkhiInfo? _palkhi;
  List<DindiMarkerInfo> _dindis = [];
  List<WariService> _services = [];
  List<WariRouteStage> _routeStages = [];
  List<police_em.EmergencyRequest> _emergencies = [];
  List<police_tr.TrafficAlert> _trafficAlerts = [];
  List<LostPersonCase> _lostPersons = [];
  List<LostPersonSighting> _sightings = [];

  // Static Police Security Checkposts along the Wari corridor
  static const List<({String name, LatLng position, String type, String phone})>
      _policeUnits = [
    (
      name: 'Pandharpur Sector Head Police Post',
      position: LatLng(17.6775, 75.3278),
      type: 'Sector HQ',
      phone: '+91 2186 223333',
    ),
    (
      name: 'Saswad Central Police Checkpost',
      position: LatLng(18.3411, 74.0305),
      type: 'Control Room',
      phone: '+91 2115 222100',
    ),
    (
      name: 'Pune Rural Traffic Patrol Unit',
      position: LatLng(18.5204, 73.8567),
      type: 'Traffic Mobile',
      phone: '+91 20 25657878',
    ),
    (
      name: 'Jejuri Route Security Post',
      position: LatLng(18.2750, 74.1600),
      type: 'Checkpost',
      phone: '+91 2115 253200',
    ),
    (
      name: 'Lonand Junction Police Outpost',
      position: LatLng(18.0400, 74.1900),
      type: 'Outpost',
      phone: '+91 2169 225100',
    ),
    (
      name: 'Phaltan Command Division',
      position: LatLng(17.9800, 74.4300),
      type: 'Sector HQ',
      phone: '+91 2166 222033',
    ),
    (
      name: 'Malshiras Sector Police Tent',
      position: LatLng(17.8200, 74.9500),
      type: 'Patrol Post',
      phone: '+91 2185 235100',
    ),
    (
      name: 'Wakhari Final Halt Police Unit',
      position: LatLng(17.7000, 75.2800),
      type: 'Crowd Control',
      phone: '+91 2186 228900',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllMapData();
  }

  Future<void> _loadAllMapData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _pilgrimRepo.getPalkhiInfo(),
        _pilgrimRepo.getNearbyDindis(),
        _pilgrimRepo.getServices(),
        _pilgrimRepo.getWariRoute(),
      ]);

      if (mounted) {
        setState(() {
          _palkhi = results[0] as PalkhiInfo?;
          _dindis = results[1] as List<DindiMarkerInfo>;
          _services = results[2] as List<WariService>;
          _routeStages = results[3] as List<WariRouteStage>;
          _emergencies = _policeRepo.emergencies;
          _trafficAlerts = _policeRepo.trafficAlerts;
          _lostPersons = _policeRepo.lostPersonCases;
          _sightings = _policeRepo.sightings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<LatLng> get _routePolylineCoords {
    if (_routeStages.isNotEmpty) {
      return _routeStages
          .map((st) => LatLng(st.position.latitude, st.position.longitude))
          .toList();
    }
    if (_palkhi != null && _palkhi!.routePoints.isNotEmpty) {
      return _palkhi!.routePoints
          .map((pt) => LatLng(pt.latitude, pt.longitude))
          .toList();
    }
    // Standard Canonical Pune–Pandharpur Route Coordinates
    return const [
      LatLng(18.5204, 73.8567), // Pune
      LatLng(18.3411, 74.0305), // Saswad
      LatLng(18.2750, 74.1600), // Jejuri
      LatLng(18.0400, 74.1900), // Lonand
      LatLng(17.9800, 74.4300), // Phaltan
      LatLng(17.8200, 74.9500), // Malshiras
      LatLng(17.7500, 75.1000), // Velapur
      LatLng(17.7000, 75.2800), // Wakhari
      LatLng(17.6775, 75.3278), // Pandharpur
    ];
  }

  void _showDetailSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? status,
    Map<String, String>? details,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withAlpha(80)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (details != null && details.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              ...details.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF222222),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening live route navigation...')),
                      );
                    },
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Navigate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                    ),
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (onAction != null) onAction();
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(actionLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const apiKey = MapConfig.mapTilerApiKey;
    final hasMapTiler = MapConfig.hasMapTilerApiKey;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _policeNavy,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Police Operations Map',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'MapTiler Live Wari Grid & Real-time Tracking',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Map Data',
            onPressed: _loadAllMapData,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Center on Corridor',
            onPressed: () {
              _mapController.move(_initialCenter, _initialZoom);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map Canvas ───────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              minZoom: 6,
              maxZoom: 18,
            ),
            children: [
              // 1. MapTiler Vector/Raster Base Map
              TileLayer(
                urlTemplate: hasMapTiler
                    ? 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}@2x.png?key=$apiKey'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mazapandurang.app',
                maxZoom: 19,
                retinaMode: hasMapTiler,
              ),

              // 2. Official Wari Route Polyline Layer
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePolylineCoords,
                    color: _palkhiOrange.withAlpha(220),
                    strokeWidth: 4.5,
                  ),
                ],
              ),

              // 3. Markers Layer
              MarkerLayer(
                markers: _buildMapMarkers(),
              ),
            ],
          ),

          // ── Top Filter Bar ──────────────────────────────────────────
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All Layers', PoliceMapFilter.all, Icons.layers),
                  _filterChip('Palkhi', PoliceMapFilter.palkhi, Icons.temple_hindu),
                  _filterChip('Dindis (${_dindis.length})', PoliceMapFilter.dindi, Icons.groups),
                  _filterChip('Services (${_services.length})', PoliceMapFilter.services, Icons.medical_services),
                  _filterChip('Police Units (${_policeUnits.length})', PoliceMapFilter.police, Icons.local_police),
                  _filterChip('Emergencies (${_emergencies.length})', PoliceMapFilter.emergency, Icons.emergency),
                  _filterChip('Traffic (${_trafficAlerts.length})', PoliceMapFilter.traffic, Icons.traffic),
                  _filterChip('Lost Persons (${_lostPersons.length})', PoliceMapFilter.lostPerson, Icons.person_search),
                ],
              ),
            ),
          ),

          // ── Loading Indicator ───────────────────────────────────────
          if (_isLoading)
            const Positioned(
              top: 70,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Syncing live data...', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

          // ── MapTiler Engine Indicator ───────────────────────────────
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasMapTiler ? Icons.verified : Icons.info_outline,
                    color: hasMapTiler ? Colors.lightGreenAccent : Colors.amberAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasMapTiler ? 'MapTiler Engine Active' : 'OSM Base (Add MapTiler Key)',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, PoliceMapFilter filter, IconData icon) {
    final isSelected = _activeFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : _policeNavy),
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() => _activeFilter = val ? filter : PoliceMapFilter.all);
        },
        selectedColor: _policeNavy,
        backgroundColor: Colors.white,
        elevation: 2,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  List<Marker> _buildMapMarkers() {
    final List<Marker> markers = [];

    // ── 1. PALKHI LIVE LOCATION ───────────────────────────────────────
    if (_activeFilter == PoliceMapFilter.all || _activeFilter == PoliceMapFilter.palkhi) {
      if (_palkhi != null) {
        final pos = LatLng(_palkhi!.currentPosition.latitude, _palkhi!.currentPosition.longitude);
        markers.add(
          Marker(
            point: pos,
            width: 52,
            height: 52,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: _palkhi!.name,
                subtitle: 'Current Stage: ${_palkhi!.currentStage}',
                status: 'LIVE ON ROUTE',
                icon: Icons.temple_hindu,
                color: _palkhiOrange,
                details: {
                  'Stage': _palkhi!.currentStage,
                  'Next Halt': _palkhi!.nextStop,
                  'Location': '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                  'Last Updated': _palkhi!.lastUpdated.toLocal().toString().substring(11, 16),
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _palkhiOrange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: _palkhiOrange.withAlpha(160), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.temple_hindu, color: Colors.white, size: 28),
              ),
            ),
          ),
        );
      }
    }

    // ── 2. LIVE DINDIS ────────────────────────────────────────────────
    if (_activeFilter == PoliceMapFilter.all || _activeFilter == PoliceMapFilter.dindi) {
      for (final dindi in _dindis) {
        final pos = LatLng(dindi.position.latitude, dindi.position.longitude);
        markers.add(
          Marker(
            point: pos,
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: dindi.name,
                subtitle: 'Dindi Leader: ${dindi.leaderName}',
                status: dindi.currentStatus.toUpperCase(),
                icon: Icons.groups,
                color: const Color(0xFFD84315),
                details: {
                  'Leader': dindi.leaderName,
                  'Members': '${dindi.memberCount} Varkaris',
                  'Status': dindi.currentStatus,
                  'Coordinates': '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD84315),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: const Icon(Icons.groups, color: Colors.white, size: 20),
              ),
            ),
          ),
        );
      }
    }

    // ── 3. WARI SERVICES & MEDICAL CAMPS ──────────────────────────────
    if (_activeFilter == PoliceMapFilter.all || _activeFilter == PoliceMapFilter.services) {
      for (final s in _services) {
        final pos = LatLng(s.position.latitude, s.position.longitude);
        final color = s.category == ServiceCategory.medical
            ? const Color(0xFFD32F2F)
            : s.category == ServiceCategory.water
                ? const Color(0xFF0288D1)
                : const Color(0xFF388E3C);
        final icon = s.category == ServiceCategory.medical
            ? Icons.local_hospital
            : s.category == ServiceCategory.water
                ? Icons.water_drop
                : Icons.restaurant;

        markers.add(
          Marker(
            point: pos,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: s.name,
                subtitle: s.description,
                status: s.availabilityStatus.toUpperCase(),
                icon: icon,
                color: color,
                details: {
                  'Category': s.category.name.toUpperCase(),
                  'Address': s.address,
                  'Contact Phone': s.contactPhone,
                  'Status': s.availabilityStatus,
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ),
          ),
        );
      }
    }

    // ── 4. POLICE CHECKPOSTS & SECTOR UNITS ────────────────────────────
    if (_activeFilter == PoliceMapFilter.all || _activeFilter == PoliceMapFilter.police) {
      for (final p in _policeUnits) {
        markers.add(
          Marker(
            point: p.position,
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: p.name,
                subtitle: 'Police Command Unit',
                status: p.type.toUpperCase(),
                icon: Icons.local_police,
                color: _policeNavy,
                details: {
                  'Unit Type': p.type,
                  'Emergency Phone': p.phone,
                  'Coordinates': '${p.position.latitude.toStringAsFixed(4)}, ${p.position.longitude.toStringAsFixed(4)}',
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _policeNavy,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: _policeNavy.withAlpha(140), blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.local_police, color: Colors.white, size: 22),
              ),
            ),
          ),
        );
      }
    }

    // ── 5. ACTIVE SOS EMERGENCIES ─────────────────────────────────────
    if (_activeFilter == PoliceMapFilter.all || _activeFilter == PoliceMapFilter.emergency) {
      for (final em in _emergencies) {
        final pos = LatLng(em.latitude, em.longitude);
        markers.add(
          Marker(
            point: pos,
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: em.typeLabel,
                subtitle: em.description,
                status: em.statusLabel,
                icon: Icons.emergency,
                color: const Color(0xFFC62828),
                actionLabel: 'Dispatch Unit',
                onAction: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Patrol unit dispatched to ${em.locationDescription}')),
                  );
                },
                details: {
                  'Type': em.typeLabel,
                  'Location': em.locationDescription,
                  'Assigned Unit': em.assignedUnit ?? 'None (Unassigned)',
                  'Reported': em.reportedAt.toLocal().toString().substring(11, 16),
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withAlpha(160), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.emergency, color: Colors.white, size: 24),
              ),
            ),
          ),
        );
      }
    }

    // ── 6. TRAFFIC ALERTS ─────────────────────────────────────────────
    if (_activeFilter == PoliceMapFilter.all || _activeFilter == PoliceMapFilter.traffic) {
      for (final tr in _trafficAlerts) {
        final pos = LatLng(tr.latitude, tr.longitude);
        markers.add(
          Marker(
            point: pos,
            width: 42,
            height: 42,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: tr.title,
                subtitle: tr.description,
                status: '${tr.typeLabel} • ${tr.severityLabel}',
                icon: Icons.traffic,
                color: const Color(0xFFF57F17),
                details: {
                  'Status Type': tr.typeLabel,
                  'Severity': tr.severityLabel,
                  'Created By': tr.createdBy,
                  'Active Since': tr.createdAt.toLocal().toString().substring(11, 16),
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF57F17),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: const Icon(Icons.traffic, color: Colors.white, size: 20),
              ),
            ),
          ),
        );
      }
    }

    // ── 7. LOST PERSON SIGHTINGS & CASES ──────────────────────────────
    if (_activeFilter == PoliceMapFilter.all || _activeFilter == PoliceMapFilter.lostPerson) {
      for (final lp in _lostPersons) {
        final pos = LatLng(lp.lastSeenLatitude, lp.lastSeenLongitude);
        markers.add(
          Marker(
            point: pos,
            width: 42,
            height: 42,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: 'Missing: ${lp.name}',
                subtitle: lp.description,
                status: lp.statusLabel,
                icon: Icons.person_search,
                color: const Color(0xFF6A1B9A),
                details: {
                  'Last Seen Location': lp.lastSeenDescription,
                  'Broadcast Radius': '${lp.broadcastRadiusKm} km',
                  'Sightings Count': '${lp.sightingCount} reports',
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: const Icon(Icons.person_search, color: Colors.white, size: 20),
              ),
            ),
          ),
        );
      }

      for (final sg in _sightings) {
        final pos = LatLng(sg.latitude, sg.longitude);
        markers.add(
          Marker(
            point: pos,
            width: 38,
            height: 38,
            child: GestureDetector(
              onTap: () => _showDetailSheet(
                title: 'Sighting: Case #${sg.caseId}',
                subtitle: sg.locationDescription,
                status: sg.statusLabel,
                icon: Icons.visibility,
                color: const Color(0xFF8E24AA),
                details: {
                  'Message': sg.reporterMessage ?? 'No details available',
                  'Location': sg.locationDescription,
                  'Reported At': sg.reportedAt.toLocal().toString().substring(11, 16),
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8E24AA),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Icon(Icons.visibility, color: Colors.white, size: 18),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }
}
