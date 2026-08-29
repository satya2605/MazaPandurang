import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/modules/citizen/citizen_module.dart';

void main() {
  testWidgets('CitizenModule screen renders CitizenInitializerScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CitizenModule.screen(),
      ),
    );

    expect(find.text('Local Citizen Module'), findsWidgets);
    expect(find.text('Module initialized successfully.'), findsOneWidget);
  });
}
