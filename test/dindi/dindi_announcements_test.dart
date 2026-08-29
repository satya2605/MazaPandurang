import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/repositories/in_memory_dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_announcements_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
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

  group('Dindi Announcements & Join Sharing — Phase 4 Tests', () {
    testWidgets(
        'DindiAnnouncementsScreen renders, displays join code and demo announcements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiAnnouncementsScreen(),
        ),
      );

      // Verify title & join code
      expect(find.text('Dindi Announcements'), findsOneWidget);
      expect(find.text('Join Code: TK12W4'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);

      // Verify pre-seeded demo announcements
      expect(find.text('Prasthan Timing at Akurdi'), findsOneWidget);
      expect(
        find.textContaining('All Dindi members must assemble'),
        findsOneWidget,
      );
      expect(find.text('URGENT'), findsOneWidget); // Urgent badge

      expect(find.text('Mahaprasad Arrangement'), findsOneWidget);
    });

    testWidgets(
        'Create-announcement modal validates required fields (title & message)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiAnnouncementsScreen(),
        ),
      );

      // Tap on FAB / New Announcement
      await tester.tap(find.text('New Announcement'));
      await tester.pumpAndSettle();

      // Verify create announcement sheet opens
      expect(find.text('Create Announcement'), findsOneWidget);

      // Tap publish without filling fields
      await tester.tap(find.text('Publish Announcement'));
      await tester.pumpAndSettle();

      // Verify validation error messages
      expect(find.text('Please enter announcement title'), findsOneWidget);
      expect(find.text('Please enter announcement message'), findsOneWidget);
    });

    testWidgets(
        'Publishing an announcement creates it, flags urgent correctly, and updates list',
        (WidgetTester tester) async {
      final service = DindiStateService();
      final initialCount = service.announcements.length;

      await tester.pumpWidget(
        const MaterialApp(
          home: DindiAnnouncementsScreen(),
        ),
      );

      // Tap on New Announcement
      await tester.tap(find.text('New Announcement'));
      await tester.pumpAndSettle();

      // Fill in title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Announcement Title *'),
        'Water Tanker Arrival',
      );

      // Fill in message
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message / Instructions *'),
        'Clean drinking water tanker has arrived near Mandir gate.',
      );

      // Toggle Urgent switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Tap Publish
      await tester.tap(find.text('Publish Announcement'));
      await tester.pumpAndSettle();

      // Verify SnackBar confirmation and modal closed
      expect(find.text('Announcement published successfully!'), findsOneWidget);
      expect(find.text('Create Announcement'), findsNothing);

      // Verify newly created announcement appears at the top
      expect(find.text('Water Tanker Arrival'), findsOneWidget);
      expect(find.textContaining('Clean drinking water tanker has arrived'),
          findsOneWidget);
      expect(find.text('Just now'), findsOneWidget);

      // Verify count in service
      expect(service.announcements.length, initialCount + 1);
      expect(service.announcements.first.isUrgent, true);
    });

    testWidgets(
        'Navigating from Dashboard to Announcements retains state across navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );

      // Verify latest announcement banner on dashboard
      expect(find.text('Dindi Announcements'), findsOneWidget);
      expect(find.text('Prasthan Timing at Akurdi'), findsOneWidget);

      // Tap View All
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.byType(DindiAnnouncementsScreen), findsOneWidget);

      // Go back to Dashboard
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(DindiDashboardScreen), findsOneWidget);
      expect(find.text('Prasthan Timing at Akurdi'), findsOneWidget);
    });

    testWidgets(
        'Join code copy action works and displays confirmation feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );

      // Tap copy button on join code card
      await tester.tap(find.text('Copy').first);
      await tester.pumpAndSettle();

      expect(
          find.text('Join Code "TK12W4" copied to clipboard!'), findsOneWidget);
    });
  });
}
