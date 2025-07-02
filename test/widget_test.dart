// This is a basic Flutter widget test for GitAlong app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitalong/main.dart';

void main() {
  testWidgets('GitAlong app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GitAlongApp(),
      ),
    );

    // Verify that GitAlong app starts up without crashing
    expect(find.text('GitAlong'), findsOneWidget);
  });

  testWidgets('App navigation smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GitAlongApp(),
      ),
    );

    // Allow the app to initialize
    await tester.pumpAndSettle();

    // The app should show some UI without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Theme integration test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GitAlongApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Check that the app uses the correct theme colors
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.primaryColor, isNotNull);
  });
}
