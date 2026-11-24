import 'package:flutter_app/data/repositories/hive_routine_repository.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/mocks.dart';

class MockRoutineBox extends Mock implements Box<Routine> {}

void main() {
  late MockRoutineBox mockRoutineBox;
  late HiveRoutineRepository routineRepository;

  setUpAll(() {
    registerFallbackValue(FakeRoutine());
  });

  setUp(() {
    mockRoutineBox = MockRoutineBox();
    routineRepository = HiveRoutineRepository(mockRoutineBox);
  });

  group('HiveRoutineRepository - getAllRoutines', () {
    test('returns routines preserving non-empty id', () async {
      when(() => mockRoutineBox.toMap())
          .thenReturn(<dynamic, Routine>{testRoutine.id: testRoutine});

      final result = await routineRepository.getAllRoutines();

      expect(result, hasLength(1));
      expect(result.first.id, testRoutine.id);
      expect(result.first.title, testRoutine.title);
    });

    test(
      'backfills id from Hive key when stored routine id is empty',
      () async {
        const legacyRoutine = Routine(
          id: '',
          time: '08:00 AM',
          title: 'Legacy Routine',
          subtitle: 'Coffee ON',
          icon: 'wb_sunny',
        );
        when(() => mockRoutineBox.toMap())
            .thenReturn(<dynamic, Routine>{42: legacyRoutine});

        final result = await routineRepository.getAllRoutines();

        expect(result, hasLength(1));
        expect(result.first.id, '42');
        expect(result.first.title, 'Legacy Routine');
      },
    );
  });

  group('HiveRoutineRepository - addRoutine', () {
    test('puts routine keyed by routine.id', () async {
      when(() => mockRoutineBox.put(any<dynamic>(), any<Routine>()))
          .thenAnswer((_) async {});

      await routineRepository.addRoutine(testRoutine);

      verify(() => mockRoutineBox.put(testRoutine.id, testRoutine)).called(1);
    });
  });

  group('HiveRoutineRepository - updateRoutine', () {
    test('puts routine under string id when key exists', () async {
      when(() => mockRoutineBox.containsKey(testRoutine.id)).thenReturn(true);
      when(() => mockRoutineBox.put(any<dynamic>(), any<Routine>()))
          .thenAnswer((_) async {});

      await routineRepository.updateRoutine(testRoutine);

      verify(() => mockRoutineBox.containsKey(testRoutine.id)).called(1);
      verify(() => mockRoutineBox.put(testRoutine.id, testRoutine)).called(1);
    });

    test('resolves legacy integer key when string id is absent', () async {
      final legacyRoutine = testRoutine.copyWith(id: '42');
      when(() => mockRoutineBox.containsKey('42')).thenReturn(false);
      when(() => mockRoutineBox.containsKey(42)).thenReturn(true);
      when(() => mockRoutineBox.put(any<dynamic>(), any<Routine>()))
          .thenAnswer((_) async {});

      await routineRepository.updateRoutine(legacyRoutine);

      verify(() => mockRoutineBox.put(42, legacyRoutine)).called(1);
    });

    test('falls back to routine.id when neither key exists', () async {
      final missingRoutine = testRoutine.copyWith(id: '42');
      when(() => mockRoutineBox.containsKey('42')).thenReturn(false);
      when(() => mockRoutineBox.containsKey(42)).thenReturn(false);
      when(() => mockRoutineBox.put(any<dynamic>(), any<Routine>()))
          .thenAnswer((_) async {});

      await routineRepository.updateRoutine(missingRoutine);

      verify(() => mockRoutineBox.put('42', missingRoutine)).called(1);
    });
  });

  group('HiveRoutineRepository - deleteRoutine', () {
    test('deletes routine under string id when key exists', () async {
      when(() => mockRoutineBox.containsKey('1')).thenReturn(true);
      when(() => mockRoutineBox.delete(any<dynamic>()))
          .thenAnswer((_) async {});

      await routineRepository.deleteRoutine('1');

      verify(() => mockRoutineBox.delete('1')).called(1);
    });

    test('deletes legacy integer key when string id is absent', () async {
      when(() => mockRoutineBox.containsKey('42')).thenReturn(false);
      when(() => mockRoutineBox.containsKey(42)).thenReturn(true);
      when(() => mockRoutineBox.delete(any<dynamic>()))
          .thenAnswer((_) async {});

      await routineRepository.deleteRoutine('42');

      verify(() => mockRoutineBox.delete(42)).called(1);
    });

    test('does not call delete when key does not exist', () async {
      when(() => mockRoutineBox.containsKey('42')).thenReturn(false);
      when(() => mockRoutineBox.containsKey(42)).thenReturn(false);

      await routineRepository.deleteRoutine('42');

      verifyNever(() => mockRoutineBox.delete(any<dynamic>()));
    });
  });
}
