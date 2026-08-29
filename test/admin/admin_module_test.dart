import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/admin/admin_module.dart';
import 'package:maza_pandurang/modules/admin/models/admin_models.dart';
import 'package:maza_pandurang/modules/admin/screens/admin_dashboard_screen.dart';

void main() {
  group('Admin Module & Models Unit Tests', () {
    test('AdminModule.screen returns AdminDashboardScreen widget', () {
      final widget = AdminModule.screen();
      expect(widget, isA<AdminDashboardScreen>());
    });

    test('AdminDashboardStats.fromJson parses dashboard counts correctly', () {
      final json = {
        'pending_ngos': 3,
        'pending_services': 5,
        'pending_dindis': 2,
        'pending_dindi_leaders': 4,
        'pending_lost_person_reports': 1,
        'open_service_reports': 6,
        'active_emergencies': 2,
        'active_traffic_alerts': 8,
        'timestamp': '2026-08-29T20:00:00Z',
      };

      final stats = AdminDashboardStats.fromJson(json);

      expect(stats.pendingNgos, equals(3));
      expect(stats.pendingServices, equals(5));
      expect(stats.pendingDindis, equals(2));
      expect(stats.pendingDindiLeaders, equals(4));
      expect(stats.pendingLostPersonReports, equals(1));
      expect(stats.openServiceReports, equals(6));
      expect(stats.activeEmergencies, equals(2));
      expect(stats.activeTrafficAlerts, equals(8));
    });

    test('AdminNgo.fromJson parses NGO data correctly', () {
      final json = {
        'id': 'NGO-100',
        'name': 'Warkari Seva Mandal',
        'registration_number': 'REG-2026-99',
        'contact_person': 'Shrutika Volunteer',
        'phone': '+919876543213',
        'email': 'shrutika@mazapandurang.local',
        'status': 'pending',
        'description': 'Providing medical and food camp seva',
      };

      final ngo = AdminNgo.fromJson(json);

      expect(ngo.id, equals('NGO-100'));
      expect(ngo.name, equals('Warkari Seva Mandal'));
      expect(ngo.registrationNumber, equals('REG-2026-99'));
      expect(ngo.status, equals('pending'));
    });

    test('AdminService.fromJson handles 2-gate verification states', () {
      final json = {
        'id': 'SRV-001',
        'name': 'Medical Camp',
        'category': 'Medical',
        'address': 'Saswad Bus Stand',
        'provider_name': 'Warkari Seva Mandal',
        'is_verified': true,
        'is_active': false,
      };

      final srv = AdminService.fromJson(json);

      expect(srv.id, equals('SRV-001'));
      expect(srv.isVerified, isTrue);
      expect(srv.isActive, isFalse);
    });

    test('AdminDindiLeader.fromJson parses rich application details', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000002',
        'display_name': 'Sanket Patil',
        'email': 'sanket@mazapandurang.local',
        'phone': '+91 98220 12345',
        'status': 'pending',
        'dindis': [
          {
            'name': 'Shree Tukaram Maharaj Palkhi Dindi No. 12',
            'start_point': 'Dehu',
            'destination': 'Pandharpur',
            'member_count': 200,
            'dindi_number': 'DND-1788022905250',
          }
        ],
      };

      final leader = AdminDindiLeader.fromJson(json);

      expect(leader.id, equals('00000000-0000-0000-0000-000000000002'));
      expect(leader.displayName, equals('Sanket Patil'));
      expect(leader.status, equals('pending'));
      expect(leader.dindiName, equals('Shree Tukaram Maharaj Palkhi Dindi No. 12'));
      expect(leader.startPoint, equals('Dehu'));
      expect(leader.destination, equals('Pandharpur'));
      expect(leader.memberCount, equals(200));
    });

    testWidgets('AdminDashboardScreen renders TabBar and Title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardScreen(),
        ),
      );

      expect(find.textContaining('Admin Control Plane'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
