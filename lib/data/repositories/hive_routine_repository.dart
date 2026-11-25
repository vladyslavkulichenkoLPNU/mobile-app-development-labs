import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
import 'package:hive/hive.dart';

class HiveRoutineRepository implements IRoutineRepository {
  final Box<Routine> _routineBox;

  const HiveRoutineRepository(this._routineBox);

  @override
  Future<List<Routine>> getAllRoutines() async {
    return _routineBox.toMap().entries.map((entry) {
      final routine = entry.value;
      if (routine.id.isEmpty) {
        return routine.copyWith(id: entry.key.toString());
      }
      return routine;
    }).toList();
  }

  @override
  Future<void> addRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    final key = _resolveExistingKey(routine.id) ?? routine.id;
    await _routineBox.put(key, routine);
  }

  @override
  Future<void> deleteRoutine(String id) async {
    final key = _resolveExistingKey(id);
    if (key != null) {
      await _routineBox.delete(key);
    }
  }

  Object? _resolveExistingKey(String id) {
    if (_routineBox.containsKey(id)) {
      return id;
    }
    final intKey = int.tryParse(id);
    if (intKey != null && _routineBox.containsKey(intKey)) {
      return intKey;
    }
    return null;
  }
}
