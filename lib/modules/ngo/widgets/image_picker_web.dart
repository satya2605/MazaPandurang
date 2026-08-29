import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web implementation: picks a file, compresses via HTML5 Canvas, returns
/// compressed JPEG as both a data-URL (for immediate preview) and raw bytes
/// (for Supabase upload).
///
/// Returns null if the user cancels or an error occurs.
Future<PickedImage?> webPickAndCompressImage({
  int maxDimension = 800,
  double quality = 0.78,
}) async {
  final completer = Completer<PickedImage?>();

  // Create a hidden <input type="file"> element
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..style.display = 'none';
  html.document.body!.append(input);

  bool picked = false;

  input.onChange.listen((event) async {
    picked = true;
    try {
      final file = input.files?.first;
      if (file == null) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }

      // Read file as data URL
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      await reader.onLoad.first;
      final rawDataUrl = reader.result as String;

      // Draw onto canvas at reduced resolution
      final img = html.ImageElement(src: rawDataUrl);
      await img.onLoad.first;

      int srcW = img.naturalWidth;
      int srcH = img.naturalHeight;

      // Scale down proportionally if needed
      if (srcW > maxDimension || srcH > maxDimension) {
        if (srcW >= srcH) {
          srcH = (srcH * maxDimension / srcW).round();
          srcW = maxDimension;
        } else {
          srcW = (srcW * maxDimension / srcH).round();
          srcH = maxDimension;
        }
      }

      final canvas = html.CanvasElement(width: srcW, height: srcH);
      canvas.context2D.drawImageScaled(img, 0, 0, srcW, srcH);

      // Export as compressed JPEG data URL
      final dataUrl = canvas.toDataUrl('image/jpeg', quality);

      // Convert data URL to raw bytes for Supabase upload
      // data:image/jpeg;base64,<base64data>
      final base64 = dataUrl.split(',').last;
      final bytes = _base64ToUint8List(base64);

      if (!completer.isCompleted) {
        completer.complete(PickedImage(dataUrl: dataUrl, bytes: bytes));
      }
    } catch (_) {
      if (!completer.isCompleted) completer.complete(null);
    } finally {
      input.remove();
    }
  });

  input.click();

  // Detect cancel: when the file dialog closes, the window regains focus.
  // Use a delay so the onChange fires first if the user actually selected a file.
  html.window.addEventListener('focus', null);
  html.window.onFocus.first.then((_) async {
    // Wait a short moment — onChange fires before focus in most browsers
    await Future.delayed(const Duration(milliseconds: 600));
    if (!picked && !completer.isCompleted) {
      completer.complete(null);
    }
  });

  return completer.future;
}

/// Decode base64 string to Uint8List.
Uint8List _base64ToUint8List(String base64) {
  // Use dart:convert via html (available in web context)
  final decoded = html.window.atob(base64);
  final bytes = Uint8List(decoded.length);
  for (int i = 0; i < decoded.length; i++) {
    bytes[i] = decoded.codeUnitAt(i);
  }
  return bytes;
}

/// Holds the result of a web image pick operation.
class PickedImage {
  /// JPEG data URL for immediate preview without network round-trip.
  final String dataUrl;

  /// Raw JPEG bytes for uploading to Supabase Storage.
  final Uint8List bytes;

  const PickedImage({required this.dataUrl, required this.bytes});
}
