import 'map_config.dart';
import 'map_service_interface.dart';

/// Concrete MapTiler implementation of [MapServiceInterface].
class MapTilerMapService implements MapServiceInterface {
  MapProviderType _provider = MapProviderType.mapLibreMapTilerOSM;

  @override
  MapProviderType get currentProvider => _provider;

  @override
  String? get mapTilerApiKey =>
      MapConfig.hasMapTilerApiKey ? MapConfig.mapTilerApiKey : null;

  @override
  void setProvider(MapProviderType provider) {
    _provider = provider;
  }
}
