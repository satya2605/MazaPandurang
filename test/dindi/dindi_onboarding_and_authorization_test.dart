import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/core/auth/auth_service.dart';
import 'package:maza_pandurang/modules/dindi/dindi_module.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_gatekeeper_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_leader_apply_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_pending_approval_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_suspended_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/my_dindis_screen.dart';

void main() {
  final authService = AuthService();

  setUp(() {
    authService.signOut();
  });

  group('Dindi Leader Onboarding & Authorization Gatekeeping Tests', () {
    testWidgets('Unregistered / Pilgrim user sees DindiLeaderApplyScreen',
        (WidgetTester tester) async {
      // Simulate normal pilgrim user
      authService.setCurrentProfile({
        'id': '00000000-0000-0000-0000-000000000001',
        'display_name': 'Satyajit Pilgrim',
        'email': 'satyajit@mazapandurang.local',
        'role': 'pilgrim',
        'status': 'active',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: DindiModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DindiGatekeeperScreen), findsOneWidget);
      expect(find.byType(DindiLeaderApplyScreen), findsOneWidget);
      expect(find.text('Apply as Dindi Leader'), findsOneWidget);
      expect(find.text('Submit Application to Admin'), findsOneWidget);
    });

    testWidgets('Pending Dindi Leader sees DindiPendingApprovalScreen with locked controls',
        (WidgetTester tester) async {
      // Simulate pending Dindi Leader
      authService.setCurrentProfile({
        'id': '00000000-0000-0000-0000-000000000002',
        'display_name': 'Sanket Patil',
        'email': 'sanket@mazapandurang.local',
        'role': 'dindi_leader',
        'status': 'pending',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: DindiModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DindiPendingApprovalScreen), findsOneWidget);
      expect(find.text('Awaiting Admin Approval'), findsOneWidget);
      expect(find.text('Check Approval Status'), findsOneWidget);
      expect(find.text('Continue as Pilgrim'), findsOneWidget);
      // Dindi management screens are locked
      expect(find.byType(MyDindisScreen), findsNothing);
    });

    testWidgets('Suspended Dindi Leader sees DindiSuspendedScreen with locked controls',
        (WidgetTester tester) async {
      // Simulate suspended Dindi Leader
      authService.setCurrentProfile({
        'id': '00000000-0000-0000-0000-000000000002',
        'display_name': 'Sanket Patil',
        'email': 'sanket@mazapandurang.local',
        'role': 'dindi_leader',
        'status': 'suspended',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: DindiModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DindiSuspendedScreen), findsOneWidget);
      expect(find.text('Dindi Leader Privileges Suspended'), findsOneWidget);
      expect(find.byType(MyDindisScreen), findsNothing);
    });

    testWidgets('Active approved Dindi Leader sees MyDindisScreen with full management',
        (WidgetTester tester) async {
      // Simulate active approved Dindi Leader
      authService.setCurrentProfile({
        'id': '00000000-0000-0000-0000-000000000002',
        'display_name': 'Sanket Patil',
        'email': 'sanket@mazapandurang.local',
        'role': 'dindi_leader',
        'status': 'active',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: DindiModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MyDindisScreen), findsOneWidget);
      expect(find.text('My Dindis'), findsOneWidget);
    });
  });
}
