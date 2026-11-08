import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/repos/users/user_repo.dart';
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
  });

  group('HiveUserRepository - login', () {
    const email = 'user@example.com';
    const validPassword = 'correctPassword';
    const wrongPassword = 'invalidPassword';

    final savedUser = User(
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
}
