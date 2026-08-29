import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_member.dart';

void main() {
  group('DindiMember Serialization Tests', () {
    test('parses canonical Supabase join response with profiles correctly', () {
      final jsonPayload = {
        'id': '00000000-0000-0000-0000-000000000020',
        'pilgrim_id': '00000000-0000-0000-0000-000000000001',
        'dindi_id': '00000000-0000-0000-0000-000000000010',
        'status': 'active',
        'role': 'warkari',
        'requested_at': '2026-08-27T12:00:00.000Z',
        'joined_at': '2026-08-28T12:00:00.000Z',
        'profiles': {
          'display_name': 'Satyajit (Pilgrim Lead)',
          'phone': '+919876543210',
          'email': 'satyajit@mazapandurang.org',
        },
      };

      final member = DindiMember.fromJson(jsonPayload);

      expect(member.id, equals('00000000-0000-0000-0000-000000000020'));
      expect(member.dindiId, equals('00000000-0000-0000-0000-000000000010'));
      expect(member.name, equals('Satyajit (Pilgrim Lead)'));
      expect(member.phone, equals('+919876543210'));
      expect(member.role, equals('warkari'));
      expect(member.status, equals(DindiMemberStatus.approved));
      expect(member.joinedAt, equals(DateTime.parse('2026-08-28T12:00:00.000Z')));
    });

    test('parses pending request without joined profile with fallback name', () {
      final jsonPayload = {
        'id': '00000000-0000-0000-0000-000000000025',
        'dindi_id': '00000000-0000-0000-0000-000000000010',
        'status': 'pending',
        'role': 'Taalvadak (टाळकरी)',
        'requested_at': '2026-08-29T10:00:00.000Z',
      };

      final member = DindiMember.fromJson(jsonPayload);

      expect(member.id, equals('00000000-0000-0000-0000-000000000025'));
      expect(member.status, equals(DindiMemberStatus.pending));
      expect(member.role, equals('Taalvadak (टाळकरी)'));
      expect(member.name, equals('Warkari Pilgrim'));
    });

    test('serializes DindiMember to JSON correctly', () {
      final member = DindiMember(
        id: 'mem-101',
        dindiId: 'dindi-99',
        name: 'Ganesh More',
        phone: '+91 94230 78901',
        role: 'Warkari',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.parse('2026-08-29T08:00:00.000Z'),
      );

      final json = member.toJson();

      expect(json['id'], equals('mem-101'));
      expect(json['dindi_id'], equals('dindi-99'));
      expect(json['name'], equals('Ganesh More'));
      expect(json['phone'], equals('+91 94230 78901'));
      expect(json['role'], equals('Warkari'));
      expect(json['status'], equals('active'));
    });
  });
}
