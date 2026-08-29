import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/repositories/mock_pilgrim_repository.dart';
import 'package:maza_pandurang/modules/pilgrim/screens/bhakti_screen.dart';

void main() {
  testWidgets('BhaktiScreen renders 5 exact categories',
      (WidgetTester tester) async {
    final repository = MockPilgrimRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: BhaktiScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Bhakti Streaming (भक्ती संगीत)'), findsOneWidget);

    // Verify 5 Categories
    expect(find.text('Vitthal Bhajans'), findsWidgets); // ChoiceChip text + list item category if matched
    expect(find.text('Abhang'), findsWidgets);
    expect(find.text('Wari Songs'), findsWidgets);
    expect(find.text('Aarti'), findsWidgets);
    expect(find.text('Pandurang'), findsWidgets);
  });
}
