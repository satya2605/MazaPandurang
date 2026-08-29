import 'package:latlong2/latlong.dart';

/// A map point of interest displayed on the Police Live Operations Map.
enum MapPoiType { palkhi, dindi, medical, police, emergency, traffic }

class MapPoi {
  final String id;
  final String label;
  final MapPoiType type;
  final LatLng position;
  final String? detail;
  final String? status;

  const MapPoi({
    required this.id,
    required this.label,
    required this.type,
    required this.position,
    this.detail,
    this.status,
  });
}
