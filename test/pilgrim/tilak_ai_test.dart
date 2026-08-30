import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/models/pilgrim_models.dart';
import 'package:maza_pandurang/modules/pilgrim/repositories/mock_pilgrim_repository.dart';
import 'package:maza_pandurang/modules/pilgrim/screens/tilak_ai_screen.dart';

void main() {
  group('Tilak AI Unit & Widget Tests', () {
    test('TilakChatMessage.fromJson parses json["message"] accurately', () {
      final json = {
        'message': 'पालखी सध्या सासवड येथे आहे.',
        'language': 'mr',
        'provider': 'groq',
        'sources': ['palkhi_tracking']
      };

      final msg = TilakChatMessage.fromJson(json);

      expect(msg.text, equals('पालखी सध्या सासवड येथे आहे.'));
      expect(msg.isUser, isFalse);
    });

    test('AI-1: Different questions return different distinct responses in MockRepository', () async {
      final mockRepo = MockPilgrimRepository();

      final res1 = await mockRepo.queryTilakAI('पालखी सध्या कुठे आहे?');
      final res2 = await mockRepo.queryTilakAI('पिण्याचे पाणी कुठे मिळेल?');
      final res3 = await mockRepo.queryTilakAI('वैद्यकीय मदत कुठे मिळेल?');

      expect(res1.text, isNot(equals(res2.text)));
      expect(res2.text, isNot(equals(res3.text)));
      expect(res1.text, isNot(equals(res3.text)));
      expect(res1.text, contains('Palkhi'));
      expect(res2.text, contains('Jal Seva'));
      expect(res3.text, contains('Medical'));
    });

    test('AI-2: Successful LLM response with json["message"] parses cleanly', () {
      final json = {
        'success': true,
        'message': 'सासवड चौकात जल सेवा कॅम्प सुरू आहे.',
        'language': 'mr',
        'provider': 'groq'
      };

      final msg = TilakChatMessage.fromJson(json);
      expect(msg.text, equals('सासवड चौकात जल सेवा कॅम्प सुरू आहे.'));
    });

    test('AI-3 & AI-4: Empty JSON or missing message uses Marathi fallback error message instead of Ram Krishna Hari', () {
      final emptyJson = <String, dynamic>{};
      final msg = TilakChatMessage.fromJson(emptyJson);

      expect(msg.text, isNot(equals('Ram Krishna Hari!')));
      expect(msg.text, contains('क्षमस्व'));
    });

    test('AI-5 & AI-9: Palkhi and Dindi context queries produce distinct results', () async {
      final mockRepo = MockPilgrimRepository();

      final palkhiRes = await mockRepo.queryTilakAI('where is palkhi');
      final dindiRes = await mockRepo.queryTilakAI('dindi information');

      expect(palkhiRes.text, contains('Palkhi'));
      expect(dindiRes.text, contains('Dindi'));
      expect(palkhiRes.text, isNot(equals(dindiRes.text)));
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

    testWidgets('AI-7 & AI-8: Submitting query updates chat feed with response', (tester) async {
      final mockRepo = MockPilgrimRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: TilakAiScreen(repository: mockRepo),
        ),
      );

      await tester.enterText(find.byType(TextField), 'वैद्यकीय मदत');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('वैद्यकीय मदत'), findsOneWidget);
      expect(find.textContaining('Medical'), findsWidgets);
    });
  });
}
