import 'package:flutter/material.dart';
import '../repositories/pilgrim_repository.dart';
import 'emergency_screen.dart';

class HelpScreen extends StatelessWidget {
  final PilgrimRepository? repository;

  const HelpScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return EmergencyScreen(repository: repository);
  }
}
