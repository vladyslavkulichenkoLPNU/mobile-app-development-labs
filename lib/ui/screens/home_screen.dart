import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/domain/constants/default_routines.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
import 'package:flutter_app/ui/utils/routine_icons.dart';
import 'package:flutter_app/ui/widgets/centered_content.dart';
import 'package:flutter_app/ui/widgets/confirm_dialog.dart';
import 'package:flutter_app/ui/widgets/routine_card.dart';

class HomeScreen extends StatefulWidget {
  final IRoutineRepository routineRepository;

  const HomeScreen({required this.routineRepository, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Routine> routines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final fetchedRoutines = await widget.routineRepository.getAllRoutines();

    if (fetchedRoutines.isEmpty) {
      for (final routine in defaultRoutines) {
        await widget.routineRepository.addRoutine(routine);
      }
      routines = await widget.routineRepository.getAllRoutines();
    } else {
      routines = fetchedRoutines;
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _toggleRoutine(Routine routine, bool newValue) async {
    final updated = routine.copyWith(isActive: newValue);
    await widget.routineRepository.updateRoutine(updated);
    if (!mounted) return;
    setState(() {
      final index = routines.indexWhere((item) => item.id == routine.id);
      if (index != -1) {
        routines[index] = updated;
      }
    });
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CenteredContent(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return RoutineCard(
                      time: routine.time,
                      title: routine.title,
                      subtitle: routine.subtitle,
                      icon: RoutineIcons.fromName(routine.icon),
                      isActive: routine.isActive,
                      onChanged: (bool value) => _toggleRoutine(routine, value),
                    );
                  },
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newRoutine = Routine(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              time: '22:00 PM',
              title: 'Sleep Mode',
              subtitle: 'All Lights OFF, Doors LOCKED',
              icon: 'nightlight_round',
            );
            await widget.routineRepository.addRoutine(newRoutine);
            await _loadRoutines();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
