import 'package:flutter/material.dart';

class RoutineCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const RoutineCard({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.teal),
        title: Text(
          '$time - $title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Switch(value: isActive, onChanged: onChanged),
      ),
    );
  }
}
