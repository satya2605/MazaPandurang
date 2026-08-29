import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/map_poi.dart';
import '../../data/repositories/police_demo_repository.dart';

/// Police Live Operations Map — displays all POIs with filter chips.
class PoliceMapScreen extends StatefulWidget {
  const PoliceMapScreen({super.key});

  @override
  State<PoliceMapScreen> createState() => _PoliceMapScreenState();
}

class _PoliceMapScreenState extends State<PoliceMapScreen> {
  final _repo = PoliceDemoRepository.instance;
  MapPoiType? _activeFilter; // null = show all

  static const _policeNavy = Color(0xFF1565C0);

  // Map centred on Pune–Pandharpur corridor midpoint
  static const _initialCenter = LatLng(18.0996, 74.3390);
  static const _initialZoom = 9.0;

  static const _filters = [
    (label: 'All', type: null as MapPoiType?),
    (label: 'Palkhi', type: MapPoiType.palkhi),
    (label: 'Dindi', type: MapPoiType.dindi),
    (label: 'Medical', type: MapPoiType.medical),
    (label: 'Police', type: MapPoiType.police),
    (label: 'Emergency', type: MapPoiType.emergency),
    (label: 'Traffic', type: MapPoiType.traffic),
  ];

  Color _colorForType(MapPoiType type) {
    switch (type) {
      case MapPoiType.palkhi:
        return const Color(0xFFE65100);
      case MapPoiType.dindi:
        return const Color(0xFFD84315);
      case MapPoiType.medical:
        return const Color(0xFFD32F2F);
      case MapPoiType.police:
        return _policeNavy;
      case MapPoiType.emergency:
        return const Color(0xFFB71C1C);
      case MapPoiType.traffic:
        return const Color(0xFFF57F17);
    }
  }

  IconData _iconForType(MapPoiType type) {
    switch (type) {
      case MapPoiType.palkhi:
        return Icons.temple_hindu;
      case MapPoiType.dindi:
        return Icons.groups;
      case MapPoiType.medical:
        return Icons.local_hospital;
      case MapPoiType.police:
        return Icons.local_police;
      case MapPoiType.emergency:
        return Icons.emergency;
      case MapPoiType.traffic:
        return Icons.traffic;
    }
  }

  void _showPoiDetail(BuildContext ctx, MapPoi poi) {
    final color = _colorForType(poi.type);
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconForType(poi.type), color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    poi.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                if (poi.status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      poi.status!,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (poi.detail != null) ...[
              const SizedBox(height: 12),
              Text(
                poi.detail!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigation app would open here.'),
                        ),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<MapPoi> get _filteredPois {
    final all = _repo.allMapPois;
    if (_activeFilter == null) return all;
    return all.where((p) => p.type == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _policeNavy,
        title: const Text(
          'Live Operations Map',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('GPS location: demo mode')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _activeFilter == f.type;
                return ChoiceChip(
                  label: Text(f.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _activeFilter = f.type),
                  selectedColor: _policeNavy.withAlpha(40),
                  labelStyle: TextStyle(
                    color: selected ? _policeNavy : const Color(0xFF555555),
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          // Map
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: _initialCenter,
                initialZoom: _initialZoom,
                minZoom: 6,
                maxZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.mazapandurang.app',
                ),
                MarkerLayer(
                  markers: _filteredPois.map((poi) {
                    final color = _colorForType(poi.type);
                    return Marker(
                      point: poi.position,
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => _showPoiDetail(context, poi),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(120),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            _iconForType(poi.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
