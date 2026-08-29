import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maza_pandurang/core/auth/auth_gate.dart';

void main() {
  testWidgets('AuthGate renders LoginScreen when unauthenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );

    // Drain microtasks and trigger rebuild
    await tester.pump();
    await tester.pump();

    // Verify LoginScreen header is rendered when unauthenticated
    expect(find.text('माझा पांडुरंग'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
