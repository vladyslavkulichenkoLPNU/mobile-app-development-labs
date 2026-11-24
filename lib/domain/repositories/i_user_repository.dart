import 'package:flutter_app/domain/models/user.dart';

abstract class IUserRepository {
  Future<bool> login(String email, String password);
  Future<bool> register(String name, String email, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();
}
