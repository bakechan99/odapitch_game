// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakenhi_game/main.dart';
import 'package:kakenhi_game/screens/title_screen.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Build our app and wait for animations/BGM attempts to settle.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // タイトル画面が表示されることを確認
    expect(find.byType(TitleScreen), findsOneWidget);
  });
}
