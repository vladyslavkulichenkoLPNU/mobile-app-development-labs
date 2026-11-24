import 'package:flutter_app/domain/validators/auth_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidator.validateName', () {
    test('returns error for null or blank input', () {
      expect(AuthValidator.validateName(null), isNotNull);
      expect(AuthValidator.validateName(''), isNotNull);
      expect(AuthValidator.validateName('   '), isNotNull);
    });

    test('returns error when name contains digits', () {
      expect(
        AuthValidator.validateName('John1'),
        'Full name must not contain digits',
      );
      expect(
        AuthValidator.validateName('123'),
        'Full name must not contain digits',
      );
    });

    test('returns null for valid names', () {
      expect(AuthValidator.validateName('John Doe'), isNull);
      expect(AuthValidator.validateName("O'Connor-Smith"), isNull);
    });
  });

  group('AuthValidator.validateEmail', () {
    test('returns error for null or blank input', () {
      expect(AuthValidator.validateEmail(null), isNotNull);
      expect(AuthValidator.validateEmail(''), isNotNull);
      expect(AuthValidator.validateEmail('   '), isNotNull);
    });

    test('returns error for invalid email formats', () {
      const invalidEmails = [
        'invalid',
        '@.',
        'user@',
        '@domain.com',
        'user@domain',
        'user @domain.com',
      ];
      for (final email in invalidEmails) {
        expect(
          AuthValidator.validateEmail(email),
          'Enter a valid email address',
          reason: 'Expected "$email" to fail validation',
        );
      }
    });

    test('returns null for valid and trimmed emails', () {
      expect(AuthValidator.validateEmail('user@example.com'), isNull);
      expect(AuthValidator.validateEmail('  user@example.com  '), isNull);
    });
  });

  group('AuthValidator.validateLoginPassword', () {
    test('returns error for null or empty password', () {
      expect(AuthValidator.validateLoginPassword(null), isNotNull);
      expect(AuthValidator.validateLoginPassword(''), isNotNull);
    });

    test('allows short non-empty and 8+ char passwords', () {
      expect(AuthValidator.validateLoginPassword('1234'), isNull);
      expect(AuthValidator.validateLoginPassword('12345678'), isNull);
    });
  });

  group('AuthValidator.validateRegistrationPassword', () {
    test('returns error for null or empty password', () {
      expect(AuthValidator.validateRegistrationPassword(null), isNotNull);
      expect(AuthValidator.validateRegistrationPassword(''), isNotNull);
    });

    test('returns error when password is shorter than 8 characters', () {
      expect(
        AuthValidator.validateRegistrationPassword('1234567'),
        'Password must be at least 8 characters',
      );
    });

    test('returns null when password has at least 8 characters', () {
      expect(AuthValidator.validateRegistrationPassword('12345678'), isNull);
    });
  });

  group('AuthValidator.validateConfirmPassword', () {
    test('returns error for null, empty, or mismatched confirmation', () {
      expect(
        AuthValidator.validateConfirmPassword(null, '12345678'),
        isNotNull,
      );
      expect(AuthValidator.validateConfirmPassword('', '12345678'), isNotNull);
      expect(
        AuthValidator.validateConfirmPassword('different', '12345678'),
        'Passwords do not match',
      );
    });

    test('returns null when confirmation matches password', () {
      expect(
        AuthValidator.validateConfirmPassword('12345678', '12345678'),
        isNull,
      );
    });
  });
}
