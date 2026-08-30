// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

html.AudioElement? _activeAudioElement;

void playWebAudio(String base64Audio, {String mimeType = 'audio/wav'}) async {
  if (base64Audio.isEmpty) return;

  try {
    final cleanBase64 = base64Audio.replaceAll(RegExp(r'\s+'), '');
    final dataUrl = 'data:$mimeType;base64,$cleanBase64';

    if (_activeAudioElement != null) {
      try {
        _activeAudioElement!.pause();
        _activeAudioElement!.remove();
      } catch (_) {}
      _activeAudioElement = null;
    }

    final audioElement = html.AudioElement(dataUrl);
    audioElement.autoplay = true;
    audioElement.controls = false;
    _activeAudioElement = audioElement;

    html.document.body?.children.add(audioElement);

    debugPrint('[WebAudioPlayer] Playing base64 audio payload (${cleanBase64.length} chars)...');

    await audioElement.play().then((_) {
      debugPrint('[WebAudioPlayer] HTML5 Audio playback started successfully.');
    }).catchError((err) {
      debugPrint('[WebAudioPlayer] HTML5 Audio playback error: $err');
    });
  } catch (e) {
    debugPrint('[WebAudioPlayer] playWebAudio Exception: $e');
  }
}
