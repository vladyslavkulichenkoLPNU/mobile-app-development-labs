import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/routine_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> routines = [
      {
        'time': '07:00 AM',
        'title': 'Morning Wakeup',
        'subtitle': 'Thermostat 22°C, Bedroom Blinds Open, Coffee Maker ON',
        'icon': 'wb_sunny',
      },
      {
        'time': '09:00 AM',
        'title': 'Leave for Work',
        'subtitle': 'All Lights OFF, Security System ARMED, Doors LOCKED',
        'icon': 'security',
      },
      {
        'time': '18:30 PM',
        'title': 'Evening Mode',
        'subtitle': 'Living Room Lights Dimmed (30%), TV ON',
        'icon': 'nightlight_round',
      },
    ];

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
        body: Center(
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
                  time: routine['time']!,
                  title: routine['title']!,
                  subtitle: routine['subtitle']!,
                  icon: _getIcon(routine['icon']!),
                  isActive: true,
                  onChanged: (bool value) {},
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
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
}
