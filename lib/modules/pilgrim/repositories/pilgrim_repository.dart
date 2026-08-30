import '../models/pilgrim_models.dart';

/// Abstract repository contract for Pilgrim module data.
abstract class PilgrimRepository {
  Future<PilgrimLocation> getCurrentUserLocation();
  Future<PalkhiInfo> getPalkhiInfo();
  Future<List<PalkhiInfo>> getPalkhiList();
  Future<List<DindiMarkerInfo>> getNearbyDindis();
  Future<DindiDetail?> getDindiById(String id);
  Future<List<Map<String, dynamic>>> getDindiMembers(String id);
  Future<bool> joinDindi(String dindiId, {String? notes});
  Future<List<WariService>> getServices({ServiceCategory? category});
  Future<WariService?> getServiceById(String serviceId);
  Future<List<WariRouteStage>> getWariRoute();
  Future<List<CityPlace>> getCityPlaces();
  Future<List<CityRoute>> getCityRoutes();
  Future<List<BhaktiMediaItem>> getBhaktiContent({String? category});
  Future<DonationsInfo?> getDonationsInfo();
  Future<List<LostPersonReport>> getLostPersons();
  Future<bool> reportLostPersonSighting(String lostPersonId, {required double latitude, required double longitude, required String locationName, String? details});
  Future<List<LostPersonSighting>> getLostPersonSightings(String lostPersonId);
  Future<bool> reportEmergency({required String emergencyType, required double latitude, required double longitude, String? description});
  Future<EmergencyRequest> createEmergencyRequest({required String emergencyType, required double latitude, required double longitude, String? locationName, String? description});
  Future<List<EmergencyRequest>> getEmergencyRequests();
  Future<List<TrafficAlert>> getTrafficAlerts();
  Future<TilakChatMessage> queryTilakAI(String prompt);
  Future<String?> transcribeAudio(List<int> audioBytes);
  Future<String?> synthesizeTTS(String text);
}
