import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/screens/pilgrim_home_screen.dart';

void main() {
  group('PilgrimHomeScreen Widget Tests', () {
    testWidgets('Renders Top Bar, Map Canvas, and 5 Bottom Navigation Actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PilgrimHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Maza Pandurang'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);

      expect(find.text('Palkhi'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Tilak AI'), findsOneWidget);
      expect(find.text('Bhakti'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
    });

    testWidgets('Tapping Palkhi tab opens Palkhi tracking view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PilgrimHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Palkhi'));
      await tester.pumpAndSettle();

      expect(find.text('Palkhi Live Track (पालखी)'), findsOneWidget);
      expect(find.text('Sant Dnyaneshwar Maharaj Palkhi'), findsWidgets);
    });

    testWidgets('Tapping Services tab opens Services discovery view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PilgrimHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();

      expect(find.text('Wari Seva Services (सेवा सुविधा)'), findsOneWidget);
      expect(find.text('SRV-MED-001'), findsOneWidget);
    });

    testWidgets('Tapping Bhakti tab opens Bhakti streaming view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PilgrimHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bhakti'));
      await tester.pumpAndSettle();

      expect(find.text('Bhakti Streaming (भक्ती संगीत)'), findsOneWidget);
      expect(find.text('Abhang'), findsOneWidget);
    });

    testWidgets('Tapping Help tab opens Emergency & Help view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PilgrimHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Help'));
      await tester.pumpAndSettle();

      expect(find.text('Emergency & Safety (आपत्कालीन सेवा)'), findsOneWidget);
      expect(find.text('Select Emergency Assistance Type'), findsOneWidget);
    });

    testWidgets('Tapping Tilak AI opens Tilak AI modal assistant',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PilgrimHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tilak AI'));
      await tester.pumpAndSettle();

      expect(find.text('Tilak AI Assistant'), findsOneWidget);
      expect(find.textContaining('Where is the Palkhi right now?'), findsOneWidget);
    });
  });
}
