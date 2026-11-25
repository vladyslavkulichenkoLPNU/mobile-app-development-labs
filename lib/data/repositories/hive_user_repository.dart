import 'package:flutter_app/data/security/password_hasher.dart';
import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_app/domain/repositories/i_user_repository.dart';
import 'package:hive/hive.dart';

class HiveUserRepository implements IUserRepository {
  static const String _sessionKey = '__current_session__';
  final Box<User> _userBox;

  const HiveUserRepository(this._userBox);

  @override
  Future<bool> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == _sessionKey) {
      return false;
    }
    final user = _userBox.get(normalizedEmail);
    if (user == null || !PasswordHasher.verify(password, user.password)) {
      return false;
    }
    await _userBox.put(_sessionKey, user);
    return true;
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == _sessionKey ||
        _userBox.containsKey(normalizedEmail)) {
      return false;
    }

    final newUser = User(
      name: name.trim(),
      email: normalizedEmail,
      password: PasswordHasher.hash(password),
    );
    await _userBox.put(normalizedEmail, newUser);
    await _userBox.put(_sessionKey, newUser);
    return true;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _userBox.get(_sessionKey);
  }

  @override
  Future<void> logout() async {
    await _userBox.delete(_sessionKey);
  }
}
