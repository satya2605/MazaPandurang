import 'dart:typed_data';

/// Stub: holds picked image data. Mirrors image_picker_web.dart.
class PickedImage {
  final String dataUrl;
  final Uint8List bytes;
  const PickedImage({required this.dataUrl, required this.bytes});
}

/// Stub implementation for non-web platforms.
/// Image picking is not supported outside Flutter Web — returns null immediately.
Future<PickedImage?> webPickAndCompressImage({
  int maxDimension = 800,
  double quality = 0.78,
}) async {
  return null;
}
