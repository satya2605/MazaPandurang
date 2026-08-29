import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/app/app.dart';
import 'package:maza_pandurang/app/module_selector/module_selector_screen.dart';

void main() {
  group('Maza Pandurang Role Selector Tests', () {
    testWidgets('App launches and renders Role Selector screen with 5 roles',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MazaPandurangApp());

      expect(find.text('Maza Pandurang'), findsOneWidget);
      expect(find.text('Select Your Role'), findsOneWidget);
      expect(find.text('Personalise your Wari experience'), findsOneWidget);

      expect(find.text('Pilgrim'), findsOneWidget);
      expect(find.text('Dindi Leader'), findsOneWidget);
      expect(find.text('NGO Volunteer'), findsOneWidget);
      expect(find.text('Police / Authority'), findsOneWidget);
      expect(find.text('Local Citizen'), findsOneWidget);

      expect(find.text('Continue as Pilgrim'), findsOneWidget);
    });

    testWidgets('Role selection updates active role button text and navigates',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MazaPandurangApp());

      // Tap on Dindi Leader role
      await tester.tap(find.text('Dindi Leader'));
      await tester.pumpAndSettle();

      expect(find.text('Continue as Dindi Leader'), findsOneWidget);

      // Continue to Dindi Module
      await tester.tap(find.text('Continue as Dindi Leader'));
      await tester.pumpAndSettle();

      expect(find.text('Dindi Leader Module'), findsWidgets);
      expect(find.text('Module initialized successfully.'), findsOneWidget);
    });

    testWidgets('Development Module Selector renders all 5 modules',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ModuleSelectorScreen(),
        ),
      );

      expect(find.text('Maza Pandurang Modules'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Owner: Shrutika'),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Owner: Shrutika'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Owner: Gauri'),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Owner: Gauri'), findsOneWidget);
    });
  });
}
