import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'ngo_supabase_config.dart';

/// Handles image uploads to Supabase Storage for the NGO module.
///
/// Uses the `service-images` public bucket.
/// Path convention: service-images/<serviceId>/<timestamp>.jpg
abstract class NgoImageService {
  /// Uploads raw JPEG bytes to Supabase Storage.
  ///
  /// Returns the public URL of the uploaded image, or null on failure.
  static Future<String?> uploadServiceImage({
    required String serviceId,
    required Uint8List jpegBytes,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$serviceId/$timestamp.jpg';
      final uploadUrl = Uri.parse(
          '${NgoSupabaseConfig.storageApiUrl}/${NgoSupabaseConfig.serviceImagesBucket}/$path');

      final response = await http.post(
        uploadUrl,
        headers: {
          'Authorization': 'Bearer ${NgoSupabaseConfig.anonKey}',
          'Content-Type': 'image/jpeg',
          'x-upsert': 'true',
        },
        body: jpegBytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return the public URL
        return '${NgoSupabaseConfig.storageBaseUrl}/${NgoSupabaseConfig.serviceImagesBucket}/$path';
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Deletes an image from Supabase Storage by its full public URL.
  /// Returns true on success.
  static Future<bool> deleteServiceImage(String publicUrl) async {
    try {
      // Extract the path after the bucket name
      // ignore: prefer_const_declarations
      final bucketPrefix =
          '${NgoSupabaseConfig.storageBaseUrl}/${NgoSupabaseConfig.serviceImagesBucket}/';
      if (!publicUrl.startsWith(bucketPrefix)) return false;
      final path = publicUrl.substring(bucketPrefix.length);

      final deleteUrl = Uri.parse(
          '${NgoSupabaseConfig.storageApiUrl}/${NgoSupabaseConfig.serviceImagesBucket}/$path');

      final response = await http.delete(
        deleteUrl,
        headers: {
          'Authorization': 'Bearer ${NgoSupabaseConfig.anonKey}',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
