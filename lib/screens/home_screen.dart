import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/routine.dart';
import 'package:flutter_app/repos/routines/i_routine_repo.dart';
import 'package:flutter_app/repos/routines/routine_repo.dart';
import 'package:flutter_app/widgets/routine_card.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IRoutineRepository _repository;
  List<Routine> routines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = HiveRoutineRepository(Hive.box<Routine>('routinesBox'));
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final fetchedRoutines = await _repository.getAllRoutines();

    if (fetchedRoutines.isEmpty) {
      final defaultRoutines = [
        Routine(
          time: '07:00 AM',
          title: 'Morning Wakeup',
          subtitle: 'Thermostat 22 C, Bedroom Blinds Open, Coffee Maker ON',
          icon: 'wb_sunny',
        ),
        Routine(
          time: '09:00 AM',
          title: 'Leave for Work',
          subtitle: 'All Lights OFF, Security System ARMED, Doors LOCKED',
          icon: 'security',
        ),
        Routine(
          time: '18:30 PM',
          title: 'Evening Mode',
          subtitle: 'Living Room Lights Dimmed (30%), TV ON',
          icon: 'nightlight_round',
        ),
      ];
      for (var routine in defaultRoutines) {
        await _repository.addRoutine(routine);
      }
      routines = await _repository.getAllRoutines();
    } else {
      routines = fetchedRoutines;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _toggleRoutine(Routine routine, bool newValue) async {
    routine.isActive = newValue;
    await _repository.updateRoutine(routine);
    setState(() {});
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

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog<Null>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to leave?'),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const Expanded(
                      child: TextButton(
                        onPressed: SystemNavigator.pop,
                        child: Text(
                          'Exit',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
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
              time: '22:00 PM',
              title: 'Sleep Mode',
              subtitle: 'All Lights OFF, Doors LOCKED',
              icon: 'nightlight_round',
            );
            await _repository.addRoutine(newRoutine);
            _loadRoutines();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
