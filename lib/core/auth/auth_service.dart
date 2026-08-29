import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized, production-grade Supabase Authentication & Profile Management Service.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initAuthListener();
  }

  final String _baseUrl = 'http://localhost:3000/api';
  Map<String, dynamic>? _currentProfile;

  Map<String, dynamic>? get currentProfile => _currentProfile;

  bool get isSupabaseInitialized {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser {
    if (!isSupabaseInitialized) return null;
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Session? get currentSession {
    if (!isSupabaseInitialized) return null;
    try {
      return Supabase.instance.client.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  String? get accessToken => currentSession?.accessToken;

  bool get isAuthenticated => currentUser != null && _currentProfile != null;

  void _initAuthListener() {
    if (!isSupabaseInitialized) return;
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
          if (session?.user != null) {
            await fetchProfileById(session!.user.id);
          }
        } else if (event == AuthChangeEvent.signedOut) {
          _currentProfile = null;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Supabase Auth state listener initialization deferred: $e');
    }
  }

  /// Restores session on app launch
  Future<void> restoreSession() async {
    if (!isSupabaseInitialized) return;
    try {
      final user = currentUser;
      if (user != null) {
        await fetchProfileById(user.id);
      }
    } catch (e) {
      debugPrint('Restore session error: $e');
    }
  }

  /// Sign in with Email and Password
  Future<Map<String, dynamic>?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!isSupabaseInitialized) {
      throw Exception('Supabase instance is not initialized');
    }
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (res.user != null) {
        return await fetchProfileById(res.user!.id);
      }
    } on AuthException catch (e) {
      debugPrint('Sign in AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
    return null;
  }

  /// Sign up with Email and Password (Defaults to pilgrim role)
  Future<Map<String, dynamic>?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!isSupabaseInitialized) {
      throw Exception('Supabase instance is not initialized');
    }
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': displayName ?? email.split('@')[0],
          'display_name': displayName ?? email.split('@')[0],
        },
      );

      if (res.user != null) {
        return await fetchProfileById(res.user!.id);
      }
    } on AuthException catch (e) {
      debugPrint('Sign up AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
    return null;
  }

  /// Continue with Google OAuth
  Future<bool> signInWithGoogle() async {
    if (!isSupabaseInitialized) {
      throw Exception('Supabase instance is not initialized');
    }
    try {
      final bool res = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'mazapandurang://login-callback',
      );
      return res;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Dindi Leader Application Integration
  Future<Map<String, dynamic>?> applyDindiLeader({
    required String userId,
    required String dindiName,
    required String startPoint,
    required String destination,
    required int expectedMembers,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final res = await http.post(
        Uri.parse('$_baseUrl/dindi-leader/apply'),
        headers: headers,
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

  /// Fetch user profile authoritatively from Express backend or Supabase
  Future<Map<String, dynamic>?> fetchProfileById(String userId) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final res = await http.get(
        Uri.parse('$_baseUrl/profiles/$userId'),
        headers: headers,
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

  void setCurrentProfile(Map<String, dynamic> profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (isSupabaseInitialized) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Sign out error: $e');
      }
    }
    _currentProfile = null;
    notifyListeners();
  }
}
