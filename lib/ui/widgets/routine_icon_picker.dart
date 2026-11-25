import 'package:flutter_app/ui/utils/routine_icons.dart';
import 'package:material_ui/material_ui.dart';

class RoutineIconPicker extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onSelected;

  const RoutineIconPicker({
    required this.selectedIcon,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Icon'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RoutineIcons.icons.entries.map((entry) {
            final isSelected = selectedIcon == entry.key;
            return ChoiceChip(
              label: Icon(
                entry.value,
                color: isSelected ? Colors.white : Colors.teal,
              ),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: Colors.teal,
              onSelected: (_) => onSelected(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }
}
