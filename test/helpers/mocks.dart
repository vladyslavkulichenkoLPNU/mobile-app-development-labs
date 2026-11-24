import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
import 'package:flutter_app/domain/repositories/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

class MockRoutineRepository extends Mock implements IRoutineRepository {}

class FakeRoutine extends Fake implements Routine {}

const testUser = User(
  name: 'Jane Doe',
  email: 'jane@example.com',
  password: 'password123',
);

const testRoutine = Routine(
  id: '1',
  time: '07:00 AM',
  title: 'Morning Wakeup',
  subtitle: 'Lights ON, Coffee Maker ON',
  icon: 'wb_sunny',
);
