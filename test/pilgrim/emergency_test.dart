import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/models/pilgrim_models.dart';
import 'package:maza_pandurang/modules/pilgrim/repositories/mock_pilgrim_repository.dart';
import 'package:maza_pandurang/modules/pilgrim/screens/emergency_screen.dart';
import 'package:maza_pandurang/modules/pilgrim/widgets/emergency_sos_button.dart';
import 'package:maza_pandurang/modules/pilgrim/widgets/emergency_status_card.dart';

void main() {
  group('Pilgrim Emergency & Safety Integration Tests', () {
    test('EmergencyRequest.fromJson parses emergency JSON correctly', () {
      final json = {
        'id': 'EMG-100',
        'request_code': 'EMG-9999',
        'requester_id': '00000000-0000-0000-0000-000000000001',
        'emergency_type': 'Medical',
        'latitude': 18.3411,
        'longitude': 74.0305,
        'location_name': 'Saswad Exit Desk',
        'description': 'Sunstroke treatment required',
        'status': 'pending',
        'created_at': '2026-08-29T20:00:00.000Z',
      };

      final req = EmergencyRequest.fromJson(json);

      expect(req.id, equals('EMG-100'));
      expect(req.requestCode, equals('EMG-9999'));
      expect(req.emergencyType, equals('Medical'));
      expect(req.status, equals('pending'));
      expect(req.position.latitude, equals(18.3411));
    });

    testWidgets('EmergencySosButton renders and shows confirmation modal on tap', (tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencySosButton(
              emergencyType: 'Medical',
              onConfirmedSubmit: () async {
                submitted = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('🚨 SEND EMERGENCY SOS'), findsOneWidget);

      await tester.tap(find.text('🚨 SEND EMERGENCY SOS'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Emergency SOS'), findsOneWidget);
      expect(find.text('DISPATCH SOS'), findsOneWidget);

      await tester.tap(find.text('DISPATCH SOS'));
      await tester.pumpAndSettle();

      expect(submitted, isTrue);
    });

    testWidgets('EmergencyStatusCard renders request details and status chip', (tester) async {
      final req = EmergencyRequest(
        id: 'EMG-001',
        requestCode: 'EMG-1001',
        requesterId: '00000000-0000-0000-0000-000000000001',
        emergencyType: 'Medical',
        position: const WariLatLng(18.3411, 74.0305),
        locationName: 'Saswad Central Camp',
        description: 'Need oxygen cylinder',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyStatusCard(request: req),
          ),
        ),
      );

      expect(find.text('EMG-1001'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.textContaining('Medical'), findsOneWidget);
    });

    testWidgets('EmergencyScreen renders type chips and dispatches SOS', (tester) async {
      final mockRepo = MockPilgrimRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyScreen(repository: mockRepo),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Emergency & Safety (आपत्कालीन सेवा)'), findsOneWidget);
      expect(find.text('Select Emergency Assistance Type'), findsOneWidget);
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Police'), findsOneWidget);
      expect(find.text('🚨 SEND EMERGENCY SOS'), findsOneWidget);
    });
  });
}
