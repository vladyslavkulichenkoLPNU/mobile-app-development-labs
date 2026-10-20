import 'package:flutter_app/models/routine.dart';
import 'package:flutter_app/repos/routines/i_routine_repo.dart';
import 'package:hive/hive.dart';

class HiveRoutineRepository implements IRoutineRepository {
  final Box<Routine> _routineBox;

  HiveRoutineRepository(this._routineBox);

  @override
  Future<List<Routine>> getAllRoutines() async {
    return _routineBox.values.toList();
  }

  @override
  Future<void> addRoutine(Routine routine) async {
    await _routineBox.add(routine);
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    await routine.save();
  }

  @override
  Future<void> deleteRoutine(dynamic key) async {
    await _routineBox.delete(key);
  }
}
