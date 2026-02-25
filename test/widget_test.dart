import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:loopin_j_app/main.dart';

void main() {
  testWidgets('App Launches Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LoopinJApp()));

    // Verify it doesn't immediately crash.
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
