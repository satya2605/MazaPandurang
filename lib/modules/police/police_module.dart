import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import 'screens/dashboard/police_shell_screen.dart';
import 'screens/login/police_login_screen.dart';

/// Police / Authority Module entry point owned by Yogeshwari.
/// Entry: PoliceShellScreen for authenticated police authority, or PoliceLoginScreen
class PoliceModule {
  static Widget screen() {
    final profile = AuthService().currentProfile;
    final role = profile?['role']?.toString().toLowerCase();
    if (role == 'police_authority' || role == 'police') {
      return const PoliceShellScreen();
    }
    return const PoliceLoginScreen();
  }
}
