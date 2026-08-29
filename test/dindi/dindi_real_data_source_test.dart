import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:maza_pandurang/modules/dindi/repositories/supabase_dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/my_dindis_screen.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_identity_provider.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_state_service.dart';

void main() {
  group('Real Database Source of Truth & Zero-Fake-Data Regression Tests', () {
    const leaderId = '00000000-0000-0000-0000-000000000002';

    test('1. Empty API response does NOT produce demo Dindi data', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final service = DindiStateService(
        repository: repo,
        identityProvider: const DevDindiIdentityProvider(),
      );
      service.resetState();

      await service.loadDindis();

      expect(service.dindis, isEmpty);
      expect(service.selectedDindiId, isNull);
      expect(service.dindiGroup.name, equals(''));
      expect(service.dindiGroup.joinCode, equals(''));
    });

    testWidgets('2. Empty API response produces an empty state in MyDindisScreen',
        (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final service = DindiStateService(
        repository: repo,
        identityProvider: const DevDindiIdentityProvider(),
      );
      service.resetState();

      await tester.pumpWidget(
        const MaterialApp(
          home: MyDindisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Dindis Registered Yet'), findsOneWidget);
      expect(find.text('Register New Dindi'), findsOneWidget);
      // Ensure no demo dindi names appear
      expect(find.text('Shree Tukaram Maharaj Dindi'), findsNothing);
      expect(find.text('TK12W4'), findsNothing);
    });

    testWidgets('3. Empty API response produces an empty state in DindiDashboardScreen',
        (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final service = DindiStateService(
        repository: repo,
        identityProvider: const DevDindiIdentityProvider(),
      );
      service.resetState();

      await tester.pumpWidget(
        const MaterialApp(
          home: DindiDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Dindis Found'), findsOneWidget);
      expect(find.text('Create New Dindi'), findsOneWidget);
      expect(find.text('TK12W4'), findsNothing);
      expect(find.text('42'), findsNothing);
    });

    test('4. Empty members response does NOT produce fake member counts', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/dindis') {
          return http.Response(
            json.encode([
              {
                'id': 'dindi-test-1',
                'name': 'Live DB Dindi',
                'dindiNumber': '01',
                'leaderName': 'Leader One',
                'leaderPhone': '+91 99999 00001',
                'startPoint': 'Alandi',
                'destination': 'Pandharpur',
                'currentHalt': 'Pune',
                'roadStatus': 'Clear & Moving',
                'joinCode': 'LIVE01',
                'leaderUserId': leaderId,
                'status': 'Active',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.contains('/members')) {
          // Zero members in DB
          return http.Response(json.encode([]), 200,
              headers: {'content-type': 'application/json'});
        }
        return http.Response(json.encode([]), 200);
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final service = DindiStateService(
        repository: repo,
        identityProvider: const DevDindiIdentityProvider(),
      );
      service.resetState();

      await service.loadDindis();

      expect(service.totalMemberCount, equals(0));
      expect(service.pendingRequestCount, equals(0));
      expect(service.members, isEmpty);
      expect(service.activeMembers, isEmpty);
      expect(service.pendingMembers, isEmpty);
    });

    test('5. API failure surfaces exception and does NOT inject fallback data', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final service = DindiStateService(
        repository: repo,
        identityProvider: const DevDindiIdentityProvider(),
      );
      service.resetState();

      expect(() => service.loadDindis(), throwsA(isA<DindiRepositoryException>()));
      expect(service.dindis, isEmpty);
      expect(service.members, isEmpty);
    });

    test('6. Real API response is rendered exactly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/dindis') {
          return http.Response(
            json.encode([
              {
                'id': 'dindi-real-99',
                'name': 'Authentic Sant Tukaram Dindi',
                'dindiNumber': 'DND-99',
                'leaderName': 'Real Leader',
                'leaderPhone': '+91 98765 43210',
                'startPoint': 'Dehu Mandir',
                'destination': 'Pandharpur Vitthal Mandir',
                'currentHalt': 'Diva Ghat',
                'roadStatus': 'Slow',
                'joinCode': 'REAL99',
                'leaderUserId': leaderId,
                'status': 'Active',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.contains('/members')) {
          return http.Response(
            json.encode([
              {
                'id': 'm-1',
                'dindiId': 'dindi-real-99',
                'name': 'Real Varkari 1',
                'phone': '+91 90000 00001',
                'role': 'Taalvadak',
                'status': 'active',
              },
              {
                'id': 'm-2',
                'dindiId': 'dindi-real-99',
                'name': 'Pending Applicant 2',
                'phone': '+91 90000 00002',
                'role': 'Warkari',
                'status': 'pending',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(json.encode([]), 200);
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final service = DindiStateService(
        repository: repo,
        identityProvider: const DevDindiIdentityProvider(),
      );
      service.resetState();

      await service.loadDindis();

      expect(service.dindis.length, equals(1));
      expect(service.dindiGroup.name, equals('Authentic Sant Tukaram Dindi'));
      expect(service.dindiGroup.joinCode, equals('REAL99'));
      expect(service.dindiGroup.currentHalt, equals('Diva Ghat'));
      expect(service.totalMemberCount, equals(1));
      expect(service.pendingRequestCount, equals(1));
      expect(service.activeMembers.first.name, equals('Real Varkari 1'));
      expect(service.pendingMembers.first.name, equals('Pending Applicant 2'));
    });
  });
}
