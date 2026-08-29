import 'package:flutter/material.dart';
import 'citizen_home_screen.dart';

/// Entry point redirect for the Local Citizen Module.
/// Owned by: Gauri — Local Citizen Module
///
/// Routes immediately to the CitizenHomeScreen.
/// Kept as a thin wrapper so CitizenModule.screen() contract stays intact.
class CitizenInitializerScreen extends StatelessWidget {
  const CitizenInitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly return the home screen — no loading needed for mock data.
    return const CitizenHomeScreen();
  }
}
