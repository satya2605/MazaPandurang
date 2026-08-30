import 'dart:convert';
import 'dart:math' as math;
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
      Supabase.instance.client;
      return true;
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

  /// Sign up with Email and Password
  Future<Map<String, dynamic>?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
    String? role,
  }) async {
    if (!isSupabaseInitialized) {
      throw Exception('Supabase instance is not initialized');
    }
    try {
      final selectedRole = role ?? 'pilgrim';
      final selectedName = displayName ?? email.split('@')[0];

      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': selectedName,
          'display_name': selectedName,
          'role': selectedRole,
        },
      );

      if (res.user != null) {
        final initialStatus = (selectedRole == 'dindi_leader' || selectedRole == 'ngo_volunteer')
            ? 'pending'
            : 'active';

        // 1. Authoritative Backend Profile Update (runs with service role, bypassing RLS)
        try {
          final patchRes = await http.patch(
            Uri.parse('$_baseUrl/profiles/${res.user!.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'display_name': selectedName,
              'role': selectedRole,
              'status': initialStatus,
            }),
          );
          if (patchRes.statusCode == 200) {
            final data = jsonDecode(patchRes.body);
            if (data is Map<String, dynamic>) {
              data['role'] = selectedRole;
              data['status'] = initialStatus;
              _currentProfile = data;
              notifyListeners();
              return data;
            }
          }
        } catch (e) {
          debugPrint('Backend profile patch error during signup: $e');
        }

        // 2. Direct Supabase Client fallback upsert
        try {
          await Supabase.instance.client.from('profiles').upsert({
            'id': res.user!.id,
            'email': email.trim(),
            'display_name': selectedName,
            'role': selectedRole,
            'status': initialStatus,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');

          // If Police Authority, also create/upsert police_profiles record
          if (selectedRole == 'police_authority') {
            await Supabase.instance.client.from('police_profiles').upsert({
              'user_id': res.user!.id,
              'police_id': 'POL-MH-${res.user!.id.substring(0, math.min(8, res.user!.id.length)).toUpperCase()}',
              'name': selectedName,
              'designation': 'Police Officer',
              'station_name': 'Pandharpur Sector Police',
              'role': 'POLICE_OFFICER',
              'status': 'ACTIVE',
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'user_id');
          }
        } catch (e) {
          debugPrint('Profile upsert during signup warning: $e');
        }

        final profile = await fetchProfileById(res.user!.id);
        if (profile != null) {
          profile['role'] = selectedRole;
          profile['status'] = initialStatus;
          _currentProfile = profile;
          notifyListeners();
          return profile;
        }

        _currentProfile = {
          'id': res.user!.id,
          'email': email.trim(),
          'display_name': selectedName,
          'role': selectedRole,
          'status': initialStatus,
        };
        notifyListeners();
        return _currentProfile;
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

  /// Police Authority Application/Registration Integration
  Future<Map<String, dynamic>?> registerPoliceAuthority({
    required String name,
    String? policeId,
    String? designation,
    String? stationName,
    String? phone,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final res = await http.post(
        Uri.parse('$_baseUrl/police/register'),
        headers: headers,
        body: jsonEncode({
          'police_id': policeId,
          'name': name,
          'designation': designation,
          'station_name': stationName,
          'phone': phone,
        }),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _currentProfile = data['profile'];
        notifyListeners();
        return data;
      }
    } catch (e) {
      debugPrint('Failed to register Police Authority profile: $e');
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
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        _currentProfile = jsonDecode(res.body);
        notifyListeners();
        return _currentProfile;
      }
    } catch (e) {
      debugPrint('Failed to fetch profile from Express backend: $e');
    }

    // Direct Supabase Database Fallback
    if (isSupabaseInitialized) {
      try {
        final res = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (res != null) {
          _currentProfile = Map<String, dynamic>.from(res);
          notifyListeners();
          return _currentProfile;
        }
      } catch (e) {
        debugPrint('Direct Supabase profile lookup error: $e');
      }
    }

    // Auth Metadata Fallback
    final user = currentUser;
    if (user != null && user.id == userId) {
      _currentProfile = {
        'id': user.id,
        'email': user.email ?? '',
        'display_name': user.userMetadata?['full_name'] ??
            user.userMetadata?['display_name'] ??
            user.email?.split('@')[0] ??
            'Warkari Pilgrim',
        'role': user.userMetadata?['role'] ?? 'pilgrim',
        'status': 'active',
      };
      notifyListeners();
      return _currentProfile;
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
