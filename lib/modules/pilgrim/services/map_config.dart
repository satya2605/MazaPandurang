/// Centralized Map Configuration reading environment parameters.
abstract class MapConfig {
  /// Reads MapTiler client API key passed via `--dart-define=MAPTILER_API_KEY=your_key`.
  /// Note: Client-side keys are browser-visible for web rendering and should be
  /// protected via MapTiler Dashboard HTTP Origin/Domain restrictions.
  static const String mapTilerApiKey =
      String.fromEnvironment('MAPTILER_API_KEY', defaultValue: '');

  /// Checks if a non-empty MapTiler API Key is provided.
  static bool get hasMapTilerApiKey => mapTilerApiKey.trim().isNotEmpty;

  /// Default MapTiler vector style endpoint URL.
  static String get mapTilerStyleUrl {
    if (!hasMapTilerApiKey) return '';
    return 'https://api.maptiler.com/maps/streets-v2/style.json?key=$mapTilerApiKey';
  }
}
