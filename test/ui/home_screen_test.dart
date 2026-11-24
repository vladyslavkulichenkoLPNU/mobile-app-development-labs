import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/ui/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockRoutineRepository mockRoutineRepository;

  setUpAll(() {
    registerFallbackValue(FakeRoutine());
  });

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
  });

  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    List<Routine> routines = const [],
  }) async {
    when(() => mockRoutineRepository.getAllRoutines())
        .thenAnswer((_) async => routines);

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(routineRepository: mockRoutineRepository)),
    );
    await tester.pumpAndSettle();
  }

  group('HomeScreen CRUD Widget Tests', () {
    testWidgets(
      'Shows empty state when no routines exist without seeding defaults',
      (WidgetTester tester) async {
        await pumpHomeScreen(tester);

        expect(find.text('No routines yet. Tap + to add one.'), findsOneWidget);
        verifyNever(() => mockRoutineRepository.addRoutine(any()));
      },
    );

    testWidgets('Displays loaded routines on RoutineCard', (
      WidgetTester tester,
    ) async {
      await pumpHomeScreen(tester, routines: const [testRoutine]);

      expect(find.text('07:00 AM - Morning Wakeup'), findsOneWidget);
      expect(find.text('Lights ON, Coffee Maker ON'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Toggles routine active switch and persists update', (
      WidgetTester tester,
    ) async {
      when(() => mockRoutineRepository.updateRoutine(any()))
          .thenAnswer((_) async {});

      await pumpHomeScreen(tester, routines: const [testRoutine]);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(
        () => mockRoutineRepository.updateRoutine(
          any(
            that: isA<Routine>()
                .having((r) => r.id, 'id', '1')
                .having((r) => r.isActive, 'isActive', isFalse),
          ),
        ),
      ).called(1);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('Blocks creating routine when form fields are invalid', (
      WidgetTester tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump();

      expect(find.text('Please enter a routine title'), findsOneWidget);
      expect(find.text('Please pick a time'), findsOneWidget);
      expect(find.text('Please enter routine actions'), findsOneWidget);
      verifyNever(() => mockRoutineRepository.addRoutine(any()));
    });

    testWidgets('Creates routine using time picker and appends it to list', (
      WidgetTester tester,
    ) async {
      when(() => mockRoutineRepository.addRoutine(any()))
          .thenAnswer((_) async {});

      await pumpHomeScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Night Lock',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Actions / Description'),
        'Lock all doors',
      );
      await tester.tap(find.widgetWithText(TextFormField, 'Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();

      verify(
        () => mockRoutineRepository.addRoutine(
          any(
            that: isA<Routine>()
                .having((r) => r.title, 'title', 'Night Lock')
                .having((r) => r.subtitle, 'subtitle', 'Lock all doors')
                .having((r) => r.time.isNotEmpty, 'has time', isTrue),
          ),
        ),
      ).called(1);

      expect(find.textContaining('Night Lock'), findsOneWidget);
      expect(find.text('Lock all doors'), findsOneWidget);
    });

    testWidgets('Edits an existing routine and updates UI', (
      WidgetTester tester,
    ) async {
      when(() => mockRoutineRepository.updateRoutine(any()))
          .thenAnswer((_) async {});

      await pumpHomeScreen(tester, routines: const [testRoutine]);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Routine'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Early Wakeup',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Actions / Description'),
        'Coffee ON',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        () => mockRoutineRepository.updateRoutine(
          any(
            that: isA<Routine>()
                .having((r) => r.id, 'id', '1')
                .having((r) => r.title, 'title', 'Early Wakeup')
                .having((r) => r.subtitle, 'subtitle', 'Coffee ON')
                .having((r) => r.time, 'time', '07:00 AM'),
          ),
        ),
      ).called(1);

      expect(find.text('07:00 AM - Early Wakeup'), findsOneWidget);
      expect(find.text('Coffee ON'), findsOneWidget);
    });

    testWidgets(
      'Does not delete routine when confirmation dialog is cancelled',
      (WidgetTester tester) async {
        await pumpHomeScreen(tester, routines: const [testRoutine]);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(
          find.text('Are you sure you want to delete "Morning Wakeup"?'),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.widgetWithText(TextButton, 'Cancel'),
          ),
        );
        await tester.pumpAndSettle();

        verifyNever(() => mockRoutineRepository.deleteRoutine(any()));
        expect(find.text('07:00 AM - Morning Wakeup'), findsOneWidget);
      },
    );

    testWidgets('Deletes routine when confirmation dialog is confirmed', (
      WidgetTester tester,
    ) async {
      when(() => mockRoutineRepository.deleteRoutine('1'))
          .thenAnswer((_) async {});

      await pumpHomeScreen(tester, routines: const [testRoutine]);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(TextButton, 'Delete'),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockRoutineRepository.deleteRoutine('1')).called(1);
      expect(find.text('No routines yet. Tap + to add one.'), findsOneWidget);
    });
  });
}
