import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/citizen_service.dart';
import 'citizen_service_details_screen.dart';

/// Citizen Map Screen — shows an OSM map with service markers.
/// Owned by: Gauri — Local Citizen Module
///
/// Uses flutter_map (open source) with OpenStreetMap tiles (free).
/// Each service is shown as a coloured icon marker.
/// Tapping a marker opens the Service Details screen.
///
/// NOTE: This consumes the SHARED map architecture pattern.
/// When the Lead Agent exposes a shared MapLibre/shared map widget,
/// this screen can be updated to use it. For now, flutter_map + OSM
/// is our approved map solution.
class CitizenMapScreen extends StatefulWidget {
  const CitizenMapScreen({super.key});

  @override
  State<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends State<CitizenMapScreen> {
  final MapController _mapController = MapController();

  // Pandharpur, Maharashtra — centre of the map
  static const LatLng _pandharpurCenter = LatLng(17.6733, 75.3278);
  static const double _initialZoom = 15.0;

  // The selected service (when user taps a marker)
  CitizenService? _selectedService;

  // All services from mock data
  final List<CitizenService> _services = MockCitizenServiceData.services;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar on the map screen — map fills the full screen
      body: Stack(
        children: [
          // -- The actual OpenStreetMap map --
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _pandharpurCenter,
              initialZoom: _initialZoom,
              maxZoom: 19,
              minZoom: 10,
            ),
            children: [
              // OSM tile layer — this loads the map images
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mazapandurang.app',
                // OSM usage policy: must credit OpenStreetMap
              ),

              // Service markers layer
              MarkerLayer(
                markers: _buildMarkers(),
              ),

              // OSM attribution (required by OSM usage policy)
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // -- Top overlay: title bar --
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(240),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Color(0xFF6A1B9A), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pandharpur Services Map',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF212121),
                            ),
                          ),
                          Text(
                            'नकाशावर सेवा पहा',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Legend button
                    IconButton(
                      icon: const Icon(Icons.legend_toggle, color: Color(0xFF6A1B9A)),
                      onPressed: _showLegend,
                      tooltip: 'Map Legend',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // -- Bottom overlay: selected service info card --
          if (_selectedService != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _SelectedServiceCard(
                service: _selectedService!,
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CitizenServiceDetailsScreen(
                        service: _selectedService!,
                      ),
                    ),
                  );
                },
                onClose: () => setState(() => _selectedService = null),
              ),
            ),

          // -- Zoom controls (top right) --
          Positioned(
            right: 16,
            bottom: _selectedService != null ? 140 : 80,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.my_location,
                  onTap: () {
                    // Re-centre map on Pandharpur
                    _mapController.move(_pandharpurCenter, _initialZoom);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a list of Marker objects for each service.
  List<Marker> _buildMarkers() {
    return _services.map((service) {
      return Marker(
        point: LatLng(service.latitude, service.longitude),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedService = service;
            });
            // Move map to centre on tapped marker
            _mapController.move(
              LatLng(service.latitude, service.longitude),
              _mapController.camera.zoom,
            );
          },
          child: _ServiceMarker(service: service),
        ),
      );
    }).toList();
  }

  void _showLegend() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _MapLegendSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Map marker widget
// ---------------------------------------------------------------------------
class _ServiceMarker extends StatelessWidget {
  final CitizenService service;
  const _ServiceMarker({required this.service});

  @override
  Widget build(BuildContext context) {
    final color = _markerColor(service.category);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(120),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _markerIcon(service.category),
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Color _markerColor(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.medical:
        return const Color(0xFFC62828);
      case ServiceCategory.food:
        return const Color(0xFFE65100);
      case ServiceCategory.water:
        return const Color(0xFF0277BD);
      case ServiceCategory.toilet:
        return const Color(0xFF558B2F);
      case ServiceCategory.nightHalt:
        return const Color(0xFF4527A0);
      case ServiceCategory.parking:
        return const Color(0xFF37474F);
      case ServiceCategory.police:
        return const Color(0xFF1565C0);
      case ServiceCategory.hospital:
        return const Color(0xFFAD1457);
      case ServiceCategory.pharmacy:
        return const Color(0xFF00695C);
      case ServiceCategory.helpCentre:
        return const Color(0xFF6A1B9A);
      case ServiceCategory.other:
        return const Color(0xFF546E7A);
    }
  }

  IconData _markerIcon(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.medical:
        return Icons.medical_services;
      case ServiceCategory.food:
        return Icons.restaurant;
      case ServiceCategory.water:
        return Icons.water_drop;
      case ServiceCategory.toilet:
        return Icons.wc;
      case ServiceCategory.nightHalt:
        return Icons.hotel;
      case ServiceCategory.parking:
        return Icons.local_parking;
      case ServiceCategory.police:
        return Icons.local_police;
      case ServiceCategory.hospital:
        return Icons.local_hospital;
      case ServiceCategory.pharmacy:
        return Icons.medication;
      case ServiceCategory.helpCentre:
        return Icons.support_agent;
      case ServiceCategory.other:
        return Icons.place;
    }
  }
}

// ---------------------------------------------------------------------------
// Selected service card (shown at bottom when marker is tapped)
// ---------------------------------------------------------------------------
class _SelectedServiceCard extends StatelessWidget {
  final CitizenService service;
  final VoidCallback onViewDetails;
  final VoidCallback onClose;

  const _SelectedServiceCard({
    required this.service,
    required this.onViewDetails,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      service.distanceLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6A1B9A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.status.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onViewDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('View', style: TextStyle(fontSize: 13)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onClose,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Zoom / location map control buttons
// ---------------------------------------------------------------------------
class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF6A1B9A)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map legend bottom sheet
// ---------------------------------------------------------------------------
class _MapLegendSheet extends StatelessWidget {
  const _MapLegendSheet();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.medical_services, const Color(0xFFC62828), 'Medical'),
      (Icons.restaurant, const Color(0xFFE65100), 'Food / Annachhatra'),
      (Icons.water_drop, const Color(0xFF0277BD), 'Water'),
      (Icons.wc, const Color(0xFF558B2F), 'Toilets'),
      (Icons.hotel, const Color(0xFF4527A0), 'Night Halt'),
      (Icons.local_police, const Color(0xFF1565C0), 'Police'),
      (Icons.local_hospital, const Color(0xFFAD1457), 'Hospital'),
      (Icons.medication, const Color(0xFF00695C), 'Pharmacy'),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Map Legend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) {
              final (icon, color, label) = item;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 16),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
