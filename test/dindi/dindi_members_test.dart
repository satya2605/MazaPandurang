import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/repositories/in_memory_dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_members_screen.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_identity_provider.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_state_service.dart';

void main() {
  setUp(() async {
    InMemoryDindiRepository.instance.reset();
    final service = DindiStateService(
      repository: InMemoryDindiRepository.instance,
      identityProvider: const DevDindiIdentityProvider(),
    );
    service.resetState();
    await service.loadDindis();
  });

  group('Dindi Member Management — Phase 2 Tests', () {
    testWidgets(
        'DindiMembersScreen renders pending requests and active members tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiMembersScreen(),
        ),
      );

      // Verify title & tabs
      expect(find.text('Dindi Members Management'), findsOneWidget);
      expect(find.text('Pending Requests (5)'), findsOneWidget);
      expect(find.text('Active Members (128)'), findsOneWidget);

      // Verify pending member tile is visible
      expect(find.text('Tukaram Shinde'), findsOneWidget);
      expect(find.text('Taalvadak (टाळकरी)'), findsOneWidget);
      expect(find.text('Approve'), findsWidgets);
      expect(find.text('Reject'), findsWidgets);

      // Switch to Active Members tab
      await tester.tap(find.text('Active Members (128)'));
      await tester.pumpAndSettle();

      expect(find.text('Ramesh Patil'), findsOneWidget);
      expect(find.text('Suresh Deshmukh'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
    });

    testWidgets('Approving a pending request updates counts and active list',
        (WidgetTester tester) async {
      final service = DindiStateService();
      expect(service.pendingRequestCount, 5);
      expect(service.totalMemberCount, 128);

      await tester.pumpWidget(
        const MaterialApp(
          home: DindiMembersScreen(),
        ),
      );

      // Tap Approve on the first pending member (Tukaram Shinde)
      await tester.tap(find.text('Approve').first);
      await tester.pumpAndSettle();

      // Verify SnackBar confirmation
      expect(find.text('Tukaram Shinde approved as active member!'),
          findsOneWidget);

      // Verify updated counts in tab headers
      expect(find.text('Pending Requests (4)'), findsOneWidget);
      expect(find.text('Active Members (129)'), findsOneWidget);
      expect(service.pendingRequestCount, 4);
      expect(service.totalMemberCount, 129);

      // Switch to Active tab and verify Tukaram Shinde is now active
      await tester.tap(find.text('Active Members (129)'));
      await tester.pumpAndSettle();

      expect(find.text('Tukaram Shinde'), findsOneWidget);
    });

    testWidgets(
        'Rejecting a pending request removes it without increasing active count',
        (WidgetTester tester) async {
      final service = DindiStateService();
      expect(service.pendingRequestCount, 5);
      expect(service.totalMemberCount, 128);

      await tester.pumpWidget(
        const MaterialApp(
          home: DindiMembersScreen(),
        ),
      );

      // Tap Reject on first pending request
      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Verify SnackBar confirmation
      expect(
          find.text('Request from Tukaram Shinde rejected.'), findsOneWidget);

      // Verify updated counts
      expect(find.text('Pending Requests (4)'), findsOneWidget);
      expect(find.text('Active Members (128)'), findsOneWidget);
      expect(service.pendingRequestCount, 4);
      expect(service.totalMemberCount, 128);
    });

    testWidgets(
        'Navigating from Dashboard to Members screen and approving reflects on Dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );

      expect(find.text('Pending Requests'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);

      // Tap on Member Management in AppBar to navigate to Members screen
      await tester.tap(find.byTooltip('Member Management'));
      await tester.pumpAndSettle();

      expect(find.byType(DindiMembersScreen), findsOneWidget);

      // Approve Tukaram Shinde
      await tester.tap(find.text('Approve').first);
      await tester.pumpAndSettle();

      // Navigate back to Dashboard
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Dashboard counts must immediately reflect changes
      expect(find.text('4'), findsOneWidget); // Pending requests = 4
      expect(find.text('129'), findsOneWidget); // Total members = 129
    });

    testWidgets('Empty states render properly when lists are empty',
        (WidgetTester tester) async {
      final service = DindiStateService();
      // Reject all pending members
      while (service.pendingMembers.isNotEmpty) {
        service.rejectMember(service.pendingMembers.first.id);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: DindiMembersScreen(),
        ),
      );

      expect(find.text('No pending join requests'), findsOneWidget);
      expect(find.text('All member join requests have been reviewed.'),
          findsOneWidget);
    });
  });
}
