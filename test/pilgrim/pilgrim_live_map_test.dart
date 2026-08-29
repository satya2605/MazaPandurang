import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/models/pilgrim_models.dart';
import 'package:maza_pandurang/modules/pilgrim/repositories/mock_pilgrim_repository.dart';
import 'package:maza_pandurang/modules/pilgrim/services/location_service.dart';
import 'package:maza_pandurang/modules/pilgrim/services/map_service_interface.dart';
import 'package:maza_pandurang/modules/pilgrim/widgets/pilgrim_map_widget.dart';

void main() {
  group('Pilgrim Live Wari Map & Location Intelligence Tests', () {
    test('TrafficAlert.fromJson parses alert JSON response correctly', () {
      final json = {
        'id': 'TRF-100',
        'alert_code': 'TRF-DIVE-01',
        'title': 'Dive Ghat Slowdown',
        'description': 'Heavy pilgrim procession crowd',
        'type': 'CROWD_DENSITY',
        'severity': 'HIGH',
        'status': 'ACTIVE',
        'latitude': 18.4100,
        'longitude': 73.9700,
      };

      final alert = TrafficAlert.fromJson(json);

      expect(alert.id, equals('TRF-100'));
      expect(alert.alertCode, equals('TRF-DIVE-01'));
      expect(alert.title, equals('Dive Ghat Slowdown'));
      expect(alert.severity, equals('HIGH'));
      expect(alert.position.latitude, equals(18.4100));
    });

    test('WariLatLng.distanceToInKm calculates distance accurately', () {
      const saswad = WariLatLng(18.3411, 74.0305);
      const jejuri = WariLatLng(18.2764, 74.1611);

      final distance = saswad.distanceToInKm(jejuri);
      expect(distance, greaterThan(10.0));
      expect(distance, lessThan(25.0));
    });

    test('LocationService handles permission request safely without crashing', () async {
      final locationService = LocationService();
      expect(locationService.status, equals(LocationPermissionStatus.notRequested));

      final status = await locationService.requestPermission();
      expect(status, equals(LocationPermissionStatus.granted));

      final location = await locationService.getCurrentLocation();
      expect(location, isNotNull);
      expect(location?.position.latitude, equals(18.3411));
    });

    testWidgets('PilgrimMapWidget renders live Palkhi banner and controls', (tester) async {
      final mockRepo = MockPilgrimRepository();
      final mockMapService = DefaultMapService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PilgrimMapWidget(
              repository: mockRepo,
              mapService: mockMapService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Sant Dnyaneshwar Maharaj Palkhi'), findsOneWidget);
      expect(find.text('All Services'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
