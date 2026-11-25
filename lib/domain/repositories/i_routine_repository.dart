import 'package:flutter_app/domain/models/routine.dart';

abstract class IRoutineRepository {
  Future<List<Routine>> getAllRoutines();
  Future<void> addRoutine(Routine routine);
  Future<void> updateRoutine(Routine routine);
  Future<void> deleteRoutine(String id);
}
