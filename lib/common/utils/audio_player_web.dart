// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void playWebAudio(String base64Audio, {String mimeType = 'audio/wav'}) {
  try {
    final dataUrl = 'data:$mimeType;base64,$base64Audio';
    final audioElement = html.AudioElement(dataUrl);
    audioElement.autoplay = true;
    audioElement.play();
  } catch (e) {
    // ignore audio element error
  }
}
