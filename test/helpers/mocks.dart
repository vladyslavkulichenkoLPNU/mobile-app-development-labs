import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
import 'package:flutter_app/domain/repositories/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

class MockRoutineRepository extends Mock implements IRoutineRepository {}

const testUser = User(
  name: 'Jane Doe',
  email: 'jane@example.com',
  password: 'password123',
);
