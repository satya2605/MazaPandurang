import '../models/dindi_announcement.dart';
import '../models/dindi_group.dart';
import '../models/dindi_member.dart';

/// Minimal repository contract for Dindi data access.
/// Designed for easy substitution with SupabaseDindiRepository in future phases.
abstract class DindiRepository {
  Future<List<DindiGroup>> getDindis({String? leaderUserId});

  Future<DindiGroup?> getDindiById(String id);

  Future<DindiGroup> createDindi(DindiGroup dindi);

  Future<DindiGroup> updateDindi(DindiGroup dindi);

  Future<List<DindiMember>> getMembers(String dindiId);

  Future<void> updateMemberStatus(
    String memberId,
    DindiMemberStatus status,
  );

  Future<void> removeMember(String memberId);

  Future<List<DindiAnnouncement>> getAnnouncements(String dindiId);

  Future<void> addAnnouncement(DindiAnnouncement announcement);
}
