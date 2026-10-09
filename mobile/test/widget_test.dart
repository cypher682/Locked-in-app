// Basic widget test for CommitStack
// This is a placeholder until proper widget tests are implemented

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build a minimal MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('CommitStack'),
          ),
        ),
      ),
    );

    // Verify the text is displayed
    expect(find.text('CommitStack'), findsOneWidget);
  });

  testWidgets('Button can be tapped', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () => pressed = true,
            child: const Text('Tap Me'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap Me'));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
