import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/citizen/citizen_module.dart';
import 'package:maza_pandurang/modules/citizen/screens/citizen_home_screen.dart';
import 'package:maza_pandurang/modules/citizen/screens/citizen_services_screen.dart';
import 'package:maza_pandurang/modules/citizen/widgets/citizen_service_card.dart';
import 'package:maza_pandurang/modules/citizen/models/citizen_service.dart';

void main() {
  group('Citizen Module Tests', () {
    // Test 1: CitizenModule.screen() opens correctly
    testWidgets('CitizenModule screen renders without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CitizenModule.screen(),
        ),
      );
      // Don't call pumpAndSettle — the map screen makes network requests in tests.
      // We just pump a few frames to ensure it renders without crashing.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Bottom nav bar should be visible
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    // Test 2: Home screen shows Quick Actions section
    testWidgets('CitizenHomeScreen shows Quick Actions section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CitizenHomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Quick Actions text should be visible
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    // Test 3: Bottom navigation tab switching
    testWidgets('Bottom NavigationBar has correct destinations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CitizenHomeScreen(),
        ),
      );
      await tester.pump();

      // Check that the NavigationBar destinations exist
      // Use the NavigationDestination label text
      expect(find.byType(NavigationBar), findsOneWidget);

      // Tap the Profile tab (least ambiguous)
      await tester.tap(find.text('Profile'));
      await tester.pump(const Duration(milliseconds: 300));

      // Profile placeholder should be visible
      expect(find.text('Profile'), findsWidgets);
    });

    // Test 4: CitizenServiceCard renders service info
    testWidgets('CitizenServiceCard renders service details',
        (WidgetTester tester) async {
      final testService = CitizenService(
        id: 'test-001',
        name: 'Test Medical Camp',
        category: ServiceCategory.medical,
        status: ServiceStatus.open,
        distanceMetres: 200,
        address: 'Test Address, Pandharpur',
        latitude: 17.6733,
        longitude: 75.3278,
        lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitizenServiceCard(
              service: testService,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Medical Camp'), findsOneWidget);
      expect(find.text('OPEN'), findsOneWidget);
      expect(find.text('200 m away'), findsOneWidget);
    });

    // Test 5: CitizenServicesScreen renders list
    testWidgets('CitizenServicesScreen shows service list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CitizenServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the screen title
      expect(find.text('Nearby Services'), findsOneWidget);
      // Should show at least one service from mock data
      expect(find.text('Pandharpur Medical Camp'), findsOneWidget);
    });

    // Test 6: ServiceStatus enum labels
    test('ServiceStatus labels are correct', () {
      expect(ServiceStatus.open.label, 'OPEN');
      expect(ServiceStatus.closed.label, 'CLOSED');
      expect(ServiceStatus.full.label, 'FULL');
      expect(ServiceStatus.available.label, 'AVAILABLE');
      expect(ServiceStatus.limited.label, 'LIMITED');
    });

    // Test 7: ServiceCategory labels
    test('ServiceCategory labels are correct', () {
      expect(ServiceCategory.medical.label, 'Medical');
      expect(ServiceCategory.food.label, 'Food / Annachhatra');
      expect(ServiceCategory.water.label, 'Water');
    });

    // Test 8: CitizenService distance label formatting
    test('CitizenService distance label formats correctly', () {
      final nearService = CitizenService(
        id: 's1',
        name: 'Near',
        category: ServiceCategory.water,
        status: ServiceStatus.open,
        distanceMetres: 500,
        address: 'Near',
        latitude: 0,
        longitude: 0,
        lastUpdatedAt: DateTime.now(),
      );
      expect(nearService.distanceLabel, '500 m away');

      final farService = CitizenService(
        id: 's2',
        name: 'Far',
        category: ServiceCategory.hospital,
        status: ServiceStatus.open,
        distanceMetres: 1500,
        address: 'Far',
        latitude: 0,
        longitude: 0,
        lastUpdatedAt: DateTime.now(),
      );
      expect(farService.distanceLabel, '1.5 km away');
    });

    // Test 9: MockCitizenServiceData has services
    test('MockCitizenServiceData contains services', () {
      expect(MockCitizenServiceData.services.isNotEmpty, true);
      expect(MockCitizenServiceData.services.length, greaterThan(3));
    });

    // Test 10: CitizenService lastUpdatedLabel
    test('CitizenService lastUpdatedLabel formats correctly', () {
      final recent = CitizenService(
        id: 's3',
        name: 'Recent',
        category: ServiceCategory.food,
        status: ServiceStatus.available,
        distanceMetres: 100,
        address: 'Somewhere',
        latitude: 0,
        longitude: 0,
        lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(recent.lastUpdatedLabel, 'Updated 5 min ago');
    });
  });
}
