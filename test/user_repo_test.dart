import 'package:flutter_app/data/repositories/hive_user_repository.dart';
import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockUserBox extends Mock implements Box<User> {}

class FakeUser extends Fake implements User {}

void main() {
  late MockUserBox mockUserBox;
  late HiveUserRepository authRepository;

  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  setUp(() {
    mockUserBox = MockUserBox();
    authRepository = HiveUserRepository(mockUserBox);
  });

  group('HiveUserRepository - register', () {
    const name = 'Test User';
    const email = 'user@example.com';
    const password = 'password123';

    test('returns true and persists user when email is not taken', () async {
      when(() => mockUserBox.containsKey(email)).thenReturn(false);
      when(() => mockUserBox.put(any<dynamic>(), any<User>()))
          .thenAnswer((_) async {});

      final result = await authRepository.register(name, email, password);

      expect(result, isTrue);
      verify(() => mockUserBox.containsKey(email)).called(1);
      verify(
        () => mockUserBox.put(
          email,
          any(
            that: isA<User>()
                .having((u) => u.name, 'name', name)
                .having((u) => u.email, 'email', email)
                .having((u) => u.password, 'password', password),
          ),
        ),
      ).called(1);
    });

    test('normalizes email and trims name before persisting user', () async {
      when(() => mockUserBox.containsKey(email)).thenReturn(false);
      when(() => mockUserBox.put(any<dynamic>(), any<User>()))
          .thenAnswer((_) async {});

      final result = await authRepository.register(
        '  Test User  ',
        '  User@Example.COM  ',
        password,
      );

      expect(result, isTrue);
      verify(() => mockUserBox.containsKey(email)).called(1);
      verify(
        () => mockUserBox.put(
          email,
          any(
            that: isA<User>()
                .having((u) => u.name, 'name', name)
                .having((u) => u.email, 'email', email),
          ),
        ),
      ).called(1);
    });

    test(
      'returns false and does not call put when email already exists',
      () async {
        when(() => mockUserBox.containsKey(email)).thenReturn(true);

        final result = await authRepository.register(name, email, password);

        expect(result, isFalse);
        verify(() => mockUserBox.containsKey(email)).called(1);
        verifyNever(() => mockUserBox.put(any<dynamic>(), any<User>()));
      },
    );

    test('returns false when email matches reserved session key', () async {
      final result = await authRepository.register(
        name,
        '__current_session__',
        password,
      );

      expect(result, isFalse);
      verifyNever(() => mockUserBox.put(any<dynamic>(), any<User>()));
    });
  });

  group('HiveUserRepository - login', () {
    const email = 'user@example.com';
    const validPassword = 'correctPassword';
    const wrongPassword = 'invalidPassword';

    const savedUser = User(
      name: 'Test User',
      email: email,
      password: validPassword,
    );

    test('returns true when user exists and password matches', () async {
      when(() => mockUserBox.get(email)).thenReturn(savedUser);
      when(() => mockUserBox.put(any<dynamic>(), any<User>()))
          .thenAnswer((_) async {});

      final result = await authRepository.login(email, validPassword);

      expect(result, isTrue);
      verify(() => mockUserBox.get(email)).called(1);
      verify(() => mockUserBox.put(any<dynamic>(), any<User>())).called(1);
    });

    test('normalizes email when looking up user on login', () async {
      when(() => mockUserBox.get(email)).thenReturn(savedUser);
      when(() => mockUserBox.put(any<dynamic>(), any<User>()))
          .thenAnswer((_) async {});

      final result = await authRepository.login(
        '  User@Example.COM  ',
        validPassword,
      );

      expect(result, isTrue);
      verify(() => mockUserBox.get(email)).called(1);
    });

    test('returns false when user does not exist in box', () async {
      when(() => mockUserBox.get(email)).thenReturn(null);

      final result = await authRepository.login(email, validPassword);

      expect(result, isFalse);
      verify(() => mockUserBox.get(email)).called(1);
    });

    test('returns false when user exists but password is incorrect', () async {
      when(() => mockUserBox.get(email)).thenReturn(savedUser);

      final result = await authRepository.login(email, wrongPassword);

      expect(result, isFalse);
      verify(() => mockUserBox.get(email)).called(1);
    });
  });

  group('HiveUserRepository - session', () {
    const sessionKey = '__current_session__';
    const savedUser = User(
      name: 'Test User',
      email: 'user@example.com',
      password: 'password123',
    );

    test('getCurrentUser returns stored user when session exists', () async {
      when(() => mockUserBox.get(sessionKey)).thenReturn(savedUser);

      final result = await authRepository.getCurrentUser();

      expect(result, equals(savedUser));
      verify(() => mockUserBox.get(sessionKey)).called(1);
    });

    test('getCurrentUser returns null when no session exists', () async {
      when(() => mockUserBox.get(sessionKey)).thenReturn(null);

      final result = await authRepository.getCurrentUser();

      expect(result, isNull);
      verify(() => mockUserBox.get(sessionKey)).called(1);
    });

    test('logout deletes the stored session key', () async {
      when(() => mockUserBox.delete(sessionKey)).thenAnswer((_) async {});

      await authRepository.logout();

      verify(() => mockUserBox.delete(sessionKey)).called(1);
    });
  });
}
