// This is a basic Flutter widget test for GitAlong app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitalong/main.dart';

void main() {
  group('GitAlong App Tests', () {
    testWidgets('App initialization smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      // Verify that the app initializes without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has correct theme configuration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      
      // Verify theme is configured
      expect(app.theme, isNotNull);
      expect(app.darkTheme, isNotNull);
      expect(app.themeMode, equals(ThemeMode.system));
    });

    testWidgets('App routing is configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      
      // Verify router is configured
      expect(app.routerConfig, isNotNull);
    });
  });
}
