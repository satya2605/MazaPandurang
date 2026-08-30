import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/pilgrim_models.dart';
import 'mock_pilgrim_repository.dart';
import 'pilgrim_repository.dart';

/// Production API Pilgrim Repository communicating with Node.js REST API
/// (`http://localhost:3000/api`) via shared [ApiClient] with automatic fallback to [MockPilgrimRepository].
class ApiPilgrimRepository implements PilgrimRepository {
  final ApiClient _apiClient = ApiClient();
  final MockPilgrimRepository _fallback = MockPilgrimRepository();

  @override
  Future<PilgrimLocation> getCurrentUserLocation() async {
    return _fallback.getCurrentUserLocation();
  }

  @override
  Future<PalkhiInfo> getPalkhiInfo() async {
    final list = await getPalkhiList();
    return list.isNotEmpty ? list.first : await _fallback.getPalkhiInfo();
  }

  @override
  Future<List<PalkhiInfo>> getPalkhiList() async {
    try {
      final response = await _apiClient.get('/palkhi').timeout(const Duration(milliseconds: 600));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          final list = decoded
              .whereType<Map<String, dynamic>>()
              .map((data) => PalkhiInfo.fromJson(data))
              .toList();
          if (list.isNotEmpty) return list;
        } else if (decoded is Map<String, dynamic>) {
          return [PalkhiInfo.fromJson(decoded)];
        }
      }
    } catch (e) {
      debugPrint('[MOCK] /api/palkhi fallback: $e');
    }
    return await _fallback.getPalkhiList();
  }

  @override
  Future<List<DindiMarkerInfo>> getNearbyDindis() async {
    try {
      final response = await _apiClient.get('/dindis').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        debugPrint('[API] /api/dindis success (${list.length} dindis)');
        return list
            .map((item) => DindiMarkerInfo(
                  dindiId: item['id'] ?? 'DND-001',
                  name: item['name'] ?? 'Alka Talkies Dindi',
                  leaderName: item['leaderName'] ?? item['leader_name'] ?? 'Dindi Leader',
                  memberCount: item['memberCount'] ?? item['member_count'] ?? 100,
                  currentStatus: item['status'] ?? item['currentStatus'] ?? 'Active',
                  position: WariLatLng(
                    item['latitude']?.toDouble() ?? 18.3411,
                    item['longitude']?.toDouble() ?? 74.0305,
                  ),
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/dindis fallback: $e');
    }
    return await _fallback.getNearbyDindis();
  }

  @override
  Future<DindiDetail?> getDindiById(String id) async {
    try {
      final response = await _apiClient.get('/dindis/$id').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DindiDetail(
          id: data['id'] ?? id,
          dindiNumber: data['dindiNumber'] ?? data['dindi_number'] ?? 'DND-001',
          name: data['name'] ?? '',
          leaderId: data['leaderId'] ?? data['leader_id'] ?? '',
          leaderName: data['leaderName'] ?? data['leader_name'] ?? 'Dindi Leader',
          leaderPhone: data['leaderPhone'] ?? data['leader_phone'] ?? '',
          memberCount: data['memberCount'] ?? data['member_count'] ?? 1,
          currentLocationName: data['currentLocationName'] ?? data['current_location_name'] ?? '',
          position: WariLatLng(
            data['latitude']?.toDouble() ?? 18.3411,
            data['longitude']?.toDouble() ?? 74.0305,
          ),
          status: data['status'] ?? 'Active',
          startPoint: data['startPoint'] ?? data['start_point'] ?? '',
          destination: data['destination'] ?? '',
          currentHalt: data['currentHalt'] ?? data['current_halt'] ?? '',
          roadStatus: data['roadStatus'] ?? data['road_status'] ?? 'clear',
          joinCode: data['joinCode'] ?? data['join_code'] ?? '',
        );
      }
    } catch (e) {
      debugPrint('[MOCK] /api/dindis/$id fallback: $e');
    }
    return await _fallback.getDindiById(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getDindiMembers(String id) async {
    try {
      final response = await _apiClient.get('/dindis/$id/members').timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/dindis/$id/members fallback: $e');
    }
    return await _fallback.getDindiMembers(id);
  }

  @override
  Future<bool> joinDindi(String dindiId, {String? notes}) async {
    try {
      final response = await _apiClient.post(
        '/dindis/$dindiId/join',
        body: {'notes': notes ?? ''},
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[MOCK] /api/dindis/$dindiId/join fallback: $e');
      return await _fallback.joinDindi(dindiId, notes: notes);
    }
  }

  @override
  Future<List<WariService>> getServices({ServiceCategory? category}) async {
    try {
      final endpoint = category != null ? '/services?category=${category.name}' : '/services';

      final response = await _apiClient.get(endpoint).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        debugPrint('[API] /api/services success (${list.length} services)');
        return list.map((item) {
          final catName = item['category'] ?? 'Other';
          final matchedCategory = ServiceCategory.values.firstWhere(
            (c) => c.name.toLowerCase() == catName.toString().toLowerCase(),
            orElse: () => ServiceCategory.medical,
          );

          return WariService(
            serviceId: item['serviceCode'] ?? item['service_id'] ?? 'SRV-MED-001',
            category: matchedCategory,
            name: item['name'] ?? 'Wari Service',
            description: item['description'] ?? '',
            address: item['address'] ?? '',
            position: WariLatLng(
              item['latitude']?.toDouble() ?? 18.3411,
              item['longitude']?.toDouble() ?? 74.0305,
            ),
            contactPhone: item['contactPhone'] ?? item['contact_phone'] ?? '',
            availabilityStatus: item['availabilityStatus'] ?? item['availability_status'] ?? 'Open 24/7',
            isVerified: item['isVerified'] ?? item['is_verified'] ?? true,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/services fallback: $e');
    }
    return await _fallback.getServices(category: category);
  }

  @override
  Future<WariService?> getServiceById(String serviceId) async {
    try {
      final response = await _apiClient.get('/services/$serviceId').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        final catName = item['category'] ?? 'Other';
        final matchedCategory = ServiceCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == catName.toString().toLowerCase(),
          orElse: () => ServiceCategory.medical,
        );

        return WariService(
          serviceId: item['serviceCode'] ?? item['service_id'] ?? serviceId,
          category: matchedCategory,
          name: item['name'] ?? 'Wari Service',
          description: item['description'] ?? '',
          address: item['address'] ?? '',
          position: WariLatLng(
            item['latitude']?.toDouble() ?? 18.3411,
            item['longitude']?.toDouble() ?? 74.0305,
          ),
          contactPhone: item['contactPhone'] ?? item['contact_phone'] ?? '',
          availabilityStatus: item['availabilityStatus'] ?? item['availability_status'] ?? 'Open 24/7',
          isVerified: item['isVerified'] ?? item['is_verified'] ?? true,
        );
      }
    } catch (e) {
      debugPrint('[MOCK] /api/services/$serviceId fallback: $e');
    }
    return await _fallback.getServiceById(serviceId);
  }

  @override
  Future<List<WariRouteStage>> getWariRoute() async {
    try {
      final response = await _apiClient.get('/wari-route').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) => WariRouteStage.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/wari-route fallback: $e');
    }
    return await _fallback.getWariRoute();
  }

  @override
  Future<List<CityPlace>> getCityPlaces() async {
    try {
      final response = await _apiClient.get('/city-places').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) => CityPlace.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/city-places fallback: $e');
    }
    return await _fallback.getCityPlaces();
  }

  @override
  Future<List<CityRoute>> getCityRoutes() async {
    try {
      final response = await _apiClient.get('/routes').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) => CityRoute.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/routes fallback: $e');
    }
    return await _fallback.getCityRoutes();
  }

  @override
  Future<List<BhaktiMediaItem>> getBhaktiContent({String? category}) async {
    try {
      final endpoint = category != null && category != 'Featured' ? '/bhakti?category=$category' : '/bhakti';

      final response = await _apiClient.get(endpoint).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list
            .map((item) => BhaktiMediaItem(
                  id: item['id'] ?? 'BHK-001',
                  title: item['title'] ?? '',
                  marathiTitle: item['marathiTitle'] ?? item['marathi_title'] ?? '',
                  artist: item['artist'] ?? '',
                  category: item['category'] ?? 'Abhang',
                  duration: item['duration'] ?? '04:00',
                  streamUrl: item['externalUrl'] ?? item['stream_url'] ?? '',
                  thumbnailUrl: item['thumbnailUrl'] ?? item['thumbnail_url'] ?? '',
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/bhakti fallback: $e');
    }
    return await _fallback.getBhaktiContent(category: category);
  }

  @override
  Future<DonationsInfo?> getDonationsInfo() async {
    try {
      final response = await _apiClient.get('/donations-info').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        return DonationsInfo.fromJson(item as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[MOCK] /api/donations-info fallback: $e');
    }
    return await _fallback.getDonationsInfo();
  }

  @override
  Future<List<LostPersonReport>> getLostPersons() async {
    try {
      final response = await _apiClient.get('/lost-persons').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) => LostPersonReport.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/lost-persons fallback: $e');
    }
    return await _fallback.getLostPersons();
  }

  @override
  Future<bool> reportLostPersonSighting(String lostPersonId, {required double latitude, required double longitude, required String locationName, String? details}) async {
    try {
      final response = await _apiClient.post(
        '/lost-persons/$lostPersonId/sightings',
        body: {
          'latitude': latitude,
          'longitude': longitude,
          'location_name': locationName,
          'details': details ?? '',
        },
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[MOCK] /api/lost-persons/$lostPersonId/sightings fallback: $e');
      return await _fallback.reportLostPersonSighting(lostPersonId, latitude: latitude, longitude: longitude, locationName: locationName, details: details);
    }
  }

  @override
  Future<List<LostPersonSighting>> getLostPersonSightings(String lostPersonId) async {
    try {
      final response = await _apiClient.get('/lost-persons/$lostPersonId/sightings').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) => LostPersonSighting.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/lost-persons/$lostPersonId/sightings fallback: $e');
    }
    return await _fallback.getLostPersonSightings(lostPersonId);
  }

  @override
  Future<bool> reportEmergency({required String emergencyType, required double latitude, required double longitude, String? description}) async {
    try {
      final req = await createEmergencyRequest(
        emergencyType: emergencyType,
        latitude: latitude,
        longitude: longitude,
        description: description,
      );
      return req.id.isNotEmpty;
    } catch (_) {
      return await _fallback.reportEmergency(emergencyType: emergencyType, latitude: latitude, longitude: longitude, description: description);
    }
  }

  @override
  Future<EmergencyRequest> createEmergencyRequest({
    required String emergencyType,
    required double latitude,
    required double longitude,
    String? locationName,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        '/emergencies',
        body: {
          'emergency_type': emergencyType,
          'latitude': latitude,
          'longitude': longitude,
          'location_name': locationName ?? '',
          'description': description ?? '',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final emgData = body['emergency'] ?? body;
        return EmergencyRequest.fromJson(emgData as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[MOCK] POST /api/emergencies fallback: $e');
    }
    return await _fallback.createEmergencyRequest(
      emergencyType: emergencyType,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      description: description,
    );
  }

  @override
  Future<List<EmergencyRequest>> getEmergencyRequests() async {
    try {
      final response = await _apiClient.get('/emergencies').timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => EmergencyRequest.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] GET /api/emergencies fallback: $e');
    }
    return await _fallback.getEmergencyRequests();
  }

  @override
  Future<List<TrafficAlert>> getTrafficAlerts() async {
    try {
      final response = await _apiClient.get('/traffic-alerts').timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => TrafficAlert.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[MOCK] /api/traffic-alerts fallback: $e');
    }
    return await _fallback.getTrafficAlerts();
  }

  @override
  Future<TilakChatMessage> queryTilakAI(String prompt) async {
    try {
      final response = await _apiClient.post(
        '/assistant/chat',
        body: {
          'message': prompt,
          'context': {
            'latitude': 18.3411,
            'longitude': 74.0305,
          },
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return TilakChatMessage.fromJson(json);
      }
    } catch (e) {
      debugPrint('[MOCK] /api/assistant/chat fallback: $e');
    }
    return await _fallback.queryTilakAI(prompt);
  }

  @override
  Future<String?> transcribeAudio(List<int> audioBytes) async {
    try {
      final response = await _apiClient.postMultipart(
        '/assistant/stt',
        audioBytes,
        filename: 'recorded_voice.wav',
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['text'] as String?;
      }
    } catch (e) {
      debugPrint('[MOCK] /api/assistant/stt fallback: $e');
    }
    return await _fallback.transcribeAudio(audioBytes);
  }

  @override
  Future<String?> synthesizeTTS(String text) async {
    try {
      final response = await _apiClient.post(
        '/assistant/tts',
        body: {
          'text': text,
          'languageCode': 'mr-IN',
          'speaker': 'meera',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['audio'] as String?;
      }
    } catch (e) {
      debugPrint('[MOCK] /api/assistant/tts fallback: $e');
    }
    return await _fallback.synthesizeTTS(text);
  }
}
