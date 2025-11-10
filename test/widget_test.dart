// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_5/main.dart';

void main() {
  testWidgets('Step Counter smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StepCounterApp());

    // Wait for Firebase initialization and auth check
    await tester.pumpAndSettle();

    // Verify that the login screen is shown initially
    expect(find.text('Step Counter Login'), findsOneWidget);

    // Verify that email and password fields are present
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify that login button is present
    expect(find.text('Login'), findsOneWidget);
  });
}
