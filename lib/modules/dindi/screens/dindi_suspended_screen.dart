import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/navigation/app_routes.dart';

/// Screen displayed when a Dindi Leader's privileges have been suspended by Admin.
class DindiSuspendedScreen extends StatelessWidget {
  final String? reason;

  const DindiSuspendedScreen({super.key, this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Suspended'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade600, width: 2),
                ),
                child: Icon(
                  Icons.block_outlined,
                  size: 50,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dindi Leader Privileges Suspended',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                reason ??
                    'Your Dindi Leader account has been suspended by administration. Management controls are locked. Please contact the administrative helpdesk for assistance.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.directions_walk),
                  label: const Text('Continue as Pilgrim'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
