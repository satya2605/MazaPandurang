import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/dindi_module.dart';
import 'package:maza_pandurang/modules/dindi/repositories/in_memory_dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_gatekeeper_screen.dart';
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

  group('Dindi Leader Dashboard — Phase 1 & 7A Entry Tests', () {
    testWidgets('DindiModule.screen() renders DindiGatekeeperScreen as entry point',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DindiModule.screen(),
        ),
      );

      // Verify DindiGatekeeperScreen is the module entry point
      expect(find.byType(DindiGatekeeperScreen), findsOneWidget);
    });

    testWidgets(
        'DindiDashboardScreen renders with all required fields for active Dindi',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );

      // Verify dashboard screen type
      expect(find.byType(DindiDashboardScreen), findsOneWidget);

      // Verify AppBar title
      expect(find.text('Dindi Leader Dashboard'), findsOneWidget);

      // Verify Dindi name & number
      expect(find.text('Shree Tukaram Maharaj Dindi'), findsOneWidget);
      expect(find.textContaining('Dindi No. 12'), findsOneWidget);
      expect(find.textContaining('Leader: Sanket Patil'), findsOneWidget);

      // Verify Route endpoints
      expect(find.text('Route: Dehu ➔ Pandharpur'), findsOneWidget);

      // Verify Join Code
      expect(find.text('TK12W4'), findsOneWidget);
      expect(find.text('DINDI JOIN CODE'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);

      // Verify Current Halt & Road Status
      expect(find.text('Current Halt'), findsOneWidget);
      expect(find.text('Akurdi Vitthal Mandir'), findsOneWidget);
      expect(find.text('Road Status'), findsOneWidget);
      expect(find.text('Clear & Moving'), findsOneWidget);

      // Verify Member metrics
      expect(find.text('Total Members'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('Pending Requests'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    test('DindiStateService loads repository data properly', () async {
      final service = DindiStateService(
        repository: InMemoryDindiRepository.instance,
      );
      service.resetState();
      await service.loadDindis();
      expect(service.dindiGroup.name, 'Shree Tukaram Maharaj Dindi');
      expect(service.dindiGroup.dindiNumber, '12');
      expect(service.dindiGroup.leaderName, 'Sanket Patil');
      expect(service.dindiGroup.joinCode, 'TK12W4');
      expect(service.dindiGroup.currentHalt, 'Akurdi Vitthal Mandir');
      expect(service.dindiGroup.roadStatus, 'Clear & Moving');
      expect(service.totalMemberCount, 128);
      expect(service.pendingRequestCount, 5);
      expect(service.announcements.length, 2);
    });
  });
}
