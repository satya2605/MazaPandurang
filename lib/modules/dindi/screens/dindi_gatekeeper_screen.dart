import 'package:flutter/material.dart';
import '../../../core/auth/auth_service.dart';
import 'dindi_leader_apply_screen.dart';
import 'dindi_pending_approval_screen.dart';
import 'dindi_suspended_screen.dart';
import 'my_dindis_screen.dart';

/// Intelligent gatekeeper that enforces Dindi Leader onboarding and lifecycle status.
class DindiGatekeeperScreen extends StatelessWidget {
  const DindiGatekeeperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, _) {
        final profile = AuthService().currentProfile;

        // If no authenticated profile exists in session, check dev fallback
        if (profile == null) {
          // In standalone development / testing, open MyDindisScreen directly
          return const MyDindisScreen();
        }

        final role = profile['role']?.toString();
        final status = profile['status']?.toString() ?? 'active';

        // 1. If user has applied as Dindi Leader and status is pending
        if (role == 'dindi_leader' && status == 'pending') {
          return const DindiPendingApprovalScreen();
        }

        // 2. If user is suspended
        if (status == 'suspended') {
          return const DindiSuspendedScreen();
        }

        // 3. If user is an active Dindi Leader (or admin)
        if (role == 'dindi_leader' || role == 'admin') {
          return const MyDindisScreen();
        }

        // 4. If normal user/pilgrim wants to become a Dindi Leader
        return const DindiLeaderApplyScreen();
      },
    );
  }
}
