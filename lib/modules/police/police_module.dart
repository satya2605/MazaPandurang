import 'package:flutter/material.dart';
import 'screens/login/police_login_screen.dart';

/// Police / Authority Module entry point owned by Yogeshwari.
/// Entry: PoliceLoginScreen → PoliceShellScreen (Dashboard | Map | Alerts | More)
class PoliceModule {
  static Widget screen() {
    return const PoliceLoginScreen();
  }
}
