import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/police/police_module.dart';

void main() {
  testWidgets('PoliceModule screen renders PoliceInitializerScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PoliceModule.screen(),
      ),
    );

    expect(find.text('Police / Authority Module'), findsWidgets);
    expect(find.text('Module initialized successfully.'), findsOneWidget);
  });
}
