import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_announcement.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_group.dart';
import 'package:maza_pandurang/modules/dindi/models/dindi_member.dart';
import 'package:maza_pandurang/modules/dindi/repositories/dindi_repository.dart';
import 'package:maza_pandurang/modules/dindi/screens/create_dindi_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/dindi_dashboard_screen.dart';
import 'package:maza_pandurang/modules/dindi/screens/my_dindis_screen.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_identity_provider.dart';
import 'package:maza_pandurang/modules/dindi/services/dindi_state_service.dart';

class FakeDindiRepository implements DindiRepository {
  List<DindiGroup> dindisList = [];
  bool shouldThrowError = false;

  @override
  Future<List<DindiGroup>> getDindis({String? leaderUserId}) async {
    if (shouldThrowError) {
      throw Exception('Server unreachable');
    }
    return List.from(dindisList);
  }

  @override
  Future<DindiGroup?> getDindiById(String id) async {
    return dindisList.cast<DindiGroup?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<DindiGroup> createDindi(DindiGroup dindi) async {
    final created = dindi.id.isEmpty
        ? dindi.copyWith(id: 'dindi-${DateTime.now().millisecondsSinceEpoch}')
        : dindi;
    dindisList.add(created);
    return created;
  }

  @override
  Future<DindiGroup> updateDindi(DindiGroup dindi) async {
    final index = dindisList.indexWhere((d) => d.id == dindi.id);
    if (index != -1) {
      dindisList[index] = dindi;
    }
    return dindi;
  }

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
  late FakeDindiRepository fakeRepo;
  late DindiStateService service;

  setUp(() {
    fakeRepo = FakeDindiRepository();
    service = DindiStateService(
      repository: fakeRepo,
      identityProvider: const DevDindiIdentityProvider(),
    );
  });

  group('MyDindisScreen — Multi-Dindi Management Tests', () {
    testWidgets('renders multiple Dindis returned by repository',
        (WidgetTester tester) async {
      fakeRepo.dindisList = [
        const DindiGroup(
          id: '00000000-0000-0000-0000-000000000010',
          name: 'Alka Talkies Dindi #1',
          dindiNumber: 'DND-001',
          leaderName: 'Sanket Patil',
          leaderPhone: '+91 98220 12345',
          startPoint: 'Alandi',
          destination: 'Pandharpur',
          currentHalt: 'Saswad Market',
          roadStatus: 'Clear & Moving',
          joinCode: 'DND123',
          leaderUserId: '00000000-0000-0000-0000-000000000002',
        ),
        const DindiGroup(
          id: '00000000-0000-0000-0000-000000000011',
          name: 'Mauli Swaranand Dindi #45',
          dindiNumber: 'DND-002',
          leaderName: 'Sanket Patil',
          leaderPhone: '+91 98220 12345',
          startPoint: 'Pune',
          destination: 'Pandharpur',
          currentHalt: 'Hadapsar',
          roadStatus: 'Slow',
          joinCode: 'DND456',
          leaderUserId: '00000000-0000-0000-0000-000000000002',
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: MyDindisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Dindis'), findsOneWidget);
      expect(find.textContaining('Leader: Sanket Patil'), findsOneWidget);
      expect(find.text('Alka Talkies Dindi #1'), findsOneWidget);
      expect(find.text('Mauli Swaranand Dindi #45'), findsOneWidget);
      expect(find.text('No. DND-001'), findsOneWidget);
      expect(find.text('No. DND-002'), findsOneWidget);
      expect(find.text('DND123'), findsOneWidget);
      expect(find.text('DND456'), findsOneWidget);
    });

    testWidgets('shows empty state when no Dindis exist with create action',
        (WidgetTester tester) async {
      fakeRepo.dindisList = [];

      await tester.pumpWidget(
        const MaterialApp(
          home: MyDindisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Dindis Registered Yet'), findsOneWidget);
      expect(find.text('Register New Dindi'), findsOneWidget);

      // Tapping Register New Dindi opens CreateDindiScreen
      await tester.tap(find.text('Register New Dindi'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateDindiScreen), findsOneWidget);
    });

    testWidgets('shows error state with retry when backend fails',
        (WidgetTester tester) async {
      fakeRepo.shouldThrowError = true;

      await tester.pumpWidget(
        const MaterialApp(
          home: MyDindisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Dindis'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);
      // Verify no fake fallback data is displayed
      expect(find.text('Shree Tukaram Maharaj Dindi'), findsNothing);

      // Fix error and tap retry
      fakeRepo.shouldThrowError = false;
      fakeRepo.dindisList = [
        const DindiGroup(
          id: 'dindi-recovered',
          name: 'Recovered Dindi Procession',
          dindiNumber: 'REC-01',
          leaderName: 'Sanket Patil',
          leaderPhone: '+91 98220 12345',
          startPoint: 'Alandi',
          destination: 'Pandharpur',
          currentHalt: 'Pune',
          roadStatus: 'Clear & Moving',
          joinCode: 'REC001',
        )
      ];

      await tester.tap(find.text('Retry Connection'));
      await tester.pumpAndSettle();

      expect(find.text('Recovered Dindi Procession'), findsOneWidget);
    });

    testWidgets('selecting Dindi sets selectedDindiId and opens Dashboard',
        (WidgetTester tester) async {
      fakeRepo.dindisList = [
        const DindiGroup(
          id: '00000000-0000-0000-0000-000000000010',
          name: 'Alka Talkies Dindi #1',
          dindiNumber: 'DND-001',
          leaderName: 'Sanket Patil',
          leaderPhone: '+91 98220 12345',
          startPoint: 'Alandi',
          destination: 'Pandharpur',
          currentHalt: 'Saswad Market',
          roadStatus: 'Clear & Moving',
          joinCode: 'DND123',
          leaderUserId: '00000000-0000-0000-0000-000000000002',
        ),
        const DindiGroup(
          id: '00000000-0000-0000-0000-000000000011',
          name: 'Mauli Swaranand Dindi #45',
          dindiNumber: 'DND-002',
          leaderName: 'Sanket Patil',
          leaderPhone: '+91 98220 12345',
          startPoint: 'Pune',
          destination: 'Pandharpur',
          currentHalt: 'Hadapsar',
          roadStatus: 'Slow',
          joinCode: 'DND456',
          leaderUserId: '00000000-0000-0000-0000-000000000002',
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: MyDindisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the second Dindi (Mauli Swaranand Dindi #45)
      await tester.tap(find.text('Mauli Swaranand Dindi #45'));
      await tester.pumpAndSettle();

      // Verify dashboard opens with Dindi #45 data
      expect(find.byType(DindiDashboardScreen), findsOneWidget);
      expect(service.selectedDindiId,
          equals('00000000-0000-0000-0000-000000000011'));
      expect(find.text('Mauli Swaranand Dindi #45'), findsOneWidget);
      expect(find.textContaining('Dindi No. DND-002'), findsOneWidget);
      expect(find.text('DND456'), findsOneWidget);
      expect(find.text('Hadapsar'), findsOneWidget);
      expect(find.text('Slow'), findsOneWidget);
    });
  });
}
