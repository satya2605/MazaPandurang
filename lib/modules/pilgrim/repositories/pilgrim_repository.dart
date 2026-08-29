import '../models/pilgrim_models.dart';

/// Abstract repository contract for Pilgrim module data.
abstract class PilgrimRepository {
  Future<PilgrimLocation> getCurrentUserLocation();
  Future<PalkhiInfo> getPalkhiInfo();
  Future<List<DindiMarkerInfo>> getNearbyDindis();
  Future<List<WariService>> getServices({ServiceCategory? category});
  Future<WariService?> getServiceById(String serviceId);
  Future<List<BhaktiMediaItem>> getBhaktiContent({String? category});
  Future<TilakChatMessage> queryTilakAI(String prompt);
}
