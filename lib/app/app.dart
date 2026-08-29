import 'package:flutter/material.dart';
import '../common/theme/app_theme.dart';
import '../common/navigation/app_routes.dart';
import '../core/auth/auth_gate.dart';

class MazaPandurangApp extends StatelessWidget {
  const MazaPandurangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maza Pandurang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: AppRoutes.routes,
    );
  }
}
