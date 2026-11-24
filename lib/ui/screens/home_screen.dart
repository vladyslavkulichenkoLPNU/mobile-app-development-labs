import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
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
      const defaultRoutines = [
        Routine(
          id: 'default_morning',
          time: '07:00 AM',
          title: 'Morning Wakeup',
          subtitle: 'Thermostat 22 C, Bedroom Blinds Open, Coffee Maker ON',
          icon: 'wb_sunny',
        ),
        Routine(
          id: 'default_work',
          time: '09:00 AM',
          title: 'Leave for Work',
          subtitle: 'All Lights OFF, Security System ARMED, Doors LOCKED',
          icon: 'security',
        ),
        Routine(
          id: 'default_evening',
          time: '18:30 PM',
          title: 'Evening Mode',
          subtitle: 'Living Room Lights Dimmed (30%), TV ON',
          icon: 'nightlight_round',
        ),
      ];
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

  IconData _getIcon(String name) {
    switch (name) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'security':
        return Icons.security;
      case 'nightlight_round':
        return Icons.nightlight_round;
      default:
        return Icons.device_hub;
    }
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
            : Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width > 600
                      ? 600
                      : MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return RoutineCard(
                        time: routine.time,
                        title: routine.title,
                        subtitle: routine.subtitle,
                        icon: _getIcon(routine.icon),
                        isActive: routine.isActive,
                        onChanged: (bool value) =>
                            _toggleRoutine(routine, value),
                      );
                    },
                  ),
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
