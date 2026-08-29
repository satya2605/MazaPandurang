import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/pilgrim/pilgrim_module.dart';

void main() {
  testWidgets('PilgrimModule screen renders PilgrimInitializerScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PilgrimModule.screen(),
      ),
    );

    expect(find.text('Pilgrim Module'), findsWidgets);
    expect(find.text('Module initialized successfully.'), findsOneWidget);
  });
}
