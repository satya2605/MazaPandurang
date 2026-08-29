import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/auth_service.dart';

/// Shared API Client that automatically attaches Supabase JWT access tokens
/// for authenticated requests to the Express backend gateway.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String baseUrl = 'http://localhost:3000/api';
  final AuthService _authService = AuthService();

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Attach verified Supabase JWT bearer token
    final token = _authService.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _buildHeaders(headers));
  }

  Future<http.Response> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: _buildHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> patch(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.patch(
      url,
      headers: _buildHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: _buildHeaders(headers));
  }
}
