import 'package:flutter/material.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/ui/screens/login_screen.dart';
import 'package:flutter_app/ui/screens/registration_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockRoutineRepository mockRoutineRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockRoutineRepository = MockRoutineRepository();
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
