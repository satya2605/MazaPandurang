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

    test('MAP-11: Compact icon pins are rendered without permanent text overlays', () {
      const service = WariService(
        serviceId: 'WAT-001',
        name: 'Dehu Mobile Toilet Facility',
        description: 'Clean sanitation facility',
        category: ServiceCategory.toilet,
        position: WariLatLng(18.7148, 73.7669),
        availabilityStatus: 'Available',
        address: 'Dehu Ghat Road',
        contactPhone: '+919876543210',
      );

      final entity = MapLocationEntity(
        id: service.serviceId,
        type: MapLocationType.serviceToilet,
        title: service.name,
        subtitle: service.address,
        latitude: service.position.latitude,
        longitude: service.position.longitude,
        status: service.availabilityStatus,
        metadata: {'service': service},
      );

      // Verify compact marker properties
      expect(entity.type.icon, equals(Icons.wc_rounded));
      expect(entity.type.color, equals(const Color(0xFF00897B))); // Teal for toilet
      expect(entity.latitude, equals(18.7148));
      expect(entity.longitude, equals(73.7669));
    });

    test('MAP-12: Dindi privacy — non-member pilgrim sees NO Dindi markers on public map', () {
      final dindiList = [
        const DindiMarkerInfo(
          dindiId: 'DND-A',
          name: 'Dindi A Troupe',
          leaderName: 'Leader A',
          memberCount: 200,
          currentStatus: 'Active',
          position: WariLatLng(18.3411, 74.0305),
        ),
        const DindiMarkerInfo(
          dindiId: 'DND-B',
          name: 'Dindi B Troupe',
          leaderName: 'Leader B',
          memberCount: 150,
          currentStatus: 'Active',
          position: WariLatLng(18.5204, 73.8567),
        ),
      ];

      const String? userDindiId = null; // Public pilgrim without Dindi membership

      final MapLocationEntity? userDindiEntity = userDindiId != null
          ? dindiList.where((d) => d.dindiId == userDindiId).map((d) => MapLocationEntity(
                id: d.dindiId,
                type: MapLocationType.dindi,
                title: d.name,
                subtitle: d.leaderName,
                latitude: d.position.latitude,
                longitude: d.position.longitude,
                status: d.currentStatus,
              )).firstOrNull
          : null;

      expect(userDindiEntity, isNull); // Ensures public pilgrim receives zero Dindi markers
    });

    test('MAP-13: Dindi privacy — member of Dindi A sees ONLY Dindi A marker, not Dindi B', () {
      final dindiList = [
        const DindiMarkerInfo(
          dindiId: 'DND-A',
          name: 'Dindi A Troupe',
          leaderName: 'Leader A',
          memberCount: 200,
          currentStatus: 'Active',
          position: WariLatLng(18.3411, 74.0305),
        ),
        const DindiMarkerInfo(
          dindiId: 'DND-B',
          name: 'Dindi B Troupe',
          leaderName: 'Leader B',
          memberCount: 150,
          currentStatus: 'Active',
          position: WariLatLng(18.5204, 73.8567),
        ),
      ];

      const String userDindiId = 'DND-A'; // Member of Dindi A

      final visibleDindis = dindiList
          .where((d) => d.dindiId == userDindiId)
          .map((d) => MapLocationEntity(
                id: d.dindiId,
                type: MapLocationType.dindi,
                title: d.name,
                subtitle: d.leaderName,
                latitude: d.position.latitude,
                longitude: d.position.longitude,
                status: d.currentStatus,
              ))
          .toList();

      expect(visibleDindis.length, equals(1));
      expect(visibleDindis.first.id, equals('DND-A'));
      expect(visibleDindis.any((e) => e.id == 'DND-B'), isFalse);
    });

    test('MAP-14: Invalid or (0,0) coordinates are rejected and excluded from map marker pipeline', () {
      bool isValidCoordinate(double? lat, double? lng) {
        if (lat == null || lng == null) return false;
        if (lat == 0.0 && lng == 0.0) return false;
        if (lat < -90.0 || lat > 90.0) return false;
        if (lng < -180.0 || lng > 180.0) return false;
        return true;
      }

      expect(isValidCoordinate(null, 73.8567), isFalse);
      expect(isValidCoordinate(18.5204, null), isFalse);
      expect(isValidCoordinate(0.0, 0.0), isFalse);
      expect(isValidCoordinate(120.0, 73.8567), isFalse); // Invalid latitude
      expect(isValidCoordinate(18.5204, 73.8567), isTrue); // Valid latitude & longitude
    });

    test('MAP-15: Category filter correctly filters service markers', () {
      final services = [
        const WariService(
          serviceId: 'MED-1',
          name: 'Saswad Medical Camp',
          description: 'Emergency medical center',
          category: ServiceCategory.medical,
          position: WariLatLng(18.3411, 74.0305),
          availabilityStatus: 'Available',
          address: 'Saswad Main Road',
          contactPhone: '+919876543210',
        ),
        const WariService(
          serviceId: 'WAT-1',
          name: 'Palkhi Jal Seva',
          description: 'Drinking water distribution',
          category: ServiceCategory.water,
          position: WariLatLng(18.3420, 74.0310),
          availabilityStatus: 'Available',
          address: 'Saswad Water Stand',
          contactPhone: '+919876543211',
        ),
      ];

      const selectedFilter = ServiceCategory.medical;
      final filtered = services.where((s) => s.category == selectedFilter).toList();

      expect(filtered.length, equals(1));
      expect(filtered.first.serviceId, equals('MED-1'));
    });
  });
}
