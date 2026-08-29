import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/citizen_service.dart';
import '../models/citizen_map_data.dart';
import 'citizen_service_details_screen.dart';

enum CitizenMapFilter { all, traffic, donations, lostPersons }

/// Citizen Map Screen — shows an OSM map with service markers, traffic zones,
/// and citizen-specific layers.
/// Owned by: Gauri — Local Citizen Module
class CitizenMapScreen extends StatefulWidget {
  const CitizenMapScreen({super.key});

  @override
  State<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends State<CitizenMapScreen> {
  final MapController _mapController = MapController();
  CitizenMapFilter _currentFilter = CitizenMapFilter.all;

  static const LatLng _pandharpurCenter = LatLng(17.6733, 75.3278);
  static const double _initialZoom = 15.0;

  CitizenService? _selectedService;
  MapLostPerson? _selectedLostPerson;
  TrafficZone? _selectedTrafficZone;

  final List<CitizenService> _services = MockCitizenServiceData.services;
  final List<CitizenService> _donations = MockCitizenMapData.donationPoints;
  final List<TrafficZone> _trafficZones = MockCitizenMapData.trafficZones;
  final List<MapLostPerson> _lostPersons = MockCitizenMapData.lostPersons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // -- Map --
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _pandharpurCenter,
              initialZoom: _initialZoom,
              maxZoom: 19,
              minZoom: 10,
            ),
            children: [
              TileLayer(
                // Use a slightly desaturated cartodb style or standard OSM
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mazapandurang.app',
              ),

              // Traffic Layer (Polygons)
              if (_currentFilter == CitizenMapFilter.all || _currentFilter == CitizenMapFilter.traffic)
                PolygonLayer(
                  polygons: _trafficZones.map((tz) {
                    return Polygon(
                      points: tz.polygonPoints,
                      color: tz.isClosed ? Colors.red.withAlpha(80) : Colors.orange.withAlpha(80),
                      borderStrokeWidth: 2,
                      borderColor: tz.isClosed ? Colors.red : Colors.orange,
                    );
                  }).toList(),
                ),

              // Markers Layer
              MarkerLayer(
                markers: _buildMarkers(),
              ),

              const RichAttributionWidget(
                attributions: [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),

          // -- Top overlay: Title & Filter Bar --
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  _buildTitleBar(),
                  const SizedBox(height: 8),
                  _buildFilterBar(),
                ],
              ),
            ),
          ),

          // -- Bottom overlay: Info Cards --
          if (_selectedService != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _SelectedServiceCard(
                service: _selectedService!,
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CitizenServiceDetailsScreen(service: _selectedService!),
                    ),
                  );
                },
                onClose: () => setState(() => _selectedService = null),
              ),
            ),
          
          if (_selectedLostPerson != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _LostPersonCard(
                person: _selectedLostPerson!,
                onClose: () => setState(() => _selectedLostPerson = null),
              ),
            ),

          // -- Zoom controls --
          Positioned(
            right: 16,
            bottom: (_selectedService != null || _selectedLostPerson != null) ? 200 : 100,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.my_location,
                  onTap: () => _mapController.move(_pandharpurCenter, _initialZoom),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // -- Report Issue FAB --
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportIssueSheet,
        backgroundColor: const Color(0xFFC62828),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Report Issue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 2)),
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
                  'Pandharpur City Map',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF212121)),
                ),
                Text(
                  'शहराचा नकाशा',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6A1B9A)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.legend_toggle, color: Color(0xFF6A1B9A)),
            onPressed: () {},
            tooltip: 'Map Legend',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            icon: Icons.layers,
            isSelected: _currentFilter == CitizenMapFilter.all,
            onTap: () => setState(() => _currentFilter = CitizenMapFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Traffic 🔴',
            icon: Icons.traffic,
            isSelected: _currentFilter == CitizenMapFilter.traffic,
            onTap: () => setState(() => _currentFilter = CitizenMapFilter.traffic),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Donations 🎁',
            icon: Icons.volunteer_activism,
            isSelected: _currentFilter == CitizenMapFilter.donations,
            onTap: () => setState(() => _currentFilter = CitizenMapFilter.donations),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Lost Persons 📍',
            icon: Icons.person_search,
            isSelected: _currentFilter == CitizenMapFilter.lostPersons,
            onTap: () => setState(() => _currentFilter = CitizenMapFilter.lostPersons),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // General Services
    if (_currentFilter == CitizenMapFilter.all) {
      for (var s in _services) {
        markers.add(_buildServiceMarker(s));
      }
    }

    // Donations
    if (_currentFilter == CitizenMapFilter.all || _currentFilter == CitizenMapFilter.donations) {
      for (var s in _donations) {
        markers.add(_buildServiceMarker(s, isDonation: true));
      }
    }

    // Lost Persons
    if (_currentFilter == CitizenMapFilter.all || _currentFilter == CitizenMapFilter.lostPersons) {
      for (var lp in _lostPersons) {
        markers.add(
          Marker(
            point: lp.lastSeenLocation,
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLostPerson = lp;
                  _selectedService = null;
                });
                _mapController.move(lp.lastSeenLocation, _mapController.camera.zoom);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.red.withAlpha(120), blurRadius: 6)],
                ),
                child: const Icon(Icons.person_search, color: Colors.white, size: 20),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  Marker _buildServiceMarker(CitizenService service, {bool isDonation = false}) {
    Color color = isDonation ? Colors.pink : const Color(0xFF6A1B9A);
    IconData icon = isDonation ? Icons.volunteer_activism : Icons.place;

    if (!isDonation) {
      if (service.category == ServiceCategory.medical) color = const Color(0xFFC62828);
      if (service.category == ServiceCategory.medical) icon = Icons.medical_services;
      // ... other mappings can go here
    }

    return Marker(
      point: LatLng(service.latitude, service.longitude),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedService = service;
            _selectedLostPerson = null;
          });
          _mapController.move(LatLng(service.latitude, service.longitude), _mapController.camera.zoom);
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 6)],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _showReportIssueSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => const _ReportIssueSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A1B9A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey.shade300),
          boxShadow: [
            if (!isSelected) BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedServiceCard extends StatelessWidget {
  final CitizenService service;
  final VoidCallback onViewDetails;
  final VoidCallback onClose;

  const _SelectedServiceCard({required this.service, required this.onViewDetails, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(service.distanceLabel, style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onViewDetails,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
            child: const Text('View', style: TextStyle(color: Colors.white)),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }
}

class _LostPersonCard extends StatelessWidget {
  final MapLostPerson person;
  final VoidCallback onClose;

  const _LostPersonCard({required this.person, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 2),
        boxShadow: [BoxShadow(color: Colors.red.withAlpha(25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(person.description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }
}

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
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4)],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF6A1B9A)),
      ),
    );
  }
}

class _ReportIssueSheet extends StatelessWidget {
  const _ReportIssueSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Report an Issue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please login to report a local issue or sighting.'),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.login, color: Color(0xFFC62828)),
            title: const Text('Login via Phone/OTP'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login screen coming soon.')));
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ],
      ),
    );
  }
}
