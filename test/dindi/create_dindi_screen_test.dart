import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_announcement.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_group.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_member.dart';
import 'package:maza_pandurang/modules/dindi/repositories/dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/repositories/supabase_dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/screens/create_dindi_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_identity_provider.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_state_service.dart';

class MockCreateDindiRepository implements DindiRepository {
  List<DindiGroup> dindis = [];
  bool throwDuplicateConflict = false;

  @override
  Future<List<DindiGroup>> getDindis({String? leaderUserId}) async => dindis;

  @override
  Future<DindiGroup?> getDindiById(String id) async => null;

  @override
  Future<DindiGroup> createDindi(DindiGroup dindi) async {
    if (throwDuplicateConflict) {
      throw const DindiRepositoryException(
        'Dindi Number already exists. Please choose a unique value.',
        statusCode: 409,
      );
    }
    final created = dindi.copyWith(
      id: '00000000-0000-0000-0000-000000000099',
    );
    dindis.add(created);
    return created;
  }

  @override
  Future<DindiGroup> updateDindi(DindiGroup dindi) async => dindi;

  @override
  Future<List<DindiMember>> getMembers(String dindiId) async => [];

  @override
  Future<void> updateMemberStatus(
      String memberId, DindiMemberStatus status) async {}

  @override
  Future<void> removeMember(String memberId) async {}

  @override
  Future<List<DindiAnnouncement>> getAnnouncements(String dindiId) async => [];

  @override
  Future<void> addAnnouncement(DindiAnnouncement announcement) async {}

  @override
  Future<bool> updateDindiLocation(
    String dindiId, {
    required double latitude,
    required double longitude,
    String? locationName,
    String? currentHalt,
  }) async => true;

  @override
  Future<bool> addDindiHalt(String dindiId, Map<String, dynamic> haltData) async => true;

  @override
  Future<bool> updateDindiHalt(String haltId, Map<String, dynamic> haltData) async => true;

  @override
  Future<bool> deleteDindiHalt(String haltId) async => true;
}

void main() {
  late MockCreateDindiRepository mockRepo;
  late DindiStateService service;

  setUp(() {
    mockRepo = MockCreateDindiRepository();
    service = DindiStateService(
      repository: mockRepo,
      identityProvider: const DevDindiIdentityProvider(),
    );
  });

  group('CreateDindiScreen Tests', () {
    testWidgets('renders all required application form fields and storage bucket upload cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateDindiScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dindi Registration Application'), findsOneWidget);
      expect(find.textContaining('Submitting as leader: Sanket Patil'),
          findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'Dindi Name *'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Dindi Number / Sequence *'),
          findsOneWidget);
      expect(find.text('Leader Profile Photo *'), findsOneWidget);
      expect(find.text('Bucket: profile-images'), findsOneWidget);
      expect(find.text('Registration Document *'), findsOneWidget);
      expect(find.text('Bucket: dindi-documents'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Origin *'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'Destination *'), findsOneWidget);
      expect(find.text('Submit Dindi Registration Application'), findsOneWidget);
    });

    testWidgets('validates required fields before submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateDindiScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap submit with empty required fields
      await tester.ensureVisible(find.text('Submit Dindi Registration Application'));
      await tester.tap(find.text('Submit Dindi Registration Application'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter Dindi name'), findsOneWidget);
      expect(find.text('Please enter Dindi number'), findsOneWidget);
    });

    testWidgets(
        'successful submission adds Dindi application to state, selects it, and opens Dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateDindiScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dindi Name *'),
        'Shree Sant Sopankaka Dindi',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dindi Number / Sequence *'),
        'SP-10',
      );

      // Submit
      await tester.ensureVisible(find.text('Submit Dindi Registration Application'));
      await tester.tap(find.text('Submit Dindi Registration Application'));
      await tester.pumpAndSettle();

      // Verify dashboard opened for the new Dindi application
      expect(find.byType(DindiDashboardScreen), findsOneWidget);
      expect(service.selectedDindiId,
          equals('00000000-0000-0000-0000-000000000099'));
      expect(find.text('Shree Sant Sopankaka Dindi'), findsOneWidget);
      expect(find.textContaining('Dindi No. SP-10'), findsOneWidget);
    });

    testWidgets(
        'conflict/failure stays on form and displays real error without fake success',
        (WidgetTester tester) async {
      mockRepo.throwDuplicateConflict = true;

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateDindiScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dindi Name *'),
        'Duplicate Dindi',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dindi Number / Sequence *'),
        '12',
      );

      await tester.ensureVisible(find.text('Submit Dindi Registration Application'));
      await tester.tap(find.text('Submit Dindi Registration Application'));
      await tester.pumpAndSettle();

      // Verify remained on CreateDindiScreen
      expect(find.byType(CreateDindiScreen), findsOneWidget);
      expect(
          find.textContaining('Dindi Number already exists'), findsOneWidget);
    });
  });
}
