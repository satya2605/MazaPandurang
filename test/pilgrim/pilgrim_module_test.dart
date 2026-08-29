import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/pilgrim_module.dart';

void main() {
  testWidgets('PilgrimModule screen renders PilgrimHomeScreen foundation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PilgrimModule.screen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maza Pandurang'), findsOneWidget);
    expect(find.text('Palkhi'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Tilak AI'), findsOneWidget);
    expect(find.text('Bhakti'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
  });
}
