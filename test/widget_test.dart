import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/app/app.dart';
import 'package:maza_pandurang/app/module_selector/module_selector_screen.dart';
import 'package:maza_pandurang/modules/dindi/repositories/in_memory_dindi_repository.dart';
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

  group('Maza Pandurang Root Auth Gate & Launcher Tests', () {
    testWidgets('App launches with AuthGate rendering LoginScreen when unauthenticated',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MazaPandurangApp());
      await tester.pump();
      await tester.pump();

      expect(find.text('माझा पांडुरंग'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('Development Module Selector renders module entries',
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
