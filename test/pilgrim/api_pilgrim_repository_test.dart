import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/models/pilgrim_models.dart';
import 'package:maza_pandurang/modules/pilgrim/repositories/api_pilgrim_repository.dart';
import 'package:maza_pandurang/modules/pilgrim/repositories/mock_pilgrim_repository.dart';

void main() {
  group('ApiPilgrimRepository & WariRouteStage Unit Tests', () {
    test('WariRouteStage.fromJson parses backend JSON response correctly', () {
      final json = {
        'id': '1',
        'stageName': 'Saswad Stay (सासवड मुक्काम)',
        'sequenceOrder': 4,
        'latitude': 18.3411,
        'longitude': 74.0305,
      };

      final stage = WariRouteStage.fromJson(json);

      expect(stage.id, equals('1'));
      expect(stage.stageName, equals('Saswad Stay (सासवड मुक्काम)'));
      expect(stage.sequenceOrder, equals(4));
      expect(stage.position.latitude, equals(18.3411));
      expect(stage.position.longitude, equals(74.0305));
    });

    test('WariRouteStage.fromJson handles snake_case keys gracefully', () {
      final json = {
        'id': 2,
        'stage_name': 'Jejuri (जेजुरी)',
        'sequence_order': 5,
        'latitude': 18.2764,
        'longitude': 74.1611,
      };

      final stage = WariRouteStage.fromJson(json);

      expect(stage.id, equals('2'));
      expect(stage.stageName, equals('Jejuri (जेजुरी)'));
      expect(stage.sequenceOrder, equals(5));
      expect(stage.position.latitude, equals(18.2764));
    });

    test('MockPilgrimRepository implements getWariRoute returning 8 stages', () async {
      final mockRepo = MockPilgrimRepository();
      final stages = await mockRepo.getWariRoute();

      expect(stages.length, equals(8));
      expect(stages.first.stageName, contains('Alandi'));
      expect(stages.last.stageName, contains('Pandharpur'));
    });

    test('ApiPilgrimRepository falls back cleanly when backend is unreachable', () async {
      final apiRepo = ApiPilgrimRepository();

      final palkhi = await apiRepo.getPalkhiInfo();
      final dindis = await apiRepo.getNearbyDindis();
      final services = await apiRepo.getServices();
      final routeStages = await apiRepo.getWariRoute();
      final cityPlaces = await apiRepo.getCityPlaces();
      final cityRoutes = await apiRepo.getCityRoutes();
      final donations = await apiRepo.getDonationsInfo();
      final lostPersons = await apiRepo.getLostPersons();
      final emergencyResult = await apiRepo.reportEmergency(
        emergencyType: 'Medical SOS',
        latitude: 18.3411,
        longitude: 74.0305,
        description: 'Test emergency report',
      );

      expect(palkhi.name, contains('Palkhi'));
      expect(dindis, isA<List<DindiMarkerInfo>>());
      expect(services, isA<List<WariService>>());
      expect(routeStages.length, equals(8));
      expect(cityPlaces, isA<List<CityPlace>>());
      expect(cityRoutes, isA<List<CityRoute>>());
      expect(donations, isNotNull);
      expect(lostPersons, isA<List<LostPersonReport>>());
      expect(emergencyResult, isTrue);
    });
  });
}
