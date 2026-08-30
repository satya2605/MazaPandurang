import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/models/pilgrim_models.dart';
import 'package:maza_pandurang/modules/pilgrim/repositories/mock_pilgrim_repository.dart';
import 'package:maza_pandurang/modules/pilgrim/screens/tilak_ai_screen.dart';

void main() {
  group('Tilak AI Unit & Widget Tests', () {
    test('TilakChatMessage.fromJson parses intent, actions, and sources', () {
      final json = {
        'reply': 'The Palkhi is currently at Saswad Stay.',
        'intent': 'palkhi_location',
        'actions': [
          {
            'type': 'palkhi',
            'label': '📍 Track Palkhi on Map',
            'targetRoute': '/palkhi'
          }
        ],
        'sources': ['palkhi_tracking']
      };

      final msg = TilakChatMessage.fromJson(json);

      expect(msg.text, equals('The Palkhi is currently at Saswad Stay.'));
      expect(msg.intent, equals('palkhi_location'));
      expect(msg.actions.length, equals(1));
      expect(msg.actions.first.label, equals('📍 Track Palkhi on Map'));
      expect(msg.actions.first.targetRoute, equals('/palkhi'));
      expect(msg.sources.first, equals('palkhi_tracking'));
    });

    test('TilakChatMessage.fromJson handles Emergency SOS safety action cards', () {
      final json = {
        'reply': 'Please use the Emergency SOS button immediately.',
        'intent': 'emergency',
        'actions': [
          {
            'type': 'emergency',
            'label': '🚨 Send Emergency SOS',
            'targetRoute': '/help'
          }
        ],
        'sources': ['emergency_dispatch_system']
      };

      final msg = TilakChatMessage.fromJson(json);

      expect(msg.intent, equals('emergency'));
      expect(msg.actions.first.type, equals('emergency'));
      expect(msg.actions.first.label, contains('Send Emergency SOS'));
    });

    testWidgets('TilakAiScreen renders header, suggested prompt chips, and input bar', (tester) async {
      final mockRepo = MockPilgrimRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: TilakAiScreen(repository: mockRepo),
        ),
      );

      expect(find.textContaining('तिलक वारी AI'), findsOneWidget);
      expect(find.textContaining('📍 पालखी सध्या कुठे आहे?'), findsOneWidget);
      expect(find.textContaining('🚨 आपत्कालीन मदत'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
