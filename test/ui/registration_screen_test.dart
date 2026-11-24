import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/screens/registration_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Future<void> pumpRegistrationScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/register',
        routes: {
          '/register': (context) =>
              RegistrationScreen(authRepository: mockAuthRepository),
          '/dashboard': (context) => const Scaffold(body: Text('Dashboard')),
        },
      ),
    );
  }

  Future<void> submitRegistration(
    WidgetTester tester, {
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      name,
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      password,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm Password'),
      confirmPassword,
    );
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Enter'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
  }

  group('RegistrationScreen Widget Tests', () {
    testWidgets('Renders all input fields and buttons', (
      WidgetTester tester,
    ) async {
      await pumpRegistrationScreen(tester);

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });

    testWidgets('Shows validation errors for invalid registration fields', (
      WidgetTester tester,
    ) async {
      await pumpRegistrationScreen(tester);
      await submitRegistration(
        tester,
        name: 'John1',
        email: '@.',
        password: '1234567',
        confirmPassword: 'mismatch',
      );
      await tester.pump();

      expect(find.text('Full name must not contain digits'), findsOneWidget);
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => mockAuthRepository.register(any(), any(), any()));
    });

    testWidgets('Shows error when email already exists', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthRepository.register(
          'John Doe',
          'user@example.com',
          'password123',
        ),
      ).thenAnswer((_) async => false);

      await pumpRegistrationScreen(tester);
      await submitRegistration(
        tester,
        name: 'John Doe',
        email: 'user@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      await tester.pumpAndSettle();

      expect(find.text('User with this email already exists.'), findsOneWidget);
    });

    testWidgets(
      'Shows loading indicator while registering and navigates on success',
      (WidgetTester tester) async {
        final completer = Completer<bool>();
        when(
          () => mockAuthRepository.register(
            'John Doe',
            'user@example.com',
            'password123',
          ),
        ).thenAnswer((_) => completer.future);

        await pumpRegistrationScreen(tester);
        await submitRegistration(
          tester,
          name: 'John Doe',
          email: 'user@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete(true);
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsOneWidget);
      },
    );
  });
}
