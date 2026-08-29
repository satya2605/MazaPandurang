import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/ngo/ngo_module.dart';

void main() {
  testWidgets('NgoModule screen renders NgoInitializerScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NgoModule.screen(),
      ),
    );

    expect(find.text('NGO Volunteer Module'), findsWidgets);
    expect(find.text('Module initialized successfully.'), findsOneWidget);
  });
}
