import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/police/police_module.dart';

void main() {
  testWidgets('PoliceModule.screen renders PoliceLoginScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PoliceModule.screen(),
      ),
    );

    expect(find.text('Police Command'), findsOneWidget);
    expect(find.text('माझा पांडुरंग — Authority Portal'), findsOneWidget);
  });
}
