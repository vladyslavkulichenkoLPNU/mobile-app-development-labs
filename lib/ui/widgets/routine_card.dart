import 'package:flutter/material.dart';

class RoutineCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoutineCard({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(icon, size: 32, color: Colors.teal),
            title: Text(
              '$time - $title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle),
            trailing: Switch(value: isActive, onChanged: onChanged),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
