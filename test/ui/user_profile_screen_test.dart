import 'package:flutter/material.dart';
import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_app/ui/screens/user_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Future<void> pumpProfileScreen(WidgetTester tester, {User? user}) async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => user);

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
  }

  Future<void> openLogoutDialog(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Log Out'));
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
  }

  group('UserProfileScreen Widget Tests', () {
    testWidgets('Renders current user name and email', (
      WidgetTester tester,
    ) async {
      await pumpProfileScreen(tester, user: testUser);

      expect(find.text(testUser.name), findsOneWidget);
      expect(find.text(testUser.email), findsOneWidget);
    });

    testWidgets('Renders fallback view when session is null', (
      WidgetTester tester,
    ) async {
      await pumpProfileScreen(tester);

      expect(find.text('No active user session found.'), findsOneWidget);
      expect(find.text('Return to Start'), findsOneWidget);
    });

    testWidgets('Calls logout and navigates to root on Log Out tap', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      await pumpProfileScreen(tester, user: testUser);
      await openLogoutDialog(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Log Out'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.logout()).called(1);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('Does not log out when confirmation dialog is cancelled', (
      WidgetTester tester,
    ) async {
      await pumpProfileScreen(tester, user: testUser);
      await openLogoutDialog(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out?'), findsNothing);
      verifyNever(() => mockAuthRepository.logout());
    });
  });
}
