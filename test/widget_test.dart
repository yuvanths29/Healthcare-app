import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthcare_app/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
