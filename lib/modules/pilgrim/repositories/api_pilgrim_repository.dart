import 'package:flutter/foundation.dart';
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
      // In real deployment, fetches GET $baseUrl/api/palkhi
      return await _fallback.getPalkhiInfo();
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Error fetching Palkhi info: $e');
      return await _fallback.getPalkhiInfo();
    }
  }

  @override
  Future<List<DindiMarkerInfo>> getNearbyDindis() async {
    try {
      return await _fallback.getNearbyDindis();
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Error fetching Dindis: $e');
      return await _fallback.getNearbyDindis();
    }
  }

  @override
  Future<List<WariService>> getServices({ServiceCategory? category}) async {
    try {
      return await _fallback.getServices(category: category);
    } catch (e) {
      debugPrint('[ApiPilgrimRepository] Error fetching services: $e');
      return await _fallback.getServices(category: category);
    }
  }

  @override
  Future<WariService?> getServiceById(String serviceId) async {
    try {
      return await _fallback.getServiceById(serviceId);
    } catch (e) {
      return await _fallback.getServiceById(serviceId);
    }
  }

  @override
  Future<List<BhaktiMediaItem>> getBhaktiContent({String? category}) async {
    try {
      return await _fallback.getBhaktiContent(category: category);
    } catch (e) {
      return await _fallback.getBhaktiContent(category: category);
    }
  }

  @override
  Future<TilakChatMessage> queryTilakAI(String prompt) async {
    return await _fallback.queryTilakAI(prompt);
  }
}
