import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
import 'package:flutter_app/ui/utils/routine_icons.dart';
import 'package:flutter_app/ui/widgets/centered_content.dart';
import 'package:flutter_app/ui/widgets/confirm_dialog.dart';
import 'package:flutter_app/ui/widgets/routine_card.dart';
import 'package:flutter_app/ui/widgets/routine_form_dialog.dart';

class HomeScreen extends StatefulWidget {
  final IRoutineRepository routineRepository;

  const HomeScreen({required this.routineRepository, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Routine> _routines = [];
  bool _isLoading = true;
  bool _isMutating = false;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final fetchedRoutines = await widget.routineRepository.getAllRoutines();
    if (!mounted) return;
    setState(() {
      _routines = List<Routine>.of(fetchedRoutines);
      _isLoading = false;
    });
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    if (_isMutating) return;

    setState(() => _isMutating = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isMutating = false);
      }
    }
  }

  void _replaceRoutine(Routine updated) {
    final index = _routines.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      _routines[index] = updated;
    }
  }

  Future<void> _toggleRoutine(Routine routine, bool newValue) async {
    final updated = routine.copyWith(isActive: newValue);
    await _runMutation(() async {
      await widget.routineRepository.updateRoutine(updated);
      if (!mounted) return;
      setState(() => _replaceRoutine(updated));
    });
  }

  Future<void> _addRoutine() async {
    if (_isMutating) return;

    final newRoutine = await showRoutineFormDialog(context: context);
    if (newRoutine == null || !mounted) return;

    await _runMutation(() async {
      await widget.routineRepository.addRoutine(newRoutine);
      if (!mounted) return;
      setState(() => _routines.add(newRoutine));
    });
  }

  Future<void> _editRoutine(Routine routine) async {
    if (_isMutating) return;

    final updated = await showRoutineFormDialog(
      context: context,
      initialRoutine: routine,
    );
    if (updated == null || !mounted) return;

    await _runMutation(() async {
      await widget.routineRepository.updateRoutine(updated);
      if (!mounted) return;
      setState(() => _replaceRoutine(updated));
    });
  }

  Future<void> _deleteRoutine(Routine routine) async {
    if (_isMutating) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Routine',
      content: 'Are you sure you want to delete "${routine.title}"?',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    await _runMutation(() async {
      await widget.routineRepository.deleteRoutine(routine.id);
      if (!mounted) return;
      setState(() {
        _routines.removeWhere((item) => item.id == routine.id);
      });
    });
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_isMutating) const LinearProgressIndicator(),
        Expanded(
          child: _routines.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No routines yet. Tap + to add one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : CenteredContent(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _routines.length,
                    itemBuilder: (context, index) {
                      final routine = _routines[index];
                      return RoutineCard(
                        time: routine.time,
                        title: routine.title,
                        subtitle: routine.subtitle,
                        icon: RoutineIcons.fromName(routine.icon),
                        isActive: routine.isActive,
                        onChanged: (bool value) =>
                            _toggleRoutine(routine, value),
                        onEdit: () => _editRoutine(routine),
                        onDelete: () => _deleteRoutine(routine),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showConfirmDialog(
          context: context,
          title: 'Exit App',
          content: 'Are you sure you want to leave?',
          confirmLabel: 'Exit',
        );
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My IoT Routines'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _isMutating ? null : _addRoutine,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
