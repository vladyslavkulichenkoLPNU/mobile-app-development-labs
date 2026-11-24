import 'dart:async';

import 'package:flutter_app/ui/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) =>
              LoginScreen(authRepository: mockAuthRepository),
          '/dashboard': (context) => const Scaffold(body: Text('Dashboard')),
        },
      ),
    );
  }

  Future<void> submitLogin(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    if (email.isNotEmpty) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        email,
      );
    }
    if (password.isNotEmpty) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        password,
      );
    }
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all input fields and buttons', (
      WidgetTester tester,
    ) async {
      await pumpLoginScreen(tester);

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });

    testWidgets('Shows validation errors on invalid email and empty password', (
      WidgetTester tester,
    ) async {
      await pumpLoginScreen(tester);
      await submitLogin(tester, email: '@.', password: '');
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    testWidgets(
      'Accepts short password and navigates to dashboard on success',
      (WidgetTester tester) async {
        when(() => mockAuthRepository.login('user@example.com', '1234'))
            .thenAnswer((_) async => true);

        await pumpLoginScreen(tester);
        await submitLogin(tester, email: 'user@example.com', password: '1234');
        await tester.pumpAndSettle();

        verify(() => mockAuthRepository.login('user@example.com', '1234'))
            .called(1);
        expect(find.text('Dashboard'), findsOneWidget);
      },
    );

    testWidgets('Shows error message when login fails', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepository.login('user@example.com', 'wrong'))
          .thenAnswer((_) async => false);

      await pumpLoginScreen(tester);
      await submitLogin(tester, email: 'user@example.com', password: 'wrong');
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password.'), findsOneWidget);
    });

    testWidgets('Shows loading indicator while login request is pending', (
      WidgetTester tester,
    ) async {
      final completer = Completer<bool>();
      when(() => mockAuthRepository.login('user@example.com', '1234'))
          .thenAnswer((_) => completer.future);

      await pumpLoginScreen(tester);
      await submitLogin(tester, email: 'user@example.com', password: '1234');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      completer.complete(true);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
