import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/repositories/in_memory_dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/my_dindis_screen.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_identity_provider.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_state_service.dart';

void main() {
  late DindiStateService service;

  setUp(() async {
    InMemoryDindiRepository.instance.reset();
    service = DindiStateService(
      repository: InMemoryDindiRepository.instance,
      identityProvider: const DevDindiIdentityProvider(),
    );
    service.resetState();
    await service.loadDindis();
  });

  group('Multi-Dindi Selection & State Isolation Tests', () {
    test('selecting Dindi A then Dindi B switches active state completely', () {
      // Initially select Dindi 12
      service.selectDindi('dindi-12');
      expect(service.selectedDindiId, equals('dindi-12'));
      expect(service.dindiGroup.name, equals('Shree Tukaram Maharaj Dindi'));
      expect(service.dindiGroup.dindiNumber, equals('12'));
      expect(service.dindiGroup.currentHalt, equals('Akurdi Vitthal Mandir'));
      expect(service.dindiGroup.roadStatus, equals('Clear & Moving'));
      expect(service.dindiGroup.joinCode, equals('TK12W4'));

      // Switch to Dindi 18
      service.selectDindi('dindi-18');
      expect(service.selectedDindiId, equals('dindi-18'));
      expect(service.dindiGroup.name,
          equals('Shree Dnyaneshwar Maharaj Dindi No. 18'));
      expect(service.dindiGroup.dindiNumber, equals('18'));
      expect(service.dindiGroup.currentHalt, equals('Saswad Sangam'));
      expect(service.dindiGroup.roadStatus, equals('Slow'));
      expect(service.dindiGroup.joinCode, equals('DN18W4'));
    });

    test('modifying Dindi A does not affect Dindi B (Strict Isolation)',
        () async {
      service.selectDindi('dindi-12');

      // Update Dindi 12 profile and road status
      await service.updateDindiProfile(
        name: 'Updated Dindi 12 Name',
        dindiNumber: '12-NEW',
        startPoint: 'Dehu Gaon',
        destination: 'Pandharpur Dham',
        currentHalt: 'Pune Central Station',
        roadStatus: 'Crowded',
      );

      // Verify Dindi 12 updated
      expect(service.dindiGroup.name, equals('Updated Dindi 12 Name'));
      expect(service.dindiGroup.dindiNumber, equals('12-NEW'));
      expect(service.dindiGroup.currentHalt, equals('Pune Central Station'));
      expect(service.dindiGroup.roadStatus, equals('Crowded'));

      // Switch to Dindi 18 and verify Dindi 18 is completely untouched
      service.selectDindi('dindi-18');
      expect(service.dindiGroup.name,
          equals('Shree Dnyaneshwar Maharaj Dindi No. 18'));
      expect(service.dindiGroup.dindiNumber, equals('18'));
      expect(service.dindiGroup.currentHalt, equals('Saswad Sangam'));
      expect(service.dindiGroup.roadStatus, equals('Slow'));
      expect(service.dindiGroup.startPoint, equals('Alandi'));
      expect(service.dindiGroup.destination, equals('Pandharpur'));
    });

    testWidgets(
        'Switch Dindi navigation action from Dashboard navigates back to MyDindisScreen',
        (WidgetTester tester) async {
      service.selectDindi('dindi-12');

      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shree Tukaram Maharaj Dindi'), findsOneWidget);

      // Tap Switch Dindi icon in AppBar
      await tester.tap(find.byTooltip('My Dindis / Switch Dindi'));
      await tester.pumpAndSettle();

      // Verify MyDindisScreen opened
      expect(find.byType(MyDindisScreen), findsOneWidget);
      expect(find.text('My Dindis'), findsOneWidget);
      expect(
          find.text('Shree Dnyaneshwar Maharaj Dindi No. 18'), findsOneWidget);

      // Tap Dindi 18
      await tester.tap(find.text('Shree Dnyaneshwar Maharaj Dindi No. 18'));
      await tester.pumpAndSettle();

      // Verify dashboard switched to Dindi 18
      expect(find.byType(DindiDashboardScreen), findsOneWidget);
      expect(
          find.text('Shree Dnyaneshwar Maharaj Dindi No. 18'), findsOneWidget);
      expect(
          find.text('Dindi No. 18 • Leader: Sanket Patil'), findsOneWidget);
      expect(find.text('Saswad Sangam'), findsOneWidget);
    });
  });
}
