import 'package:flutter_app/domain/validators/routine_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoutineValidator.validateTitle', () {
    test('returns error for null, empty, or blank title', () {
      expect(
        RoutineValidator.validateTitle(null),
        'Please enter a routine title',
      );
      expect(
        RoutineValidator.validateTitle(''),
        'Please enter a routine title',
      );
      expect(
        RoutineValidator.validateTitle('   '),
        'Please enter a routine title',
      );
    });

    test('returns error when trimmed title is shorter than 2 characters', () {
      expect(
        RoutineValidator.validateTitle('A'),
        'Title must be at least 2 characters',
      );
      expect(
        RoutineValidator.validateTitle(' A '),
        'Title must be at least 2 characters',
      );
    });

    test('returns error when trimmed title exceeds 50 characters', () {
      expect(
        RoutineValidator.validateTitle('a' * 51),
        'Title must be at most 50 characters',
      );
    });

    test('returns null for valid boundary and trimmed titles', () {
      expect(RoutineValidator.validateTitle('Go'), isNull);
      expect(RoutineValidator.validateTitle('a' * 50), isNull);
      expect(RoutineValidator.validateTitle('  Morning Wakeup  '), isNull);
    });
  });

  group('RoutineValidator.validateTime', () {
    test('returns error for null, empty, or blank time', () {
      expect(RoutineValidator.validateTime(null), 'Please pick a time');
      expect(RoutineValidator.validateTime(''), 'Please pick a time');
      expect(RoutineValidator.validateTime('   '), 'Please pick a time');
    });

    test('returns error for invalid time formats', () {
      const invalidTimes = [
        '25:00',
        '13:00 PM',
        '18:30 PM',
        '0:30 AM',
        '12:60',
        'abc',
      ];
      for (final time in invalidTimes) {
        expect(
          RoutineValidator.validateTime(time),
          'Enter a valid time (e.g. 07:00 AM or 18:30)',
          reason: 'Expected "$time" to fail validation',
        );
      }
    });

    test('returns null for valid 12-hour formats', () {
      const valid12h = ['07:00 AM', '6:30 PM', '12:00 am', '7:00\u202FAM'];
      for (final time in valid12h) {
        expect(
          RoutineValidator.validateTime(time),
          isNull,
          reason: 'Expected "$time" to pass validation',
        );
      }
    });

    test('returns null for valid 24-hour formats', () {
      const valid24h = ['00:00', '7:00', '18:30', '23:59'];
      for (final time in valid24h) {
        expect(
          RoutineValidator.validateTime(time),
          isNull,
          reason: 'Expected "$time" to pass validation',
        );
      }
    });
  });

  group('RoutineValidator.validateSubtitle', () {
    test('returns error for null, empty, or blank description', () {
      expect(
        RoutineValidator.validateSubtitle(null),
        'Please enter routine actions',
      );
      expect(
        RoutineValidator.validateSubtitle(''),
        'Please enter routine actions',
      );
      expect(
        RoutineValidator.validateSubtitle('   '),
        'Please enter routine actions',
      );
    });

    test('returns error when description is shorter than 3 characters', () {
      expect(
        RoutineValidator.validateSubtitle('ON'),
        'Description must be at least 3 characters',
      );
      expect(
        RoutineValidator.validateSubtitle(' A '),
        'Description must be at least 3 characters',
      );
    });

    test('returns error when description exceeds 150 characters', () {
      expect(
        RoutineValidator.validateSubtitle('a' * 151),
        'Description must be at most 150 characters',
      );
    });

    test('returns null for valid boundary and trimmed descriptions', () {
      expect(RoutineValidator.validateSubtitle('Run'), isNull);
      expect(RoutineValidator.validateSubtitle('a' * 150), isNull);
      expect(RoutineValidator.validateSubtitle('  Turn lights on  '), isNull);
    });
  });
}
