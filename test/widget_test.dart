// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:force_player_register_app/shared/widgets/aura_widgets.dart';
import 'package:force_player_register_app/core/theme/app_theme.dart';

void main() {
  testWidgets('AuraCard smoke test', (WidgetTester tester) async {
    // Build AuraCard and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: AuraCard(child: Text('Aura Content'))),
      ),
    );

    // Verify that our content is displayed.
    expect(find.text('Aura Content'), findsOneWidget);
    expect(find.byType(AuraCard), findsOneWidget);
  });
}
