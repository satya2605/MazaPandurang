import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/pilgrim_models.dart';
import 'mock_pilgrim_repository.dart';
import 'pilgrim_repository.dart';

/// Production API Pilgrim Repository communicating with Node.js REST API
/// (`http://localhost:3000/api`) with automatic fallback to [MockPilgrimRepository].
class ApiPilgrimRepository implements PilgrimRepository {
  final String baseUrl;
  final MockPilgrimRepository _fallback = MockPilgrimRepository();

  ApiPilgrimRepository({
    String? baseUrl,
  }) : baseUrl = baseUrl ??
            const String.fromEnvironment('API_BASE_URL',
                defaultValue: 'http://localhost:3000');

  @override
  Future<PilgrimLocation> getCurrentUserLocation() async {
    return _fallback.getCurrentUserLocation();
  }

  @override
  Future<PalkhiInfo> getPalkhiInfo() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/palkhi'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PalkhiInfo(
          palkhiId: data['id'] ?? 'PALKHI-001',
          name: data['name'] ?? 'Sant Dnyaneshwar Maharaj Palkhi',
          currentStage: data['currentStage'] ?? 'Saswad Stay',
          nextStop: data['nextStop'] ?? 'Jejuri',
          currentPosition: WariLatLng(
            data['latitude']?.toDouble() ?? 18.3411,
            data['longitude']?.toDouble() ?? 74.0305,
          ),
          lastUpdated:
              DateTime.tryParse(data['lastUpdated'] ?? '') ?? DateTime.now(),
          routePoints: (await _fallback.getPalkhiInfo()).routePoints,
        );
      }
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Fallback Palkhi: $e');
    }
    return await _fallback.getPalkhiInfo();
  }

  @override
  Future<List<DindiMarkerInfo>> getNearbyDindis() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/dindis'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list
            .map((item) => DindiMarkerInfo(
                  dindiId: item['id'] ?? 'DND-001',
                  name: item['name'] ?? 'Alka Talkies Dindi',
                  leaderName: item['leaderName'] ?? 'Dindi Leader',
                  memberCount: item['memberCount'] ?? 100,
                  currentStatus: item['currentStatus'] ?? 'Active',
                  position: WariLatLng(
                    item['latitude']?.toDouble() ?? 18.3411,
                    item['longitude']?.toDouble() ?? 74.0305,
                  ),
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Fallback Dindis: $e');
    }
    return await _fallback.getNearbyDindis();
  }

  @override
  Future<List<WariService>> getServices({ServiceCategory? category}) async {
    try {
      final uri = category != null
          ? Uri.parse('$baseUrl/api/services?category=${category.name}')
          : Uri.parse('$baseUrl/api/services');

      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) {
          final catName = item['category'] ?? 'Other';
          final matchedCategory = ServiceCategory.values.firstWhere(
            (c) => c.name.toLowerCase() == catName.toString().toLowerCase(),
            orElse: () => ServiceCategory.medical,
          );

          return WariService(
            serviceId:
                item['serviceCode'] ?? item['service_id'] ?? 'SRV-MED-001',
            category: matchedCategory,
            name: item['name'] ?? 'Wari Service',
            description: item['description'] ?? '',
            address: item['address'] ?? '',
            position: WariLatLng(
              item['latitude']?.toDouble() ?? 18.3411,
              item['longitude']?.toDouble() ?? 74.0305,
            ),
            contactPhone: item['contactPhone'] ?? '',
            availabilityStatus: item['availabilityStatus'] ?? 'Open 24/7',
            isVerified: item['isVerified'] ?? true,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Fallback Services: $e');
    }
    return await _fallback.getServices(category: category);
  }

  @override
  Future<WariService?> getServiceById(String serviceId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/services/$serviceId'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final item = json.decode(response.body);
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
          contactPhone: item['contactPhone'] ?? '',
          availabilityStatus: item['availabilityStatus'] ?? 'Open 24/7',
          isVerified: item['isVerified'] ?? true,
        );
      }
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Fallback ServiceById: $e');
    }
    return await _fallback.getServiceById(serviceId);
  }

  @override
  Future<List<BhaktiMediaItem>> getBhaktiContent({String? category}) async {
    try {
      final uri = category != null && category != 'Featured'
          ? Uri.parse('$baseUrl/api/bhakti?category=$category')
          : Uri.parse('$baseUrl/api/bhakti');

      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list
            .map((item) => BhaktiMediaItem(
                  id: item['id'] ?? 'BHK-001',
                  title: item['title'] ?? '',
                  marathiTitle: item['marathiTitle'] ?? '',
                  artist: item['artist'] ?? '',
                  category: item['category'] ?? 'Abhang',
                  duration: item['duration'] ?? '04:00',
                  streamUrl: item['externalUrl'] ?? '',
                  thumbnailUrl: item['thumbnailUrl'] ?? '',
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Fallback Bhakti: $e');
    }
    return await _fallback.getBhaktiContent(category: category);
  }

  @override
  Future<TilakChatMessage> queryTilakAI(String prompt) async {
    return await _fallback.queryTilakAI(prompt);
  }
}
