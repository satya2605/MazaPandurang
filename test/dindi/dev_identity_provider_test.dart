import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_identity_provider.dart';

void main() {
  group('DevDindiIdentityProvider Tests', () {
    test('provides canonical development UUID for Sanket', () {
      const provider = DevDindiIdentityProvider();

      expect(
        provider.currentUserId,
        equals('00000000-0000-0000-0000-000000000002'),
      );
      expect(
        DevDindiIdentityProvider.sanketProfileId,
        equals('00000000-0000-0000-0000-000000000002'),
      );
    });

    test('provides leader name and phone without hardcoding in screens', () {
      const provider = DevDindiIdentityProvider();

      expect(provider.currentLeaderName, isNotEmpty);
      expect(provider.currentLeaderPhone, isNotEmpty);
    });
  });
}
