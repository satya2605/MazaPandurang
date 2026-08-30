import '../models/dindi_announcement.dart';
import '../models/dindi_group.dart';
import '../models/dindi_member.dart';

/// Repository contract for Dindi data access.
abstract class DindiRepository {
  Future<List<DindiGroup>> getDindis({String? leaderUserId});

  Future<DindiGroup?> getDindiById(String id);

  Future<DindiGroup> createDindi(DindiGroup dindi);

  Future<DindiGroup> updateDindi(DindiGroup dindi);

  Future<bool> updateDindiLocation(
    String dindiId, {
    required double latitude,
    required double longitude,
    String? locationName,
    String? currentHalt,
  });

  Future<bool> addDindiHalt(String dindiId, Map<String, dynamic> haltData);

  Future<bool> updateDindiHalt(String haltId, Map<String, dynamic> haltData);

  Future<bool> deleteDindiHalt(String haltId);

  Future<List<DindiMember>> getMembers(String dindiId);

  Future<void> updateMemberStatus(
    String memberId,
    DindiMemberStatus status,
  );

  Future<void> removeMember(String memberId);

  Future<List<DindiAnnouncement>> getAnnouncements(String dindiId);

  Future<void> addAnnouncement(DindiAnnouncement announcement);
}
