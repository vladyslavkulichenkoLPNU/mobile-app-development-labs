import 'package:flutter_app/domain/models/routine.dart';

const List<Routine> defaultRoutines = [
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
