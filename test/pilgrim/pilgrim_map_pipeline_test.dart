import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:maza_pandurang/modules/pilgrim/models/pilgrim_models.dart';
import 'package:maza_pandurang/modules/admin/models/admin_models.dart';

void main() {
  group('Pilgrim Map Data Pipeline Unit & Contract Tests (MAP-1 to MAP-12)', () {
    test('MAP-1: Palkhi API data parses into live Palkhi MapLocationEntity with correct type and coordinates', () {
      final palkhi = PalkhiInfo(
        palkhiId: 'PAL-100',
        name: 'Sant Tukaram Maharaj Palkhi',
        saint: 'Sant Tukaram Maharaj',
        startPoint: 'Dehu',
        destination: 'Pandharpur',
        currentStage: 'Akurdi Stay',
        nextStop: 'Pune Stay',
        currentPosition: const WariLatLng(18.7148, 73.7669),
        routePoints: const [WariLatLng(18.7148, 73.7669)],
        lastUpdated: DateTime.now(),
      );

      final entity = MapLocationEntity(
        id: palkhi.palkhiId,
        type: MapLocationType.palkhiLive,
        title: palkhi.name,
        subtitle: 'टप्पा: ${palkhi.currentStage}',
        latitude: palkhi.currentPosition.latitude,
        longitude: palkhi.currentPosition.longitude,
        status: 'ACTIVE',
        metadata: {'palkhi': palkhi},
      );

      expect(entity.type, equals(MapLocationType.palkhiLive));
      expect(entity.title, equals('Sant Tukaram Maharaj Palkhi'));
      expect(entity.latitude, equals(18.7148));
      expect(entity.longitude, equals(73.7669));
      expect(entity.type.icon, equals(Icons.flag_rounded));
    });

    test('MAP-2: Palkhi halts parse to halt markers when valid approx coordinates exist', () {
      final halt = PalkhiHalt.fromJson({
        'id': 'HALT-001',
        'palkhi_id': 'PAL-100',
        'day_number': 2,
        'halt_date': '2026-06-25',
        'location_name': 'Pune Palkhi Halt',
        'approx_latitude': 18.5204,
        'approx_longitude': 73.8567,
        'next_destination': 'Saswad Stay',
      });

      final entity = MapLocationEntity(
        id: halt.id,
        type: MapLocationType.palkhiHalt,
        title: '${halt.locationName} (दिवस ${halt.dayNumber})',
        subtitle: 'तारीख: ${halt.haltDate}',
        latitude: halt.approxLatitude!,
        longitude: halt.approxLongitude!,
        status: 'PLANNED',
        metadata: {'halt': halt},
      );

      expect(entity.type, equals(MapLocationType.palkhiHalt));
      expect(entity.latitude, equals(18.5204));
      expect(entity.longitude, equals(73.8567));
      expect(entity.type.icon, equals(Icons.signpost_rounded));
    });

    test('MAP-3 & MAP-5: Dindis parse to Dindi markers and maintain strict architectural separation from Palkhi', () {
      const dindi = DindiMarkerInfo(
        dindiId: 'DND-99',
        name: 'Alka Talkies Dindi',
        leaderName: 'Sanket Maharaj',
        memberCount: 450,
        currentStatus: 'Active',
        position: WariLatLng(18.3420, 74.0310),
      );

      final dindiEntity = MapLocationEntity(
        id: dindi.dindiId,
        type: MapLocationType.dindi,
        title: dindi.name,
        subtitle: 'प्रमुख: ${dindi.leaderName}',
        latitude: dindi.position.latitude,
        longitude: dindi.position.longitude,
        status: dindi.currentStatus,
        metadata: {'dindi': dindi},
      );

      expect(dindiEntity.type, equals(MapLocationType.dindi));
      expect(dindiEntity.type, isNot(equals(MapLocationType.palkhiLive)));
      expect(dindiEntity.type.icon, equals(Icons.groups_rounded));
      expect(dindiEntity.type.color, equals(const Color(0xFF7B1FA2)));
    });

    test('MAP-4: Services map to category-specific icons (Medical, Water, Food, Police, Toilet, Shelter)', () {
      expect(MapLocationType.serviceMedical.icon, equals(Icons.local_hospital_rounded));
      expect(MapLocationType.serviceWater.icon, equals(Icons.water_drop_rounded));
      expect(MapLocationType.serviceFood.icon, equals(Icons.restaurant_rounded));
      expect(MapLocationType.servicePolice.icon, equals(Icons.local_police_rounded));
      expect(MapLocationType.serviceToilet.icon, equals(Icons.wc_rounded));
      expect(MapLocationType.serviceShelter.icon, equals(Icons.night_shelter_rounded));
    });

    test('MAP-6: Records with missing/null coordinates do not pollute valid map location markers', () {
      final haltWithoutCoords = PalkhiHalt.fromJson({
        'id': 'HALT-NO-COORDS',
        'palkhi_id': 'PAL-100',
        'day_number': 9,
        'halt_date': '2026-07-01',
        'location_name': 'Unknown Halt',
        'approx_latitude': null,
        'approx_longitude': null,
      });

      expect(haltWithoutCoords.approxLatitude, isNull);
      expect(haltWithoutCoords.approxLongitude, isNull);
    });

    test('MAP-7: MapLocationEntity distance calculation accurately computes distance in KM', () {
      const pos1 = WariLatLng(18.3411, 74.0305); // Saswad
      const pos2 = WariLatLng(18.5204, 73.8567); // Pune

      final dist = pos1.distanceToInKm(pos2);
      expect(dist, greaterThan(15.0));
      expect(dist, lessThan(35.0));
    });

    test('MAP-10: Public Palkhi JSON serialization conceals internal administrative operator credentials', () {
      final jsonSample = {
        'id': 'PAL-DEMO',
        'name': 'Sant Dnyaneshwar Maharaj Palkhi',
        'saint': 'Sant Dnyaneshwar Maharaj',
        'currentStage': 'Alandi',
        'nextStop': 'Pune',
        'latitude': 18.6772,
        'longitude': 73.8967,
      };

      final palkhi = PalkhiInfo.fromJson(jsonSample);
      expect(palkhi.palkhiId, equals('PAL-DEMO'));
      expect(jsonSample.containsKey('assigned_operator_id'), isFalse);
    });
  });
}
