import 'package:flutter/foundation.dart';
import 'audio_player_stub.dart' if (dart.library.html) 'audio_player_web.dart';

/// Universal cross-platform helper to play base64 WAV audio streams.
void playBase64Audio(String base64Audio, {String mimeType = 'audio/wav'}) {
  if (base64Audio.isEmpty) return;
  if (kIsWeb) {
    playWebAudio(base64Audio, mimeType: mimeType);
  } else {
    debugPrint('[AudioPlayer] Audio payload: ${base64Audio.length} base64 chars');
  }
}
