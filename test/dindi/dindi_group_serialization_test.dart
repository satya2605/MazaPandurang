import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_group.dart';

void main() {
  group('DindiGroup JSON Serialization & Deserialization Tests', () {
    test('serializes DindiGroup to JSON correctly with status and without leader_id', () {
      const dindi = DindiGroup(
        id: '00000000-0000-0000-0000-000000000010',
        name: 'Shree Tukaram Maharaj Dindi',
        dindiNumber: '12',
        leaderName: 'Sanket Patil',
        leaderPhone: '+91 98220 12345',
        startPoint: 'Dehu',
        destination: 'Pandharpur',
        currentHalt: 'Akurdi Vitthal Mandir',
        roadStatus: 'Clear & Moving',
        joinCode: 'TK12W4',
        leaderUserId: '00000000-0000-0000-0000-000000000002',
        status: 'Active',
      );

      final jsonMap = dindi.toJson();

      expect(jsonMap['id'], equals('00000000-0000-0000-0000-000000000010'));
      expect(jsonMap['name'], equals('Shree Tukaram Maharaj Dindi'));
      expect(jsonMap['dindiNumber'], equals('12'));
      expect(jsonMap['leaderName'], equals('Sanket Patil'));
      expect(jsonMap['leaderPhone'], equals('+91 98220 12345'));
      expect(jsonMap['startPoint'], equals('Dehu'));
      expect(jsonMap['destination'], equals('Pandharpur'));
      expect(jsonMap['currentHalt'], equals('Akurdi Vitthal Mandir'));
      expect(jsonMap['roadStatus'], equals('Clear & Moving'));
      expect(jsonMap['joinCode'], equals('TK12W4'));
      expect(jsonMap['status'], equals('Active'));
      // Client payloads must NOT send leader_id to preserve backend authority
      expect(jsonMap.containsKey('leader_id'), isFalse);
      expect(jsonMap.containsKey('leaderUserId'), isFalse);
    });

    test('deserializes camelCase API payload to DindiGroup with status', () {
      final jsonMap = {
        'id': '00000000-0000-0000-0000-000000000010',
        'name': 'Alka Talkies Dindi #1',
        'dindiNumber': 'DND-001',
        'leaderName': 'Sanket Maharaj',
        'leaderPhone': '+919876543211',
        'startPoint': 'Alandi',
        'destination': 'Pandharpur',
        'currentHalt': 'Saswad Market',
        'roadStatus': 'clear',
        'joinCode': 'DND123',
        'leaderUserId': '00000000-0000-0000-0000-000000000002',
        'status': 'Halted',
      };

      final dindi = DindiGroup.fromJson(jsonMap);

      expect(dindi.id, equals('00000000-0000-0000-0000-000000000010'));
      expect(dindi.name, equals('Alka Talkies Dindi #1'));
      expect(dindi.dindiNumber, equals('DND-001'));
      expect(dindi.leaderName, equals('Sanket Maharaj'));
      expect(dindi.leaderPhone, equals('+919876543211'));
      expect(dindi.startPoint, equals('Alandi'));
      expect(dindi.destination, equals('Pandharpur'));
      expect(dindi.currentHalt, equals('Saswad Market'));
      expect(dindi.roadStatus, equals('clear'));
      expect(dindi.joinCode, equals('DND123'));
      expect(dindi.status, equals('Halted'));
      expect(
          dindi.leaderUserId, equals('00000000-0000-0000-0000-000000000002'));
    });

    test(
        'deserializes snake_case database row to DindiGroup with safe defaults',
        () {
      final dbRow = {
        'id': '00000000-0000-0000-0000-000000000011',
        'name': 'Mauli Swaranand Dindi #45',
        'dindi_number': 'DND-002',
        'start_point': 'Pune',
        'destination': 'Pandharpur',
        'current_halt': 'Hadapsar',
        'road_status': 'slow',
        'join_code': 'DND456',
        'leader_id': '00000000-0000-0000-0000-000000000002',
      };

      final dindi = DindiGroup.fromJson(dbRow);

      expect(dindi.id, equals('00000000-0000-0000-0000-000000000011'));
      expect(dindi.dindiNumber, equals('DND-002'));
      expect(dindi.leaderName, equals('Dindi Leader')); // Safe default
      expect(dindi.startPoint, equals('Pune'));
      expect(dindi.roadStatus, equals('slow'));
      expect(dindi.joinCode, equals('DND456'));
      expect(dindi.status, equals('Active')); // Default status
      expect(
          dindi.leaderUserId, equals('00000000-0000-0000-0000-000000000002'));
    });
  });
}
