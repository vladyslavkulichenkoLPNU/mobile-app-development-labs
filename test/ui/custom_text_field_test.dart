import 'package:flutter/material.dart';
import 'package:flutter_app/ui/widgets/input_text_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('Does not obscure text by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CustomTextField(label: 'Email')),
        ),
      );

      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });

    testWidgets('Renders label and obscures text when isPassword is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(label: 'Password', isPassword: true),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      final TextField textField = tester.widget(textFieldFinder);
      expect(textField.obscureText, isTrue);
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
