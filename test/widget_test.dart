import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
import 'package:flutter_app/domain/repositories/i_user_repository.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/ui/screens/login_screen.dart';
import 'package:flutter_app/ui/screens/registration_screen.dart';
import 'package:flutter_app/ui/screens/user_profile_screen.dart';
import 'package:flutter_app/ui/widgets/input_text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

class MockRoutineRepository extends Mock implements IRoutineRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockRoutineRepository mockRoutineRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockRoutineRepository = MockRoutineRepository();
  });

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
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(authRepository: mockAuthRepository)),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });

    testWidgets('Shows validation errors on invalid email and empty password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(authRepository: mockAuthRepository)),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), '@.');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
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

        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/login',
            routes: {
              '/login': (context) =>
                  LoginScreen(authRepository: mockAuthRepository),
              '/dashboard': (context) =>
                  const Scaffold(body: Text('Dashboard')),
            },
          ),
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'user@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          '1234',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
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

      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(authRepository: mockAuthRepository)),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrong',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password.'), findsOneWidget);
    });

    testWidgets('Shows loading indicator while login request is pending', (
      WidgetTester tester,
    ) async {
      final completer = Completer<bool>();
      when(() => mockAuthRepository.login('user@example.com', '1234'))
          .thenAnswer((_) => completer.future);

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

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '1234',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      completer.complete(true);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  group('RegistrationScreen Widget Tests', () {
    testWidgets('Renders all input fields and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationScreen(authRepository: mockAuthRepository),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationScreen(authRepository: mockAuthRepository),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John1',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), '@.');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '1234567',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'mismatch',
      );
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Enter'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
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

      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationScreen(authRepository: mockAuthRepository),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Enter'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
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

        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/register',
            routes: {
              '/register': (context) =>
                  RegistrationScreen(authRepository: mockAuthRepository),
              '/dashboard': (context) =>
                  const Scaffold(body: Text('Dashboard')),
            },
          ),
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'),
          'John Doe',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'user@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'password123',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'),
          'password123',
        );
        await tester.ensureVisible(
          find.widgetWithText(ElevatedButton, 'Enter'),
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Enter'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete(true);
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsOneWidget);
      },
    );
  });

  group('UserProfileScreen Widget Tests', () {
    testWidgets('Renders current user name and email', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
        (_) async => const User(
          name: 'Jane Doe',
          email: 'jane@example.com',
          password: 'password123',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UserProfileScreen(authRepository: mockAuthRepository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
    });

    testWidgets('Renders fallback view when session is null', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          home: UserProfileScreen(authRepository: mockAuthRepository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No active user session found.'), findsOneWidget);
      expect(find.text('Return to Start'), findsOneWidget);
    });

    testWidgets('Calls logout and navigates to root on Log Out tap', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
        (_) async => const User(
          name: 'Jane Doe',
          email: 'jane@example.com',
          password: 'password123',
        ),
      );
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/profile',
          routes: {
            '/': (context) => const Scaffold(body: Text('Start')),
            '/profile': (context) =>
                UserProfileScreen(authRepository: mockAuthRepository),
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.logout()).called(1);
      expect(find.text('Start'), findsOneWidget);
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
            '/login': (context) =>
                LoginScreen(authRepository: mockAuthRepository),
            '/register': (context) =>
                RegistrationScreen(authRepository: mockAuthRepository),
          },
        ),
      );

      expect(find.text("Don't have an account? Register"), findsOneWidget);

      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? Login'), findsOneWidget);

      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });
  });

  group('SmartSyncApp Initial Route Tests', () {
    testWidgets('Renders StartingScreen when initialRoute is root', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        SmartSyncApp(
          userRepository: mockAuthRepository,
          routineRepository: mockRoutineRepository,
          initialRoute: '/',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Smart Sync Hub'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('Renders HomeScreen when initialRoute is dashboard', (
      WidgetTester tester,
    ) async {
      when(() => mockRoutineRepository.getAllRoutines()).thenAnswer(
        (_) async => const [
          Routine(
            id: '1',
            time: '07:00 AM',
            title: 'Morning Wakeup',
            subtitle: 'Lights ON',
            icon: 'wb_sunny',
          ),
        ],
      );

      await tester.pumpWidget(
        SmartSyncApp(
          userRepository: mockAuthRepository,
          routineRepository: mockRoutineRepository,
          initialRoute: '/dashboard',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My IoT Routines'), findsOneWidget);
      expect(find.text('07:00 AM - Morning Wakeup'), findsOneWidget);
      verify(() => mockRoutineRepository.getAllRoutines()).called(1);
    });
  });
}
