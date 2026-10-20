import 'package:flutter_app/models/routine.dart';

abstract class IRoutineRepository {
  Future<List<Routine>> getAllRoutines();
  Future<void> addRoutine(Routine routine);
  Future<void> updateRoutine(Routine routine);
  Future<void> deleteRoutine(dynamic key);
}
