import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/repos/users/i_user_repo.dart';
import 'package:hive/hive.dart';

class HiveUserRepository implements IUserRepository {
  final Box<User> _userBox;

  HiveUserRepository(this._userBox);

  @override
  Future<bool> login(String email, String password) async {
    final user = _userBox.get(email);
    if (user == null) {
      return false;
    }
    return user.password == password;
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    if (_userBox.containsKey(email)) {
      return false;
    }

    final newUser = User(name: name, email: email, password: password);
    await _userBox.put(email, newUser);
    return true;
  }
}
