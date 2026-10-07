// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/registration_screen.dart';
import 'package:flutter_app/widgets/input_text_field.dart';
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

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all input fields and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });
  });

  group('RegistrationScreen Widget Tests', () {
    testWidgets('Renders all input fields and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Navigates from Login to Register and back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistrationScreen(),
          },
        ),
      );

      expect(find.text('Don\'t have an account? Register'), findsOneWidget);

      await tester.tap(find.text('Don\'t have an account? Register'));
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? Login'), findsOneWidget);

      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });
  });
}
