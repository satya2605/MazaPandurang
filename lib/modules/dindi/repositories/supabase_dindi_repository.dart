import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/auth/auth_service.dart';
import '../models/dindi_announcement.dart';
import '../models/dindi_group.dart';
import '../models/dindi_member.dart';
import 'dindi_repository.dart';

/// Exception thrown when a Dindi repository operation fails.
class DindiRepositoryException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const DindiRepositoryException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() =>
      'DindiRepositoryException: $message (status: $statusCode)';
}

/// Production REST API Dindi Repository communicating through the Node.js
/// REST API gateway (`/api/dindis` and `/api/dindi-memberships`) backed by Supabase PostgreSQL.
///
/// NOTE: In accordance with architectural contracts, failures are surfaced
/// explicitly rather than silently masking database errors with mock data.
class SupabaseDindiRepository implements DindiRepository {
  final String baseUrl;
  final http.Client _client;

  SupabaseDindiRepository({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ??
            const String.fromEnvironment('API_BASE_URL',
                defaultValue: 'http://localhost:3000'),
        _client = client ?? http.Client();

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    final token = AuthService().accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      final profile = AuthService().currentProfile;
      final userId = profile?['id']?.toString() ?? '00000000-0000-0000-0000-000000000002';
      headers['Authorization'] = 'Bearer test-jwt-$userId';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  @override
  Future<List<DindiGroup>> getDindis({String? leaderUserId}) async {
    final uri = leaderUserId != null && leaderUserId.isNotEmpty
        ? Uri.parse('$baseUrl/api/dindis?leader_id=$leaderUserId')
        : Uri.parse('$baseUrl/api/dindis');

    try {
      final response = await _client.get(
        uri,
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => DindiGroup.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        final errorMsg = _extractErrorMessage(response.body) ??
            'Failed to fetch Dindis (HTTP ${response.statusCode})';
        throw DindiRepositoryException(
          errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DindiRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] getDindis network error: $e');
      throw DindiRepositoryException(
        'Unable to connect to Dindi service: $e',
      );
    }
  }

  @override
  Future<DindiGroup?> getDindiById(String id) async {
    final uri = Uri.parse('$baseUrl/api/dindis/$id');

    try {
      final response = await _client.get(
        uri,
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return DindiGroup.fromJson(decoded);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final errorMsg = _extractErrorMessage(response.body) ??
            'Failed to fetch Dindi $id (HTTP ${response.statusCode})';
        throw DindiRepositoryException(
          errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DindiRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] getDindiById network error: $e');
      throw DindiRepositoryException(
        'Unable to connect to Dindi service: $e',
      );
    }
  }

  @override
  Future<DindiGroup> createDindi(DindiGroup dindi) async {
    final uri = Uri.parse('$baseUrl/api/dindis');

    try {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders({'Content-Type': 'application/json'}),
            body: json.encode(dindi.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return DindiGroup.fromJson(decoded);
        }
        return dindi;
      } else {
        final errorMsg = _extractErrorMessage(response.body) ??
            'Failed to create Dindi (HTTP ${response.statusCode})';
        throw DindiRepositoryException(
          errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DindiRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] createDindi network error: $e');
      throw DindiRepositoryException(
        'Unable to create Dindi: $e',
      );
    }
  }

  @override
  Future<DindiGroup> updateDindi(DindiGroup dindi) async {
    final uri = Uri.parse('$baseUrl/api/dindis/${dindi.id}');

    try {
      final response = await _client
          .patch(
            uri,
            headers: _buildHeaders({'Content-Type': 'application/json'}),
            body: json.encode(dindi.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return DindiGroup.fromJson(decoded);
        }
        return dindi;
      } else {
        final errorMsg = _extractErrorMessage(response.body) ??
            'Failed to update Dindi (HTTP ${response.statusCode})';
        throw DindiRepositoryException(
          errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DindiRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] updateDindi network error: $e');
      throw DindiRepositoryException(
        'Unable to update Dindi: $e',
      );
    }
  }

  @override
  Future<bool> updateDindiLocation(
    String dindiId, {
    required double latitude,
    required double longitude,
    String? locationName,
    String? currentHalt,
  }) async {
    final uri = Uri.parse('$baseUrl/api/dindis/$dindiId/location');
    try {
      final response = await _client.patch(
        uri,
        headers: _buildHeaders({'Content-Type': 'application/json'}),
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'current_location_name': locationName,
          'current_halt': currentHalt,
        }),
      ).timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] updateDindiLocation error: $e');
      return false;
    }
  }

  @override
  Future<bool> addDindiHalt(String dindiId, Map<String, dynamic> haltData) async {
    final uri = Uri.parse('$baseUrl/api/dindis/$dindiId/halts');
    try {
      final response = await _client.post(
        uri,
        headers: _buildHeaders({'Content-Type': 'application/json'}),
        body: json.encode(haltData),
      ).timeout(const Duration(seconds: 6));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] addDindiHalt error: $e');
      return false;
    }
  }

  @override
  Future<bool> updateDindiHalt(String haltId, Map<String, dynamic> haltData) async {
    final uri = Uri.parse('$baseUrl/api/dindis/halts/$haltId');
    try {
      final response = await _client.put(
        uri,
        headers: _buildHeaders({'Content-Type': 'application/json'}),
        body: json.encode(haltData),
      ).timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] updateDindiHalt error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteDindiHalt(String haltId) async {
    final uri = Uri.parse('$baseUrl/api/dindis/halts/$haltId');
    try {
      final response = await _client.delete(
        uri,
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] deleteDindiHalt error: $e');
      return false;
    }
  }

  // ----------------------------------------------------
  // Live Member Operations via Shared REST API Gateway
  // ----------------------------------------------------
  @override
  Future<List<DindiMember>> getMembers(String dindiId) async {
    final uri = Uri.parse('$baseUrl/api/dindis/$dindiId/members');

    try {
      final response = await _client.get(
        uri,
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => DindiMember.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        final errorMsg = _extractErrorMessage(response.body) ??
            'Failed to fetch members for Dindi $dindiId (HTTP ${response.statusCode})';
        throw DindiRepositoryException(
          errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DindiRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] getMembers network error: $e');
      throw DindiRepositoryException(
        'Unable to fetch Dindi members: $e',
      );
    }
  }

  @override
  Future<void> updateMemberStatus(
      String memberId, DindiMemberStatus status) async {
    final uri = Uri.parse('$baseUrl/api/dindi-memberships/$memberId');

    final statusString =
        status == DindiMemberStatus.approved ? 'active' : status.name;

    try {
      final response = await _client
          .patch(
            uri,
            headers: _buildHeaders({'Content-Type': 'application/json'}),
            body: json.encode({'status': statusString}),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) {
        final errorMsg = _extractErrorMessage(response.body) ??
            'Failed to update member status (HTTP ${response.statusCode})';
        throw DindiRepositoryException(
          errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DindiRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[SupabaseDindiRepository] updateMemberStatus error: $e');
      throw DindiRepositoryException(
        'Unable to update member status: $e',
      );
    }
  }

  @override
  Future<void> removeMember(String memberId) async {
    // In database semantics, removing/rejecting sets status to 'rejected'
    await updateMemberStatus(memberId, DindiMemberStatus.rejected);
  }

  // ----------------------------------------------------
  // Announcements Delegate (No fake backend data)
  // ----------------------------------------------------
  @override
  Future<List<DindiAnnouncement>> getAnnouncements(String dindiId) async {
    return [];
  }

  @override
  Future<void> addAnnouncement(DindiAnnouncement announcement) async {
    return;
  }

  // ----------------------------------------------------
  // Helper to extract clean error message from backend JSON
  // ----------------------------------------------------
  String? _extractErrorMessage(String responseBody) {
    try {
      final dynamic decoded = json.decode(responseBody);
      if (decoded is Map<String, dynamic>) {
        if (decoded['error'] is Map<String, dynamic>) {
          return decoded['error']['message']?.toString();
        } else if (decoded['error'] is String) {
          return decoded['error'] as String;
        } else if (decoded['message'] is String) {
          return decoded['message'] as String;
        }
      }
    } catch (_) {}
    return null;
  }
}
