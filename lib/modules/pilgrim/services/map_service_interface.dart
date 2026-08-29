/// Supported map rendering providers.
enum MapProviderType {
  mapLibreMapTilerOSM, // Primary OSM-based renderer (MapLibre Flutter + MapTiler)
  googleMaps, // Optional alternate Google Maps provider
}

/// Abstract interface for map rendering and routing.
abstract class MapServiceInterface {
  MapProviderType get currentProvider;

  /// MapTiler Cloud API key configuration point.
  String? get mapTilerApiKey;

  /// Switch active map rendering provider.
  void setProvider(MapProviderType provider);
}

/// Default MapLibre + MapTiler + OpenStreetMap service configuration.
class DefaultMapService implements MapServiceInterface {
  MapProviderType _provider = MapProviderType.mapLibreMapTilerOSM;
  final String? _apiKey;

  DefaultMapService({String? mapTilerApiKey}) : _apiKey = mapTilerApiKey;

  @override
  MapProviderType get currentProvider => _provider;

  @override
  String? get mapTilerApiKey => _apiKey;

  @override
  void setProvider(MapProviderType provider) {
    _provider = provider;
  }
}
