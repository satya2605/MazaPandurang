import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String _baseUrl = 'http://localhost:3000/api';

  Map<String, dynamic>? _currentProfile;
  Map<String, dynamic>? get currentProfile => _currentProfile;

  bool get isAuthenticated => _currentProfile != null;

  Future<Map<String, dynamic>?> fetchProfileById(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/profiles/$userId'),
        headers: {'Content-Type': 'application/json', 'x-user-id': userId},
      );

      if (res.statusCode == 200) {
        _currentProfile = jsonDecode(res.body);
        notifyListeners();
        return _currentProfile;
      }
    } catch (e) {
      debugPrint('Failed to fetch profile: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> applyDindiLeader({
    required String userId,
    required String dindiName,
    required String startPoint,
    required String destination,
    required int expectedMembers,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/dindi-leader/apply'),
        headers: {'Content-Type': 'application/json', 'x-user-id': userId},
        body: jsonEncode({
          'dindi_name': dindiName,
          'start_point': startPoint,
          'destination': destination,
          'expected_members': expectedMembers,
        }),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _currentProfile = data['profile'];
        notifyListeners();
        return data;
      }
    } catch (e) {
      debugPrint('Failed to submit Dindi Leader application: $e');
    }
    return null;
  }

  void setCurrentProfile(Map<String, dynamic> profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  void signOut() {
    _currentProfile = null;
    notifyListeners();
  }
}
