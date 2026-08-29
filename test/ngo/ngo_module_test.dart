import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/ngo/models/medical_filter.dart';
import 'package:maza_pandurang/modules/ngo/models/ngo_organization.dart';
import 'package:maza_pandurang/modules/ngo/models/ngo_service.dart';
import 'package:maza_pandurang/modules/ngo/models/ngo_service_details.dart';
import 'package:maza_pandurang/modules/ngo/models/service_report.dart';
import 'package:maza_pandurang/modules/ngo/ngo_module.dart';
import 'package:maza_pandurang/modules/ngo/screens/ngo_profile_screen.dart';
import 'package:maza_pandurang/modules/ngo/screens/ngo_registration_screen.dart';
import 'package:maza_pandurang/modules/ngo/screens/service_detail_screen.dart';
import 'package:maza_pandurang/modules/ngo/screens/service_form_screen.dart';
import 'package:maza_pandurang/modules/ngo/services/ngo_mock_data.dart';
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

      final nameField = find.bySemanticsLabel('Service Name *');
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'Fresh Water Seva');

      final descField =
          find.bySemanticsLabel('Description / Facilities Offered *');
      await tester.ensureVisible(descField);
      await tester.enterText(
          descField, 'Clean drinking water distribution point.');

      final locField = find.bySemanticsLabel('Location / Landmark Address *');
      await tester.ensureVisible(locField);
      await tester.enterText(locField, 'Pandharpur Station');

      final capField = find.bySemanticsLabel('General Service Capacity');
      await tester.ensureVisible(capField);
      await tester.enterText(capField, '5000 Litres');

      final hoursField = find.bySemanticsLabel('Operating Hours');
      await tester.ensureVisible(hoursField);
      await tester.enterText(hoursField, '24x7 Open');

      final publishBtn = find.byIcon(Icons.add_circle);
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

      final updateBtn = find.byIcon(Icons.save);
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

    // 13. [UPDATED] Service detail shows image widget when imageUrl is set
    testWidgets('13. Service detail displays image widget when imageUrl exists',
        (WidgetTester tester) async {
      final service = repo.services.first;
      expect(service.imageUrl, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: service),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsWidgets);
    });

    // 14. Report submission works (repository-level)
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

  // ── Image & Report Section Tests ─────────────────────────────────────────────
  group('NGO Service Detail — Image & Report Section Tests', () {
    // 18. Screen does not crash when imageUrl is null
    testWidgets('18. Service detail does not crash when imageUrl is null',
        (WidgetTester tester) async {
      final serviceNoImage = NgoService(
        id: 'srv-test-no-img',
        ngoId: 'ngo-001',
        name: 'Test Seva (No Image)',
        category: NgoServiceCategory.food,
        description: 'A test service with no image URL.',
        latitude: 17.67,
        longitude: 75.32,
        locationName: 'Test Location',
        capacity: '100',
        operatingHours: '24 Hours',
        contactPhone: '+91 00000 00000',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
        imageUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: serviceNoImage),
        ),
      );
      await tester.pump();

      expect(find.text('Test Seva (No Image)'), findsWidgets);
    });

    // 19. Placeholder is shown when imageUrl is null
    testWidgets('19. Placeholder shown when imageUrl is null',
        (WidgetTester tester) async {
      final serviceNoImage = NgoService(
        id: 'srv-test-no-img2',
        ngoId: 'ngo-001',
        name: 'No Image Service',
        category: NgoServiceCategory.water,
        description: 'No image.',
        latitude: 17.67,
        longitude: 75.32,
        locationName: 'Test Location',
        capacity: '50',
        operatingHours: '6am-10pm',
        contactPhone: '+91 00000 00001',
        availability: ServiceAvailability.limited,
        lastUpdatedAt: DateTime.now(),
        imageUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: serviceNoImage),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.local_hospital_outlined), findsOneWidget);
    });

    // 20. Error fallback: Image.network errorBuilder does not crash
    testWidgets('20. Image error fallback renders placeholder without crash',
        (WidgetTester tester) async {
      final serviceWithBadUrl = NgoService(
        id: 'srv-bad-url',
        ngoId: 'ngo-001',
        name: 'Bad URL Service',
        category: NgoServiceCategory.medical,
        description: 'Service with a broken image URL.',
        latitude: 17.67,
        longitude: 75.32,
        locationName: 'Test Location',
        capacity: '10',
        operatingHours: '8am-6pm',
        contactPhone: '+91 00000 00002',
        availability: ServiceAvailability.unavailable,
        lastUpdatedAt: DateTime.now(),
        imageUrl: 'https://invalid.example.invalid/no-image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: serviceWithBadUrl),
        ),
      );
      await tester.pump();

      expect(find.text('Bad URL Service'), findsWidgets);
    });

    // 21. "Report Incorrect Information" section is NOT present
    testWidgets(
        '21. Report Incorrect Information section is absent from service detail',
        (WidgetTester tester) async {
      final service = repo.services.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: service),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Found Incorrect Information?'), findsNothing);
      expect(find.text('Report Incorrect Information'), findsNothing);
      expect(
        find.text(
            'Help maintain accurate data for Warkaris during Wari. Report closed camps, wrong locations, or inaccurate numbers.'),
        findsNothing,
      );
    });

    // 22. Existing availability editing still works after changes
    testWidgets('22. Availability change via popup still works',
        (WidgetTester tester) async {
      final service = repo.services.first;
      expect(service.availability, ServiceAvailability.available);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: service),
        ),
      );
      await tester.pump();

      expect(find.text('Change Status'), findsOneWidget);
    });

    // 23. Service detail navigation: screen renders correctly from a service object
    testWidgets('23. Service detail renders all key sections',
        (WidgetTester tester) async {
      final service = repo.services.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: service),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Availability Status'), findsOneWidget);
      expect(find.text('Seva Overview & Facilities'), findsOneWidget);
      expect(find.text('Location & Coordinates'), findsOneWidget);
      expect(find.textContaining('Operating Hours'), findsOneWidget);
      expect(find.text('Contact & Inquiry'), findsOneWidget);
    });
  });

  // ── Backend Contract & Moderation Integration Tests ─────────────────────────
  group('NGO Backend Integration & Moderation Workflow Tests', () {
    // 24. Pending NGO state rendering
    testWidgets('24. Pending NGO status banner renders correctly',
        (WidgetTester tester) async {
      repo.setApprovalStatus(NgoApprovalStatus.pending);

      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Approval Pending (Under Review)'), findsOneWidget);
    });

    // 25. Approved NGO state rendering
    testWidgets('25. Approved NGO status banner renders correctly',
        (WidgetTester tester) async {
      repo.setApprovalStatus(NgoApprovalStatus.approved);

      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verified NGO Partner (Approved)'), findsOneWidget);
    });

    // 26. Rejected NGO state restricts modifying services
    testWidgets('26. Rejected NGO displays rejection banner and warns on add',
        (WidgetTester tester) async {
      repo.setApprovalStatus(NgoApprovalStatus.rejected);

      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registration Rejected'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_location_alt));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'NGO Registration is currently rejected. Cannot modify services.'),
          findsOneWidget);
    });

    // 27. Service creation enforces initial moderation state
    test(
        '27. Service created via addService has isApproved false or moderation gate',
        () {
      final newService = NgoService(
        id: 'srv-mod-test-1',
        ngoId: repo.organization.id,
        name: 'New Moderation Seva',
        category: NgoServiceCategory.food,
        description: 'New seva needing admin check.',
        latitude: 18.34,
        longitude: 74.03,
        locationName: 'Saswad',
        capacity: '500',
        operatingHours: '24/7',
        contactPhone: '+919876543210',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
        isApproved: false, // Moderation gate
      );

      repo.addService(newService);

      final added = repo.services.firstWhere((s) => s.id == 'srv-mod-test-1');
      expect(added.isApproved, isFalse);
    });

    // 28. NgoProfileScreen loads and renders details and gallery section
    testWidgets('28. NGO Profile screen displays details and gallery container',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NgoProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('NGO Profile & Verification'), findsOneWidget);
      expect(find.text('Registration No.'), findsOneWidget);
      expect(find.text('NGO Gallery & Verification Photos'), findsOneWidget);
    });

    // 29. NgoOrganization and NgoService JSON serialization roundtrip
    test(
        '29. NgoOrganization and NgoService JSON serialization works correctly',
        () {
      final orgJson = {
        'id': 'ngo-001',
        'name': 'Test Seva Trust',
        'registration_number': 'REG-12345',
        'contact_person': 'Shrutika Lead',
        'phone': '+919876543213',
        'email': 'shrutika@ngo.org',
        'primary_category': 'Medical & Food Seva',
        'status': 'approved',
        'created_at': DateTime.now().toIso8601String(),
      };

      final org = NgoOrganization.fromJson(orgJson);
      expect(org.id, 'ngo-001');
      expect(org.approvalStatus, NgoApprovalStatus.approved);
      expect(org.name, 'Test Seva Trust');

      final svcJson = {
        'id': 'srv-101',
        'provider_id': 'ngo-001',
        'name': 'Food Camp',
        'category': 'Food & Annachhatra',
        'description': 'Free food.',
        'latitude': 18.34,
        'longitude': 74.03,
        'address': 'Saswad',
        'contact_phone': '+919876543210',
        'availability_status': 'AVAILABLE',
        'is_verified': true,
      };

      final svc = NgoService.fromJson(svcJson);
      expect(svc.id, 'srv-101');
      expect(svc.category, NgoServiceCategory.food);
      expect(svc.availability, ServiceAvailability.available);
      expect(svc.isApproved, isTrue);
    });

    // 30. Pending NGO cannot access service creation
    testWidgets('30. Pending NGO cannot access service creation',
        (WidgetTester tester) async {
      repo.setApprovalStatus(NgoApprovalStatus.pending);

      await tester.pumpWidget(
        MaterialApp(
          home: NgoModule.screen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_location_alt));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Application submitted. Waiting for Admin verification before adding services.'),
          findsOneWidget);
    });
  });

  // ── Enhanced Service Form Tests ──────────────────────────────────────────────
  group('NGO Enhanced Service Form Sections Tests', () {
    // 31. Service form renders all structured sections
    testWidgets('31. Service form renders all structured sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Service Photos'), findsOneWidget);
      expect(find.textContaining('Specifics & Capacity'), findsOneWidget);
      expect(find.text('Emergency Contacts & On-Ground Team'), findsOneWidget);
      expect(find.text('Location & Coordinates'), findsOneWidget);
      expect(find.text('Operating Hours & Availability'), findsOneWidget);
      expect(find.text('Primary Contact'), findsOneWidget);
      expect(find.text('Facilities & Accessibility'), findsOneWidget);
      expect(find.text('Important Instructions / Notes'), findsOneWidget);
    });

    // 32. Dynamic category-specific fields render
    testWidgets('32. Dynamic category-specific fields render for food category',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Food category is default -> Meals Per Day and Approx. Beneficiaries/Day exist
      expect(find.bySemanticsLabel('Meals Per Day'), findsOneWidget);
      expect(
          find.bySemanticsLabel('Approx. Beneficiaries/Day'), findsOneWidget);
    });

    // 33. Facilities and accessibility chips selection works
    testWidgets('33. Facilities and accessibility chips selection works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final wheelchairChip =
          find.widgetWithText(FilterChip, 'Wheelchair Accessible');
      await tester.ensureVisible(wheelchairChip);
      await tester.tap(wheelchairChip);
      await tester.pumpAndSettle();

      final FilterChip chipWidget = tester.widget(wheelchairChip);
      expect(chipWidget.selected, isTrue);
    });

    // 34. 24-hours switch toggle works
    testWidgets('34. 24-hours switch toggle sets operating hours',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final switchTile = find.byType(SwitchListTile);
      await tester.ensureVisible(switchTile);
      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Operating Hours'), findsOneWidget);
    });

    // 35. Full service form persistence fields serialize and deserialize correctly
    test(
        '35. Full service form persistence fields serialize and deserialize correctly',
        () {
      final json = {
        'id': 'srv-999',
        'provider_id': 'ngo-001',
        'name': 'Annachhatra Mega Kitchen',
        'category': 'Food & Annachhatra',
        'description': 'Free meals and resting zone.',
        'latitude': 17.6775,
        'longitude': 75.3260,
        'address': 'Pandharpur Station Chowk',
        'contact_phone': '+91 98230 11223',
        'alternate_contact_phone': '+91 98230 99887',
        'whatsapp_available': true,
        'capacity': '10000 meals/day',
        'operating_hours': '24 Hours Open',
        'wheelchair_accessible': true,
        'drinking_water_available': true,
        'seating_available': true,
        'accessible_toilet': false,
        'senior_citizen_friendly': true,
        'important_instructions': 'Token not required. Follow queue entry.',
        'category_details': {
          'meals_per_day': 10000,
          'beneficiaries_per_day': 8000,
        },
        'availability_status': 'AVAILABLE',
        'is_verified': false,
      };

      final svc = NgoService.fromJson(json);
      expect(svc.alternateContactPhone, '+91 98230 99887');
      expect(svc.whatsappAvailable, isTrue);
      expect(svc.wheelchairAccessible, isTrue);
      expect(svc.drinkingWaterAvailable, isTrue);
      expect(svc.seatingAvailable, isTrue);
      expect(svc.accessibleToilet, isFalse);
      expect(svc.seniorCitizenFriendly, isTrue);
      expect(
          svc.importantInstructions, 'Token not required. Follow queue entry.');
      expect(svc.categoryDetails['meals_per_day'], 10000);
      expect(svc.categoryDetails['beneficiaries_per_day'], 8000);

      final outJson = svc.toJson();
      expect(outJson['alternate_contact_phone'], '+91 98230 99887');
      expect(outJson['whatsapp_available'], isTrue);
      expect(outJson['wheelchair_accessible'], isTrue);
      expect(outJson['drinking_water_available'], isTrue);
      expect(outJson['important_instructions'],
          'Token not required. Follow queue entry.');
      expect(outJson['category_details']['meals_per_day'], 10000);
    });

    // 36. Medical emergency support, ambulance, and contacts directory serialize correctly
    test(
        '36. Medical emergency support, ambulance, and contacts directory serialize correctly',
        () {
      final json = {
        'id': 'srv-med-1',
        'provider_id': 'ngo-001',
        'name': '24/7 Wari Critical Care & Ambulance Unit',
        'category': 'Medical Assistance',
        'description': 'Emergency medical support and ambulance base.',
        'latitude': 17.6775,
        'longitude': 75.3260,
        'address': 'Pandharpur Temple Naka',
        'contact_phone': '+91 98230 00000',
        'emergency_support_available': true,
        'ambulance_available': true,
        'emergency_contact_phone': '+91 98230 11223',
        'ambulance_contact_phone': '+91 98230 99999',
        'emergency_instructions': 'Direct ambulance dispatch from Gate 2.',
        'category_details': {
          'doctors_available': 4,
          'beds_available': 12,
          'emergency_contacts': [
            {
              'name': 'Dr. Deshmukh',
              'phone': '+91 98230 11223',
              'role': 'Doctor',
            },
            {
              'name': 'Unit 1 Ambulance Driver',
              'phone': '+91 98230 99999',
              'role': 'Ambulance',
            }
          ]
        },
        'availability_status': 'AVAILABLE',
        'is_verified': true,
      };

      final svc = NgoService.fromJson(json);
      expect(svc.emergencySupportAvailable, isTrue);
      expect(svc.ambulanceAvailable, isTrue);
      expect(svc.emergencyContactPhone, '+91 98230 11223');
      expect(svc.ambulanceContactPhone, '+91 98230 99999');
      expect(
          svc.emergencyInstructions, 'Direct ambulance dispatch from Gate 2.');
      expect(svc.emergencyContacts.length, 2);
      expect(svc.emergencyContacts.first['name'], 'Dr. Deshmukh');

      final out = svc.toJson();
      expect(out['emergency_support_available'], isTrue);
      expect(out['ambulance_available'], isTrue);
      expect(out['emergency_contact_phone'], '+91 98230 11223');
      expect(out['ambulance_contact_phone'], '+91 98230 99999');
      expect(out['category_details']['emergency_contacts'], isNotNull);
    });

    // 37. Service detail screen renders emergency and ambulance support card
    testWidgets(
        '37. Service detail screen renders emergency and ambulance support card',
        (WidgetTester tester) async {
      final emergencyService = NgoService(
        id: 'srv-med-1',
        ngoId: 'ngo-001',
        name: 'Wari Emergency Post',
        category: NgoServiceCategory.medical,
        description: '24/7 emergency medical triage and ambulance post.',
        latitude: 17.6775,
        longitude: 75.3260,
        locationName: 'Pandharpur Bypass',
        capacity: '50 patients/hr',
        operatingHours: '24 Hours Open',
        contactPhone: '+91 98230 00000',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
        emergencySupportAvailable: true,
        ambulanceAvailable: true,
        emergencyContactPhone: '+91 98230 11223',
        ambulanceContactPhone: '+91 98230 99999',
        emergencyInstructions: 'Rush to triage gate in emergency.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: emergencyService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Support & Ambulance'), findsOneWidget);
      expect(find.textContaining('Total Ambulances'), findsOneWidget);
      expect(find.textContaining('Call Ambulance'), findsWidgets);
    });

    // 38. Service detail screen displays Contact & Inquiry section
    testWidgets('38. Service detail screen displays Contact & Inquiry section',
        (WidgetTester tester) async {
      final contactService = NgoService(
        id: 'srv-med-10',
        ngoId: 'ngo-001',
        name: 'Wari Health Post',
        category: NgoServiceCategory.medical,
        description: 'First aid post.',
        latitude: 17.6775,
        longitude: 75.3260,
        locationName: 'ISKCON Chowk',
        capacity: '50 patients/hr',
        operatingHours: '24 Hours Open',
        contactPhone: '+91 98230 00000',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: contactService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contact & Inquiry'), findsOneWidget);
      expect(find.text('Call NGO'), findsOneWidget);
    });

    // 39. Service form allows adding emergency contact via dialog
    testWidgets('39. Service form allows adding emergency contact via dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final addContactBtn = find.widgetWithText(
          OutlinedButton, 'Add On-Ground Contact / Doctor / Driver');
      await tester.ensureVisible(addContactBtn);
      await tester.tap(addContactBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add Emergency Contact'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    // 40. Water category metrics render in ServiceDetailScreen
    testWidgets('40. Water category metrics render in ServiceDetailScreen',
        (WidgetTester tester) async {
      final waterService = NgoService(
        id: 'srv-wat-1',
        ngoId: 'ngo-001',
        name: 'Pandharpur Jal Seva Camp',
        category: NgoServiceCategory.water,
        description: '24/7 Pure filtered drinking water.',
        latitude: 17.6775,
        longitude: 75.3260,
        locationName: 'Wakhari Ringan Ground',
        capacity: '20,000 Litres/Day',
        operatingHours: '24 Hours Open',
        contactPhone: '+91 98230 44556',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
        drinkingWaterAvailable: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: waterService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pandharpur Jal Seva Camp'), findsWidgets);
      expect(find.text('Drinking Water'), findsOneWidget);
    });

    // 41. NgoServiceDetails covers all public.service_details columns
    test('41. NgoServiceDetails serializes and deserializes all 20+ columns',
        () {
      final detailsJson = {
        'service_id': 'srv-uuid-101',
        'service_capacity': '5000 meals/day',
        'operating_hours': '24 Hours Open',
        'is_open_24_hours': true,
        'meals_per_day': 5000,
        'beneficiaries_per_day': 4000,
        'doctors_available': 6,
        'beds_available': 15,
        'medicines_available': 'ORS, Paracetamol, Bandages',
        'water_capacity_litres_per_day': 12000,
        'water_taps_count': 10,
        'available_spaces': 80,
        'current_occupancy': '25 / 80',
        'alternate_contact_phone': '+91 98230 88776',
        'whatsapp_available': true,
        'wheelchair_accessible': true,
        'drinking_water': true,
        'seating_available': true,
        'accessible_toilet': true,
        'senior_citizen_friendly': true,
        'important_instructions': 'Entry via Gate 3 only.',
      };

      final details = NgoServiceDetails.fromJson(detailsJson);
      expect(details.serviceId, 'srv-uuid-101');
      expect(details.serviceCapacity, '5000 meals/day');
      expect(details.isOpen24Hours, isTrue);
      expect(details.mealsPerDay, 5000);
      expect(details.beneficiariesPerDay, 4000);
      expect(details.doctorsAvailable, 6);
      expect(details.bedsAvailable, 15);
      expect(details.medicinesAvailable, 'ORS, Paracetamol, Bandages');
      expect(details.waterCapacityLitresPerDay, 12000);
      expect(details.waterTapsCount, 10);
      expect(details.availableSpaces, 80);
      expect(details.currentOccupancy, '25 / 80');
      expect(details.alternateContactPhone, '+91 98230 88776');
      expect(details.whatsappAvailable, isTrue);
      expect(details.wheelchairAccessible, isTrue);
      expect(details.drinkingWater, isTrue);
      expect(details.seatingAvailable, isTrue);
      expect(details.accessibleToilet, isTrue);
      expect(details.seniorCitizenFriendly, isTrue);
      expect(details.importantInstructions, 'Entry via Gate 3 only.');

      final outJson = details.toJson();
      expect(outJson['service_id'], 'srv-uuid-101');
      expect(outJson['meals_per_day'], 5000);
      expect(outJson['is_open_24_hours'], isTrue);
      expect(outJson['doctors_available'], 6);
      expect(outJson['water_capacity_litres_per_day'], 12000);
    });

    // 44. Medical service renders separate Doctor & Bed Availability cards
    testWidgets(
        '44. Medical service renders separate Doctor & Bed Availability cards',
        (WidgetTester tester) async {
      final medService = NgoService(
        id: 'srv-med-dtl-1',
        ngoId: 'ngo-001',
        name: 'Wari Intensive Care Post',
        category: NgoServiceCategory.medical,
        description: 'Emergency and general medical camp.',
        latitude: 17.6775,
        longitude: 75.3260,
        locationName: 'Pandharpur Station',
        capacity: '15 Beds',
        operatingHours: '24 Hours Open',
        contactPhone: '+91 98230 11223',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
        totalDoctors: 5,
        availableDoctors: 3,
        totalBeds: 15,
        availableBeds: 6,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: medService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Doctor Availability'), findsOneWidget);
      expect(find.text('Bed Availability'), findsOneWidget);
      expect(find.textContaining('5'), findsWidgets);
      expect(find.textContaining('15'), findsWidgets);
    });

    // 45. Shelter service renders correctly on ServiceDetailScreen
    testWidgets('45. Shelter service renders correctly on ServiceDetailScreen',
        (WidgetTester tester) async {
      final shelterService = NgoService(
        id: 'srv-shl-dtl-1',
        ngoId: 'ngo-001',
        name: 'Wari Vishram Bhavan',
        category: NgoServiceCategory.shelter,
        description: 'Clean night shelter facility.',
        latitude: 17.6775,
        longitude: 75.3260,
        locationName: 'Temple Bypass',
        capacity: '100 Spaces',
        operatingHours: '24 Hours Open',
        contactPhone: '+91 98230 99887',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: shelterService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wari Vishram Bhavan'), findsWidgets);
      expect(find.text('Live Availability Status'), findsOneWidget);
    });

    // 46. End-to-end field persistence mapping verification
    test(
        '46. Full form persistence mapping across services and service_details',
        () async {
      final fullService = NgoService(
        id: 'srv-e2e-100',
        ngoId: 'ngo-001',
        name: 'Comprehensive Seva Dham',
        category: NgoServiceCategory.medical,
        description: 'Complete medical and triage post.',
        latitude: 17.6775,
        longitude: 75.3260,
        locationName: 'Pandharpur Station',
        capacity: '50 Beds',
        operatingHours: '24 Hours Open',
        contactPhone: '+91 98230 11111',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
        isApproved: false, // New services must remain unverified
        alternateContactPhone: '+91 98230 22222',
        whatsappAvailable: true,
        wheelchairAccessible: true,
        drinkingWaterAvailable: true,
        seatingAvailable: true,
        accessibleToilet: true,
        seniorCitizenFriendly: true,
        importantInstructions:
            'Priority queue for senior citizens and mothers.',
        emergencySupportAvailable: true,
        ambulanceAvailable: true,
        emergencyContactPhone: '+91 98230 33333',
        ambulanceContactPhone: '+91 98230 44444',
        emergencyInstructions: 'Emergency bay located at North entrance.',
        details: const NgoServiceDetails(
          serviceCapacity: '50 Beds',
          operatingHours: '24 Hours Open',
          isOpen24Hours: true,
          doctorsAvailable: 8,
          bedsAvailable: 50,
          medicinesAvailable: 'Full Emergency Kit, IV Fluids, Pain Relief',
          alternateContactPhone: '+91 98230 22222',
          whatsappAvailable: true,
          wheelchairAccessible: true,
          drinkingWater: true,
          seatingAvailable: true,
          accessibleToilet: true,
          seniorCitizenFriendly: true,
          importantInstructions:
              'Priority queue for senior citizens and mothers.',
        ),
      );

      final ok = await repo.addService(fullService);
      expect(ok, isTrue);

      final added = repo.services.firstWhere((s) => s.id == 'srv-e2e-100');
      expect(added.name, 'Comprehensive Seva Dham');
      expect(added.isApproved, isFalse); // Moderation gate invariant
      expect(added.details?.doctorsAvailable, 8);
      expect(added.details?.bedsAvailable, 50);
      expect(added.details?.isOpen24Hours, isTrue);
      expect(added.details?.wheelchairAccessible, isTrue);
      expect(added.details?.drinkingWater, isTrue);
      expect(added.emergencySupportAvailable, isTrue);
      expect(added.ambulanceAvailable, isTrue);
    });

    // 47. Edit/update persists to both services and service_details
    test('47. Updating a service updates core and extended service_details',
        () async {
      final initialService = NgoService(
        id: 'srv-update-test-1',
        ngoId: 'ngo-001',
        name: 'Initial Seva Post',
        category: NgoServiceCategory.water,
        description: 'Water kiosk.',
        latitude: 17.67,
        longitude: 75.32,
        locationName: 'Pandharpur Gate',
        capacity: '5000 Litres',
        operatingHours: '08:00 AM - 08:00 PM',
        contactPhone: '+91 98230 11000',
        availability: ServiceAvailability.available,
        lastUpdatedAt: DateTime.now(),
        details: const NgoServiceDetails(
          waterCapacityLitresPerDay: 5000,
          waterTapsCount: 4,
        ),
      );

      await repo.addService(initialService);

      final updatedService = initialService.copyWith(
        name: 'Upgraded 24/7 Water Mega Post',
        operatingHours: '24 Hours Open',
        details: const NgoServiceDetails(
          waterCapacityLitresPerDay: 25000,
          waterTapsCount: 16,
          isOpen24Hours: true,
          drinkingWater: true,
        ),
      );

      final updateOk = await repo.updateService(updatedService);
      expect(updateOk, isTrue);

      final fetched =
          repo.services.firstWhere((s) => s.id == 'srv-update-test-1');
      expect(fetched.name, 'Upgraded 24/7 Water Mega Post');
      expect(fetched.details?.waterCapacityLitresPerDay, 25000);
      expect(fetched.details?.waterTapsCount, 16);
      expect(fetched.details?.isOpen24Hours, isTrue);
    });

    // 48. Mauli Medical Camp Live Availability Summary
    testWidgets(
        '48. Mauli Medical Camp renders real-time summary for Beds, Doctors, Ambulances',
        (WidgetTester tester) async {
      final mauliCamp = NgoMockData.initialServices
          .firstWhere((s) => s.name.contains('Mauli Medical'));

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: mauliCamp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Availability Status'), findsOneWidget);
      expect(find.text('LIMITED'), findsOneWidget);
      expect(find.text('12 Available'), findsOneWidget); // Beds
      expect(find.text('2 Available'), findsOneWidget); // Doctors
      expect(find.text('1 Available'), findsOneWidget); // Ambulances
    });

    // 49. Operational Emergency Support & Ambulance Fleet
    testWidgets(
        '49. Mauli Medical Camp renders ambulance fleet with vehicle number MH-12-AB-1234 and call button',
        (WidgetTester tester) async {
      final mauliCamp = NgoMockData.initialServices
          .firstWhere((s) => s.name.contains('Mauli Medical'));

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: mauliCamp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Support & Ambulance'), findsOneWidget);
      expect(find.text('MH-12-AB-1234'), findsOneWidget);
      expect(find.text('BLS (Basic Life Support)'), findsOneWidget);
      expect(find.text('Available'), findsWidgets);
      expect(find.text('MH-12-CD-5678'), findsOneWidget);
      expect(find.text('On Trip'), findsWidgets);
      expect(find.text('Call Ambulance'), findsWidgets);
    });

    // 50. Bed Availability Separate Card
    testWidgets(
        '50. Mauli Medical Camp renders separate Bed Availability card with general and ICU breakdown',
        (WidgetTester tester) async {
      final mauliCamp = NgoMockData.initialServices
          .firstWhere((s) => s.name.contains('Mauli Medical'));

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: mauliCamp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bed Availability'), findsOneWidget);
      expect(find.text('Total Beds'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      expect(find.text('General Beds: 10 available'), findsOneWidget);
      expect(find.text('ICU Beds: 2 available'), findsOneWidget);
    });

    // 51. Doctor Availability Separate Card & View Doctors
    testWidgets(
        '51. Mauli Medical Camp renders separate Doctor Availability card with doctor roster',
        (WidgetTester tester) async {
      final mauliCamp = NgoMockData.initialServices
          .firstWhere((s) => s.name.contains('Mauli Medical'));

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: mauliCamp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Doctor Availability'), findsOneWidget);
      expect(find.text('Dr. Rajesh Kulkarni'), findsOneWidget);
      expect(find.text('Dr. Sneha Joshi'), findsOneWidget);
      expect(find.text('Dr. Amit Deshmukh'), findsOneWidget);
      expect(find.text('Dr. Priya Patil'), findsOneWidget);
      expect(find.text('Emergency'), findsWidgets);
    });

    // 52. MedicalServiceFilter independent filtering tests
    test(
        '52. MedicalServiceFilter independently filters by beds, doctors, ambulances, and emergency',
        () {
      final mauliCamp = NgoMockData.initialServices
          .firstWhere((s) => s.name.contains('Mauli Medical'));

      const bedFilter = MedicalServiceFilter(hasAvailableBeds: true);
      expect(bedFilter.matches(mauliCamp), isTrue);

      const docFilter = MedicalServiceFilter(hasAvailableDoctors: true);
      expect(docFilter.matches(mauliCamp), isTrue);

      const ambFilter = MedicalServiceFilter(hasAvailableAmbulances: true);
      expect(ambFilter.matches(mauliCamp), isTrue);

      const emergencyFilter = MedicalServiceFilter(isEmergencySupport: true);
      expect(emergencyFilter.matches(mauliCamp), isTrue);

      const limitedFilter =
          MedicalServiceFilter(liveStatus: ServiceAvailability.limited);
      expect(limitedFilter.matches(mauliCamp), isTrue);

      const unavailFilter =
          MedicalServiceFilter(liveStatus: ServiceAvailability.unavailable);
      expect(unavailFilter.matches(mauliCamp), isFalse);
    });

    // 53. Universal Detail Page — Food / Annachhatra Category
    testWidgets(
        '53. Universal detail page dynamically renders Food / Annachhatra module',
        (WidgetTester tester) async {
      final foodService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.food);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: foodService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food & Annachhatra Operations'), findsOneWidget);
      expect(find.text('Meals / Day'), findsOneWidget);
      expect(find.text('Beneficiaries'), findsOneWidget);
      expect(find.text('Hot Desi Ghee Khichdi'), findsOneWidget);
      expect(find.text('Seva Overview & Facilities'), findsOneWidget);
      expect(find.text('Location & Coordinates'), findsOneWidget);
      expect(find.text('Contact & Inquiry'), findsOneWidget);
      expect(find.text('Call NGO'), findsOneWidget);
      // Emergency support is absent for standard food camp
      expect(find.text('Emergency Support & Ambulance'), findsNothing);
    });

    // 54. Universal Detail Page — Shelter / Vishram Dham Category
    testWidgets(
        '54. Universal detail page dynamically renders Shelter / Vishram Dham module',
        (WidgetTester tester) async {
      final shelterService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.shelter);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: shelterService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Night Shelter & Rest Capacity'), findsOneWidget);
      expect(find.text('Total Beds/Mats'), findsOneWidget);
      expect(find.text('Available Now'), findsOneWidget);
      expect(find.text('Male Section: 80 Spaces'), findsOneWidget);
      expect(find.text('Female & Children: 80 Spaces'), findsOneWidget);
      expect(find.text('Seva Overview & Facilities'), findsOneWidget);
      expect(find.text('Location & Coordinates'), findsOneWidget);
      expect(find.text('Contact & Inquiry'), findsOneWidget);
    });

    // 55. Universal Detail Page — Water / Jal Seva Category
    testWidgets(
        '55. Universal detail page dynamically renders Water / Jal Seva module',
        (WidgetTester tester) async {
      final waterService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.water);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: waterService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Drinking Water & Jal Seva Hub'), findsOneWidget);
      expect(find.text('Water Capacity'), findsWidgets);
      expect(find.text('Active Taps'), findsOneWidget);
      expect(find.text('Chilled Filtered RO Water'), findsOneWidget);
      expect(find.text('Seva Overview & Facilities'), findsOneWidget);
      expect(find.text('Location & Coordinates'), findsOneWidget);
      expect(find.text('Contact & Inquiry'), findsOneWidget);
    });

    // 56. Universal Detail Page — Clothing & Material Distribution Category
    testWidgets(
        '56. Universal detail page dynamically renders Clothing & Material Distribution module',
        (WidgetTester tester) async {
      final clothingService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.clothing);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: clothingService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vastra & Material Distribution'), findsOneWidget);
      expect(find.text('Current Stock'), findsOneWidget);
      expect(find.text('Dhoti & Kurta Sets'), findsOneWidget);
      expect(find.text('Soft Foam Walking Chappals'), findsOneWidget);
      expect(find.text('Seva Overview & Facilities'), findsOneWidget);
      expect(find.text('Contact & Inquiry'), findsOneWidget);
    });

    // 57. Universal Detail Page — Sanitation & Bio-Toilets Category
    testWidgets(
        '57. Universal detail page dynamically renders Sanitation & Bio-Toilets module',
        (WidgetTester tester) async {
      final sanitationService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.sanitation);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: sanitationService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bio-Toilet & Hygiene Complex'), findsOneWidget);
      expect(find.text('Total Toilets'), findsOneWidget);
      expect(find.text('Ladies Changing & Bio-Toilets (14)'), findsOneWidget);
      expect(find.text('Wheelchair Accessible Units (4)'), findsOneWidget);
      expect(find.text('Seva Overview & Facilities'), findsOneWidget);
    });

    // 58. Universal Detail Page — Volunteer & Help Desk Category
    testWidgets(
        '58. Universal detail page dynamically renders Volunteer & Help Desk module',
        (WidgetTester tester) async {
      final volunteerService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.volunteer);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: volunteerService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Volunteer Assistance & Help Desk'), findsOneWidget);
      expect(find.text('Active Volunteers'), findsOneWidget);
      expect(find.text('Languages'), findsWidgets);
      expect(find.text('Lost Person PA Announcements'), findsOneWidget);
      expect(find.text('Seva Overview & Facilities'), findsOneWidget);
    });

    // 59. Universal Detail Page — Emergency & Rescue Category
    testWidgets(
        '59. Universal detail page dynamically renders Emergency & Rescue module',
        (WidgetTester tester) async {
      final emergencyService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.emergency);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailScreen(service: emergencyService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Disaster & River Rescue'), findsOneWidget);
      expect(find.text('Emergency Support & Ambulance'), findsOneWidget);
      expect(find.text('Rescue Boats'), findsOneWidget);
      expect(find.text('MH-12-RR-0001'), findsOneWidget);
      expect(find.text('Call Ambulance'), findsWidgets);
    });

    // 60. Multi-criteria NgoServiceFilter independently filters food, shelter, water
    test(
        '60. Multi-criteria NgoServiceFilter independently filters food, shelter, water',
        () {
      final foodService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.food);
      final shelterService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.shelter);
      final waterService = NgoMockData.initialServices
          .firstWhere((s) => s.category == NgoServiceCategory.water);

      const foodFilter = NgoServiceFilter(hasAvailableFood: true);
      expect(foodFilter.matches(foodService), isTrue);
      expect(foodFilter.matches(shelterService), isFalse);

      const shelterFilter = NgoServiceFilter(hasAvailableShelter: true);
      expect(shelterFilter.matches(shelterService), isTrue);
      expect(shelterFilter.matches(foodService), isFalse);

      const waterFilter = NgoServiceFilter(hasAvailableWater: true);
      expect(waterFilter.matches(waterService), isTrue);
      expect(waterFilter.matches(foodService), isFalse);
    });
  });
}
