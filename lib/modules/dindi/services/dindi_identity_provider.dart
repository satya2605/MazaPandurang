import '../../../core/auth/auth_service.dart';

/// Abstract contract representing the identity of a Dindi Leader.
///
/// Designed to decouple the Dindi module from concrete authentication mechanisms.
abstract class DindiIdentityProvider {
  /// The unique identifier of the currently signed-in leader (UUID in Supabase).
  String get currentUserId;

  /// The display name of the leader.
  String get currentLeaderName;

  /// The contact phone of the leader.
  String get currentLeaderPhone;
}

/// Production identity provider dynamically deriving credentials from [AuthService].
class AuthDindiIdentityProvider implements DindiIdentityProvider {
  const AuthDindiIdentityProvider();

  @override
  String get currentUserId {
    final profile = AuthService().currentProfile;
    if (profile != null && profile['id'] != null) {
      return profile['id'].toString();
    }
    // Fallback to canonical dev leader profile for standalone dev/testing
    return DevDindiIdentityProvider.sanketProfileId;
  }

  @override
  String get currentLeaderName {
    final profile = AuthService().currentProfile;
    if (profile != null && profile['display_name'] != null && profile['display_name'].toString().isNotEmpty) {
      return profile['display_name'].toString();
    }
    return 'Dindi Leader';
  }

  @override
  String get currentLeaderPhone {
    final profile = AuthService().currentProfile;
    if (profile != null && profile['phone'] != null) {
      return profile['phone'].toString();
    }
    return '';
  }
}

/// Development-only identity provider supplying Sanket's deterministic profile UUID.
class DevDindiIdentityProvider implements DindiIdentityProvider {
  const DevDindiIdentityProvider();

  /// Sanket's canonical development profile UUID per `AGENT_DATABASE_CONTRACT.md`.
  static const String sanketProfileId = '00000000-0000-0000-0000-000000000002';

  @override
  String get currentUserId => sanketProfileId;

  @override
  String get currentLeaderName => 'Sanket Patil';

  @override
  String get currentLeaderPhone => '+91 98220 12345';
}
