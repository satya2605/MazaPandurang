import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/ngo/models/ngo_organization.dart';
import 'package:maza_pandurang/modules/ngo/models/ngo_service.dart';
import 'package:maza_pandurang/modules/ngo/models/service_report.dart';
import 'package:maza_pandurang/modules/ngo/ngo_module.dart';
import 'package:maza_pandurang/modules/ngo/screens/ngo_registration_screen.dart';
import 'package:maza_pandurang/modules/ngo/screens/service_detail_screen.dart';
import 'package:maza_pandurang/modules/ngo/screens/service_form_screen.dart';
import 'package:maza_pandurang/modules/ngo/services/ngo_repository.dart';

void main() {
  late NgoRepository repo;

  setUp(() {
    repo = NgoRepository();
    repo.resetForTesting();
  });

  group('NGO Module Mandatory Test Suite (17 Checks)', () {
    // 1. NGO dashboard renders
    testWidgets('1. NGO dashboard renders header, banner and metrics',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('NGO Seva Dashboard'), findsOneWidget);
      expect(find.text('Shree Sant Tukaram Seva Trust'), findsOneWidget);
      expect(find.text('Verified NGO Partner (Approved)'), findsOneWidget);
      expect(find.text('Seva Services'), findsOneWidget);
    });

    // 2. Registration validation works
    testWidgets('2. Registration validation works on empty fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NgoRegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure button is scrolled into view before tapping
      final submitBtn = find.text('Submit NGO Registration');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Enter NGO Name'), findsOneWidget);
      expect(find.text('Enter Registration No.'), findsOneWidget);
    });

    // 3. Registration creates PENDING state
    testWidgets('3. Registration creates PENDING state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NgoRegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'New Wari Seva');
      await tester.enterText(textFields.at(1), 'REG-9999');
      await tester.enterText(textFields.at(2), 'Ramesh Patil');
      await tester.enterText(textFields.at(3), '9876543210');
      await tester.enterText(textFields.at(4), 'wari@seva.org');

      final submitBtn = find.text('Submit NGO Registration');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(repo.organization.name, 'New Wari Seva');
      expect(repo.organization.approvalStatus, NgoApprovalStatus.pending);
    });

    // 4. Approval state changes in demo mode
    testWidgets('4. Approval state changes in demo mode toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.organization.approvalStatus, NgoApprovalStatus.approved);

      await tester.tap(find.text('Demo Toggle'));
      await tester.pumpAndSettle();

      expect(repo.organization.approvalStatus, NgoApprovalStatus.pending);
      expect(find.text('Approval Pending (Under Review)'), findsOneWidget);
    });

    // 5. Services render
    testWidgets('5. Services render in list on dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.text('Vitthal Seva Annachhatra (Free Meals)'), findsOneWidget);
      expect(find.text('Mauli Medical & First Aid Camp'), findsOneWidget);
    });

    // 6. Service has unique stable ID
    test('6. Services have unique stable IDs', () {
      final ids = repo.services.map((s) => s.id).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, uniqueIds.length);
      expect(ids.first, isNotEmpty);
    });

    // 7. Editing service preserves serviceId
    test('7. Editing service preserves serviceId', () {
      final originalService = repo.services.first;
      final originalId = originalService.id;

      final updatedService = originalService.copyWith(
        name: 'Updated Annachhatra Seva Name',
      );

      repo.updateService(updatedService);

      final resultService = repo.services.firstWhere((s) => s.id == originalId);
      expect(resultService.id, originalId);
      expect(resultService.name, 'Updated Annachhatra Seva Name');
    });

    // 8. Adding a service works
    testWidgets('8. Adding a service works via ServiceFormScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
          find.bySemanticsLabel('Service Name *'), 'Fresh Water Seva');
      await tester.enterText(
          find.bySemanticsLabel('Description / Facilities Offered *'),
          'Clean drinking water distribution point.');
      await tester.enterText(
          find.bySemanticsLabel('Location / Landmark Address *'),
          'Pandharpur Station');
      await tester.enterText(
          find.bySemanticsLabel('Service Capacity'), '5000 Litres');
      await tester.enterText(
          find.bySemanticsLabel('Operating Hours'), '24x7 Open');

      final publishBtn =
          find.widgetWithText(ElevatedButton, 'Publish Seva Service');
      await tester.ensureVisible(publishBtn);
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      final added =
          repo.services.firstWhere((s) => s.name == 'Fresh Water Seva');
      expect(added, isNotNull);
      expect(added.capacity, '5000 Litres');
    });

    // 9. Editing a service works
    testWidgets('9. Editing a service works', (WidgetTester tester) async {
      final serviceToEdit = repo.services.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceFormScreen(serviceToEdit: serviceToEdit),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
          find.bySemanticsLabel('Service Name *'), 'Modified Seva Name');

      final updateBtn =
          find.widgetWithText(ElevatedButton, 'Update Service Details');
      await tester.ensureVisible(updateBtn);
      await tester.tap(updateBtn);
      await tester.pumpAndSettle();

      expect(repo.services.firstWhere((s) => s.id == serviceToEdit.id).name,
          'Modified Seva Name');
    });

    // 10. Availability changes
    test('10. Service availability changes', () {
      final targetId = repo.services.first.id;
      expect(repo.services.first.availability, ServiceAvailability.available);

      repo.updateServiceAvailability(targetId, ServiceAvailability.limited);
      expect(repo.services.first.availability, ServiceAvailability.limited);

      repo.updateServiceAvailability(targetId, ServiceAvailability.unavailable);
      expect(repo.services.first.availability, ServiceAvailability.unavailable);
    });

    // 11. lastUpdatedAt changes
    test('11. lastUpdatedAt timestamp changes on update', () async {
      final target = repo.services.first;
      final oldTimestamp = target.lastUpdatedAt;

      await Future.delayed(const Duration(milliseconds: 20));
      repo.updateServiceAvailability(target.id, ServiceAvailability.limited);

      final newTimestamp =
          repo.services.firstWhere((s) => s.id == target.id).lastUpdatedAt;
      expect(newTimestamp.isAfter(oldTimestamp), isTrue);
    });

    // 12. Service details render
    testWidgets('12. Service details render correctly',
        (WidgetTester tester) async {
      final service = repo.services.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: service),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(service.name), findsWidgets);
      expect(find.text('Live Availability Status'), findsOneWidget);
      expect(find.text('Location & Coordinates'), findsOneWidget);
    });

    // 13. Report dialog opens
    testWidgets('13. Report dialog opens from service details',
        (WidgetTester tester) async {
      final service = repo.services.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: service),
        ),
      );
      await tester.pumpAndSettle();

      final reportBtn = find.text('Report Incorrect Information').last;
      await tester.ensureVisible(reportBtn);
      await tester.tap(reportBtn);
      await tester.pumpAndSettle();

      expect(find.text('Report Incorrect Information'), findsWidgets);
      expect(find.text('Reason for Report'), findsOneWidget);
    });

    // 14. Report submission works
    test('14. Report submission works in repository', () {
      final initialCount = repo.reports.length;

      repo.submitReport(
        serviceId: 'srv-001',
        serviceName: 'Test Service',
        reporterName: 'Test User',
        reason: ReportReason.incorrectLocation,
        comments: 'Location marker is 500m off',
      );

      expect(repo.reports.length, initialCount + 1);
      expect(repo.reports.first.comments, 'Location marker is 500m off');
    });

    // 15. Report count updates
    testWidgets('15. Dashboard report count metric updates on new report',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      final initialReportCount = repo.reports.length;

      repo.submitReport(
        serviceId: 'srv-001',
        serviceName: 'Test Service',
        reporterName: 'Test User',
        reason: ReportReason.wrongAvailability,
        comments: 'Food exhausted early',
      );

      await tester.pumpAndSettle();
      expect(repo.reports.length, initialReportCount + 1);
      expect(find.text('${initialReportCount + 1}'), findsWidgets);
    });

    // 16. Navigation works
    testWidgets('16. Navigation from dashboard to forms and details works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Add Service
      await tester.tap(find.byIcon(Icons.add_location_alt));
      await tester.pumpAndSettle();
      expect(find.text('Add New Seva Service'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('NGO Seva Dashboard'), findsOneWidget);
    });

    // 17. Empty service state does not crash
    testWidgets('17. Empty service state renders safely without crash',
        (WidgetTester tester) async {
      // Clear all services
      for (final s in List.from(repo.services)) {
        repo.deleteService(s.id);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Seva Services Found'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // Total services count is 0
    });
  });
}
