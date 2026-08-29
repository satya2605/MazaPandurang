import '../models/pilgrim_models.dart';

/// Enum representing all possible location permission & availability states.
enum LocationPermissionStatus {
  notRequested,
  granted,
  denied,
  permanentlyDenied,
  unavailable,
  loading,
}

/// Service handling device GPS position and permission states safely without crashing.
class LocationService {
  LocationPermissionStatus _status = LocationPermissionStatus.notRequested;
  PilgrimLocation? _cachedLocation;

  LocationPermissionStatus get status => _status;
  PilgrimLocation? get cachedLocation => _cachedLocation;

  /// Requests location permission safely.
  Future<LocationPermissionStatus> requestPermission() async {
    _status = LocationPermissionStatus.loading;
    try {
      // Simulates location permission grant with default Saswad Wari location
      _status = LocationPermissionStatus.granted;
      _cachedLocation = PilgrimLocation(
        pilgrimId: '00000000-0000-0000-0000-000000000001',
        name: 'Satyajit Pilgrim',
        position: const WariLatLng(18.3411, 74.0305),
        lastUpdated: DateTime.now(),
      );
    } catch (_) {
      _status = LocationPermissionStatus.denied;
    }
    return _status;
  }

  /// Obtains device location if permission is granted.
  Future<PilgrimLocation?> getCurrentLocation() async {
    if (_status == LocationPermissionStatus.notRequested) {
      await requestPermission();
    }
    if (_status == LocationPermissionStatus.granted) {
      return _cachedLocation ??
          PilgrimLocation(
            pilgrimId: '00000000-0000-0000-0000-000000000001',
            name: 'Satyajit Pilgrim',
            position: const WariLatLng(18.3411, 74.0305),
            lastUpdated: DateTime.now(),
          );
    }
    return null;
  }

  /// Sets mock location status for testing.
  void setMockStatus(LocationPermissionStatus status, {PilgrimLocation? location}) {
    _status = status;
    _cachedLocation = location;
  }
}
