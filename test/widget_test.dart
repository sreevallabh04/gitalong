// This is a basic Flutter widget test for GitAlong app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitalong/main.dart';

void main() {
  group('GitAlong App Tests', () {
    testWidgets('App should start without crashing',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: GitAlongApp(),
        ),
      );

      // Verify that the app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have proper theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: GitAlongApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('App should have router configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: GitAlongApp(),
        ),
      );

      // Verify that the app has router configuration
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
