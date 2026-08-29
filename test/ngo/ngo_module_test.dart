import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/ngo/models/ngo_service.dart';
import 'package:maza_pandurang/modules/ngo/ngo_module.dart';
import 'package:maza_pandurang/modules/ngo/services/ngo_mock_data.dart';
import 'package:maza_pandurang/modules/ngo/services/ngo_repository.dart';

void main() {
  setUp(() {
    // Reset repository state before each test
    NgoRepository()
        .setApprovalStatus(NgoMockData.defaultOrganization.approvalStatus);
  });

  group('NGO Module Functional & Widget Tests', () {
    testWidgets('NGO Dashboard renders header, metrics, and demo services',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );

      expect(find.text('NGO Seva Dashboard'), findsOneWidget);
      expect(find.text('Shree Sant Tukaram Seva Trust'), findsOneWidget);
      expect(find.text('Verified NGO Partner (Approved)'), findsOneWidget);
      expect(
          find.text('Vitthal Seva Annachhatra (Free Meals)'), findsOneWidget);
      expect(find.text('Mauli Medical & First Aid Camp'), findsOneWidget);
    });

    testWidgets('Toggling Demo Approval Status updates banner',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );

      expect(find.text('Verified NGO Partner (Approved)'), findsOneWidget);

      await tester.tap(find.text('Demo Toggle'));
      await tester.pumpAndSettle();

      expect(find.text('Approval Pending (Under Review)'), findsOneWidget);
    });

    testWidgets('Dynamic service availability state toggle updates repository',
        (WidgetTester tester) async {
      final repo = NgoRepository();
      final serviceId = repo.services.first.id;

      expect(repo.services.first.availability, ServiceAvailability.available);

      repo.updateServiceAvailability(
          serviceId, ServiceAvailability.unavailable);

      expect(repo.services.first.availability, ServiceAvailability.unavailable);
    });

    testWidgets('Navigates to ServiceFormScreen on Add Service tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_location_alt));
      await tester.pumpAndSettle();

      expect(find.text('Add New Seva Service'), findsOneWidget);
      expect(find.text('Service Name *'), findsOneWidget);
    });

    testWidgets(
        'Navigates to ServiceDetailScreen and opens Report Incorrect dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );

      final viewButton = find.text('View').first;
      await tester.ensureVisible(viewButton);
      await tester.pumpAndSettle();

      await tester.tap(viewButton);
      await tester.pumpAndSettle();

      expect(find.text('Live Availability Status'), findsOneWidget);
      expect(find.text('Report Incorrect Information'), findsWidgets);

      final reportButton = find.text('Report Incorrect Information').last;
      await tester.ensureVisible(reportButton);
      await tester.pumpAndSettle();

      await tester.tap(reportButton);
      await tester.pumpAndSettle();

      expect(find.text('Reason for Report'), findsOneWidget);
      expect(find.text('Submit Report'), findsOneWidget);
    });
  });
}
