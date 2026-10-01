import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Сценарій 1: Математична операція
  testWidgets(
    'Counter increments by valid integer inputs, including negative numbers',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyHomePage(title: '')));

      final inputField = find.byType(TextFormField);
      final submitButton = find.text('Enter');

      // Simulate typing '5' and tapping the button
      await tester.enterText(inputField, '5');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify counter updated to 5
      expect(find.text('5'), findsOneWidget);

      // Simulate typing '-2' and tapping
      await tester.enterText(inputField, '-2');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify counter is now 3 (5 + -2)
      expect(find.text('3'), findsOneWidget);
    },
  );

  // Сценарій 2: Термінальна команда
  testWidgets('Terminal command "Avada Kedavra" resets counter to zero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MyHomePage(title: '')));

    final inputField = find.byType(TextFormField);
    final submitButton = find.text('Enter');

    // First, add a number so the counter is not zero
    await tester.enterText(inputField, '42');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);

    // Simulate typing the terminal command
    await tester.enterText(inputField, 'Avada Kedavra');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verify counter is reset to 0
    expect(find.text('0'), findsOneWidget);
  });

  // Сценарій 3: Обробка виключень
  testWidgets(
    'Invalid inputs are caught by validation and do not mutate state',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyHomePage(title: '')));

      final inputField = find.byType(TextFormField);
      final submitButton = find.text('Enter');

      // Simulate typing an invalid fractional number
      await tester.enterText(inputField, '3.14');
      await tester.tap(submitButton);

      await tester.pump();

      // Verify counter remains at default 0
      expect(find.text('0'), findsOneWidget);

      // Verify form validation error text appears under the field
      expect(
        find.text('Only integers or "Avada Kedavra" are allowed.'),
        findsOneWidget,
      );
    },
  );
}
