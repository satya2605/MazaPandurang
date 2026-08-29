import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../../modules/admin/admin_module.dart';
import '../../modules/citizen/citizen_module.dart';
import '../../modules/dindi/dindi_module.dart';
import '../../modules/ngo/ngo_module.dart';
import '../../modules/pilgrim/pilgrim_module.dart';
import '../../modules/police/police_module.dart';
import 'auth_service.dart';
import 'screens/login_screen.dart';

/// Single authoritative entry point and authentication gate for the entire application.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkSession() async {
    try {
      await _authService.restoreSession();
    } catch (e) {
      debugPrint('AuthGate session restore error: $e');
    } finally {
      if (mounted) {
        setState(() => _isCheckingSession = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Session Restoration / Loading Splash Screen
    if (_isCheckingSession) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.temple_hindu, color: AppColors.primary, size: 54),
              ),
              const SizedBox(height: 24),
              const Text(
                'माझा पांडुरंग',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Checking your session...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Unauthenticated -> Render LoginScreen
    if (!_authService.isAuthenticated || _authService.currentUser == null) {
      return const LoginScreen();
    }

    // 3. Authenticated -> Inspect server/profile role & status
    final profile = _authService.currentProfile;
    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Profile Not Found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your authenticated identity does not have an active profile record.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final String status = (profile['status'] ?? 'active').toString().toLowerCase();
    if (status == 'suspended') {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Account Suspended',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account has been suspended by platform administration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String role = (profile['role'] ?? 'pilgrim').toString().toLowerCase();
    switch (role) {
      case 'admin':
        return AdminModule.screen();
      case 'dindi_leader':
        return DindiModule.screen();
      case 'police_authority':
      case 'police':
        return PoliceModule.screen();
      case 'ngo_volunteer':
      case 'ngo':
        return NgoModule.screen();
      case 'local_citizen':
      case 'citizen':
        return CitizenModule.screen();
      case 'palkhi_operator':
        return PilgrimModule.screen();
      case 'pilgrim':
      default:
        return PilgrimModule.screen();
    }
  }
}
