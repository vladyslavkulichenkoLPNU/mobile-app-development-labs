import 'package:flutter_app/data/security/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordHasher', () {
    test('hash produces a non-plaintext sha256 formatted string', () {
      const password = 'secretPassword123';
      final hashed = PasswordHasher.hash(password);

      expect(hashed, isNot(equals(password)));
      expect(hashed.startsWith(r'sha256$10000$'), isTrue);
      expect(hashed.split(r'$'), hasLength(4));
    });

    test('hash generates a unique salt on each call', () {
      const password = 'secretPassword123';
      final first = PasswordHasher.hash(password);
      final second = PasswordHasher.hash(password);

      expect(first, isNot(equals(second)));
    });

    test('verify returns true for matching password and false otherwise', () {
      const password = 'secretPassword123';
      final hashed = PasswordHasher.hash(password);

      expect(PasswordHasher.verify(password, hashed), isTrue);
      expect(PasswordHasher.verify('wrongPassword', hashed), isFalse);
    });

    test('verify returns false for malformed or plaintext values', () {
      expect(PasswordHasher.verify('password', 'password'), isFalse);
      expect(PasswordHasher.verify('password', r'sha256$0$salt$hash'), isFalse);
      expect(
        PasswordHasher.verify('password', r'md5$10000$salt$hash'),
        isFalse,
      );
      expect(PasswordHasher.verify('password', 'sha256\$bad\$s\$h'), isFalse);
    });
  });
}
