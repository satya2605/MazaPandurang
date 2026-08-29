import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Flutter Client
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://fjnhsaxuwyairfgrciyf.supabase.co',
      ),
      anonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqbmhzYXh1d3lhaXJmZ3JjaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MTM0ODMsImV4cCI6MjA3NDk4OTQ4M30.demo-placeholder-anon-key',
      ),
    );
    await AuthService().restoreSession();
  } catch (e) {
    debugPrint('Supabase initialization warning: $e');
  }

  runApp(const MazaPandurangApp());
}
