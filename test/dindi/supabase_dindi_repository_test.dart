import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_group.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_member.dart';
import 'package:maza_pandurang/modules/dindi/repositories/supabase_dindi_repository.dart';

void main() {
  group('SupabaseDindiRepository Unit Tests (Mock HTTP)', () {
    const leaderId = '00000000-0000-0000-0000-000000000002';
    const dindiId = '00000000-0000-0000-0000-000000000010';

    test('getDindis sends leader_id filter and parses response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/dindis'));
        expect(request.url.queryParameters['leader_id'], equals(leaderId));

        final responsePayload = [
          {
            'id': '00000000-0000-0000-0000-000000000010',
            'name': 'Shree Tukaram Maharaj Dindi',
            'dindiNumber': '12',
            'leaderName': 'Sanket Patil',
            'leaderPhone': '+91 98220 12345',
            'startPoint': 'Dehu',
            'destination': 'Pandharpur',
            'currentHalt': 'Akurdi Vitthal Mandir',
            'roadStatus': 'Clear & Moving',
            'joinCode': 'TK12W4',
            'leaderUserId': leaderId,
            'status': 'Active',
          },
          {
            'id': '00000000-0000-0000-0000-000000000011',
            'name': 'Shree Dnyaneshwar Maharaj Dindi No. 18',
            'dindiNumber': '18',
            'leaderName': 'Sanket Patil',
            'leaderPhone': '+91 98220 12345',
            'startPoint': 'Alandi',
            'destination': 'Pandharpur',
            'currentHalt': 'Saswad Sangam',
            'roadStatus': 'Slow',
            'joinCode': 'DN18W4',
            'leaderUserId': leaderId,
            'status': 'Halted',
          }
        ];

        return http.Response(
          json.encode(responsePayload),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final dindis = await repo.getDindis(leaderUserId: leaderId);

      expect(dindis.length, equals(2));
      expect(dindis[0].id, equals('00000000-0000-0000-0000-000000000010'));
      expect(dindis[0].dindiNumber, equals('12'));
      expect(dindis[0].status, equals('Active'));
      expect(dindis[1].id, equals('00000000-0000-0000-0000-000000000011'));
      expect(dindis[1].dindiNumber, equals('18'));
      expect(dindis[1].status, equals('Halted'));
    });

    test('getDindiById returns Dindi when found', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path,
            equals('/api/dindis/00000000-0000-0000-0000-000000000010'));

        return http.Response(
          json.encode({
            'id': '00000000-0000-0000-0000-000000000010',
            'name': 'Shree Tukaram Maharaj Dindi',
            'dindiNumber': '12',
            'leaderName': 'Sanket Patil',
            'leaderPhone': '+91 98220 12345',
            'startPoint': 'Dehu',
            'destination': 'Pandharpur',
            'currentHalt': 'Akurdi Vitthal Mandir',
            'roadStatus': 'Clear & Moving',
            'joinCode': 'TK12W4',
            'leaderUserId': leaderId,
            'status': 'Active',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final dindi =
          await repo.getDindiById('00000000-0000-0000-0000-000000000010');

      expect(dindi, isNotNull);
      expect(dindi!.name, equals('Shree Tukaram Maharaj Dindi'));
      expect(dindi.dindiNumber, equals('12'));
      expect(dindi.status, equals('Active'));
    });

    test('getDindiById returns null when HTTP 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'error': {'message': 'Dindi not found'}
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final dindi = await repo.getDindiById('non-existent-id');
      expect(dindi, isNull);
    });

    test('createDindi posts payload without leader_id and returns created record',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, equals('/api/dindis'));

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['name'], equals('New Sant Dindi'));
        expect(body['dindiNumber'], equals('99'));
        expect(body['status'], equals('Active'));
        // Verify leader_id is not sent in client payload
        expect(body.containsKey('leader_id'), isFalse);
        expect(body.containsKey('leaderUserId'), isFalse);

        return http.Response(
          json.encode({
            'id': '00000000-0000-0000-0000-000000000099',
            'name': 'New Sant Dindi',
            'dindiNumber': '99',
            'leaderName': 'Sanket Patil',
            'leaderPhone': '+91 98220 12345',
            'startPoint': 'Alandi',
            'destination': 'Pandharpur',
            'currentHalt': 'Pune',
            'roadStatus': 'Clear & Moving',
            'joinCode': 'NEW999',
            'leaderUserId': leaderId,
            'status': 'Active',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      const newGroup = DindiGroup(
        id: '',
        name: 'New Sant Dindi',
        dindiNumber: '99',
        leaderName: 'Sanket Patil',
        leaderPhone: '+91 98220 12345',
        startPoint: 'Alandi',
        destination: 'Pandharpur',
        currentHalt: 'Pune',
        roadStatus: 'Clear & Moving',
        joinCode: 'NEW999',
        leaderUserId: leaderId,
        status: 'Active',
      );

      final created = await repo.createDindi(newGroup);

      expect(created.id, equals('00000000-0000-0000-0000-000000000099'));
      expect(created.name, equals('New Sant Dindi'));
      expect(created.joinCode, equals('NEW999'));
      expect(created.status, equals('Active'));
    });

    test('updateDindi uses PATCH (NOT PUT) and sends status and roadStatus',
        () async {
      final mockClient = MockClient((request) async {
        // Must be PATCH per shared API contract
        expect(request.method, equals('PATCH'));
        expect(request.url.path,
            equals('/api/dindis/00000000-0000-0000-0000-000000000010'));

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['status'], equals('Halted'));
        expect(body['roadStatus'], equals('Slow'));
        expect(body.containsKey('leader_id'), isFalse);
        expect(body.containsKey('leaderUserId'), isFalse);

        return http.Response(
          json.encode({
            'id': '00000000-0000-0000-0000-000000000010',
            'name': 'Updated Dindi Name',
            'dindiNumber': '12',
            'leaderName': 'Sanket Patil',
            'leaderPhone': '+91 98220 12345',
            'startPoint': 'Dehu',
            'destination': 'Pandharpur',
            'currentHalt': 'Saswad Ground',
            'roadStatus': 'Slow',
            'joinCode': 'TK12W4',
            'leaderUserId': leaderId,
            'status': 'Halted',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      const updatedGroup = DindiGroup(
        id: '00000000-0000-0000-0000-000000000010',
        name: 'Updated Dindi Name',
        dindiNumber: '12',
        leaderName: 'Sanket Patil',
        leaderPhone: '+91 98220 12345',
        startPoint: 'Dehu',
        destination: 'Pandharpur',
        currentHalt: 'Saswad Ground',
        roadStatus: 'Slow',
        joinCode: 'TK12W4',
        leaderUserId: leaderId,
        status: 'Halted',
      );

      final result = await repo.updateDindi(updatedGroup);

      expect(result.currentHalt, equals('Saswad Ground'));
      expect(result.roadStatus, equals('Slow'));
      expect(result.status, equals('Halted'));
    });

    // ----------------------------------------------------
    // Member Management REST Tests
    // ----------------------------------------------------
    test('getMembers queries /api/dindis/:id/members and parses joined profiles',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, equals('/api/dindis/$dindiId/members'));

        final responsePayload = [
          {
            'id': '00000000-0000-0000-0000-000000000020',
            'pilgrim_id': '00000000-0000-0000-0000-000000000001',
            'dindi_id': dindiId,
            'status': 'active',
            'role': 'Taalvadak (टाळकरी)',
            'requested_at': '2026-08-27T12:00:00.000Z',
            'joined_at': '2026-08-28T12:00:00.000Z',
            'profiles': {
              'display_name': 'Satyajit (Pilgrim Lead)',
              'phone': '+919876543210',
              'email': 'satyajit@mazapandurang.org',
            },
          },
          {
            'id': '00000000-0000-0000-0000-000000000021',
            'pilgrim_id': '00000000-0000-0000-0000-000000000005',
            'dindi_id': dindiId,
            'status': 'pending',
            'role': 'Warkari',
            'requested_at': '2026-08-29T08:00:00.000Z',
            'profiles': {
              'display_name': 'Gauri (Citizen)',
              'phone': '+919876543214',
            },
          }
        ];

        return http.Response(
          json.encode(responsePayload),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      final members = await repo.getMembers(dindiId);

      expect(members.length, equals(2));
      expect(members[0].id, equals('00000000-0000-0000-0000-000000000020'));
      expect(members[0].name, equals('Satyajit (Pilgrim Lead)'));
      expect(members[0].phone, equals('+919876543210'));
      expect(members[0].status, equals(DindiMemberStatus.approved));

      expect(members[1].id, equals('00000000-0000-0000-0000-000000000021'));
      expect(members[1].name, equals('Gauri (Citizen)'));
      expect(members[1].status, equals(DindiMemberStatus.pending));
    });

    test('updateMemberStatus patches /api/dindi-memberships/:id with active',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('PATCH'));
        expect(request.url.path,
            equals('/api/dindi-memberships/00000000-0000-0000-0000-000000000021'));

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['status'], equals('active'));

        return http.Response(
          json.encode({
            'id': '00000000-0000-0000-0000-000000000021',
            'status': 'active',
            'updated_at': DateTime.now().toIso8601String(),
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      await repo.updateMemberStatus(
        '00000000-0000-0000-0000-000000000021',
        DindiMemberStatus.approved,
      );
    });

    test('removeMember patches /api/dindi-memberships/:id with rejected',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('PATCH'));
        expect(request.url.path,
            equals('/api/dindi-memberships/00000000-0000-0000-0000-000000000021'));

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['status'], equals('rejected'));

        return http.Response(
          json.encode({
            'id': '00000000-0000-0000-0000-000000000021',
            'status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      await repo.removeMember('00000000-0000-0000-0000-000000000021');
    });

    test(
        'does NOT silently fallback on API error; throws DindiRepositoryException',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'error': {'message': 'Database connection timeout'}
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      expect(
        () => repo.getDindis(leaderUserId: leaderId),
        throwsA(isA<DindiRepositoryException>()),
      );

      expect(
        () => repo.getMembers(dindiId),
        throwsA(isA<DindiRepositoryException>()),
      );
    });

    test(
        'throws DindiRepositoryException on 409 conflict when creating duplicate',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'error': {
              'message':
                  'Dindi Number already exists. Please choose a unique value.'
            }
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = SupabaseDindiRepository(
        baseUrl: 'http://localhost:3000',
        client: mockClient,
      );

      const duplicate = DindiGroup(
        id: '',
        name: 'Duplicate Dindi',
        dindiNumber: '12',
        leaderName: 'Sanket Patil',
        leaderPhone: '+91 98220 12345',
        startPoint: 'Dehu',
        destination: 'Pandharpur',
        currentHalt: 'Akurdi',
        roadStatus: 'Clear',
        joinCode: 'TK12W4',
        leaderUserId: leaderId,
        status: 'Active',
      );

      expect(
        () => repo.createDindi(duplicate),
        throwsA(
          predicate<DindiRepositoryException>(
            (e) =>
                e.statusCode == 409 &&
                e.message.contains('Dindi Number already exists'),
          ),
        ),
      );
    });
  });
}
