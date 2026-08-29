import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_profile_screen.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_state_service.dart';

void main() {
  setUp(() {
    DindiStateService().resetDemoData();
  });

  group('Dindi Profile & Road Status — Phase 3 Tests', () {
    testWidgets(
        'DindiProfileScreen renders and populates with current Dindi information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiProfileScreen(),
        ),
      );

      // Verify title
      expect(find.text('Edit Dindi Information'), findsOneWidget);

      // Verify fields pre-populated with current values
      expect(find.text('Shree Tukaram Maharaj Dindi'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Sanket Patil'), findsOneWidget);
      expect(find.text('+91 98220 12345'), findsOneWidget);
      expect(find.text('Dehu'), findsOneWidget);
      expect(find.text('Pandharpur'), findsOneWidget);
      expect(find.text('Akurdi Vitthal Mandir'), findsOneWidget);
      expect(find.text('Clear & Moving'), findsWidgets);
    });

    testWidgets('Form rejects empty required fields with clear error messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiProfileScreen(),
        ),
      );

      // Clear the Dindi Name field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Shree Tukaram Maharaj Dindi'),
        '',
      );

      // Clear Current Halt
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Akurdi Vitthal Mandir'),
        '',
      );

      // Tap Save via AppBar
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Verify validation error messages
      expect(find.text('Please enter Dindi name'), findsOneWidget);
      expect(find.text('Please enter current halt location'), findsOneWidget);
    });

    testWidgets('Valid edits update DindiStateService and reflect on Dashboard',
        (WidgetTester tester) async {
      final service = DindiStateService();

      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );

      expect(find.text('Akurdi Vitthal Mandir'), findsOneWidget);
      expect(find.text('Clear & Moving'), findsOneWidget);

      // Tap on Edit Dindi Info in AppBar
      await tester.tap(find.byTooltip('Edit Dindi Info'));
      await tester.pumpAndSettle();

      expect(find.byType(DindiProfileScreen), findsOneWidget);

      // Update Current Halt to 'Pune Sangam'
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Akurdi Vitthal Mandir'),
        'Pune Sangam',
      );

      // Scroll to dropdown and open it
      await tester.scrollUntilVisible(
        find.byType(DropdownButtonFormField<String>),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select 'Crowded'
      await tester.tap(find.text('Crowded').last);
      await tester.pumpAndSettle();

      // Tap Save via AppBar
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Verify SnackBar confirmation and return to Dashboard
      expect(
          find.text('Dindi information updated successfully!'), findsOneWidget);
      expect(find.byType(DindiDashboardScreen), findsOneWidget);

      // Verify dashboard immediately reflects new halt & road status
      expect(find.text('Pune Sangam'), findsOneWidget);
      expect(find.text('Crowded'), findsOneWidget);

      // Verify service state directly
      expect(service.dindiGroup.currentHalt, 'Pune Sangam');
      expect(service.dindiGroup.roadStatus, 'Crowded');
    });

    testWidgets(
        'Tapping on Current Halt or Road Status card on Dashboard opens Profile Screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );

      // Tap Current Halt card
      await tester.tap(find.text('Current Halt'));
      await tester.pumpAndSettle();

      expect(find.byType(DindiProfileScreen), findsOneWidget);
    });
  });
}
