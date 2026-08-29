import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/dindi/dindi_module.dart';

void main() {
  testWidgets('DindiModule screen renders DindiInitializerScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DindiModule.screen(),
      ),
    );

    expect(find.text('Dindi Leader Module'), findsWidgets);
    expect(find.text('Module initialized successfully.'), findsOneWidget);
  });
}
