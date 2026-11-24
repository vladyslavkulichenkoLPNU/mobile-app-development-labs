import 'package:flutter/material.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/validators/routine_validator.dart';
import 'package:flutter_app/ui/utils/routine_icons.dart';
import 'package:flutter_app/ui/widgets/input_text_field.dart';

Future<Routine?> showRoutineFormDialog({
  required BuildContext context,
  Routine? initialRoutine,
}) {
  return showDialog<Routine>(
    context: context,
    builder: (context) => _RoutineFormDialog(initialRoutine: initialRoutine),
  );
}

class _RoutineFormDialog extends StatefulWidget {
  final Routine? initialRoutine;

  const _RoutineFormDialog({this.initialRoutine});

  @override
  State<_RoutineFormDialog> createState() => _RoutineFormDialogState();
}

class _RoutineFormDialogState extends State<_RoutineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _timeController;
  late final TextEditingController _subtitleController;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRoutine;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _timeController = TextEditingController(text: initial?.time ?? '');
    _subtitleController = TextEditingController(text: initial?.subtitle ?? '');
    final initialIcon = initial?.icon;
    _selectedIcon =
        initialIcon != null && RoutineIcons.icons.containsKey(initialIcon)
        ? initialIcon
        : RoutineIcons.icons.keys.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  TimeOfDay _parseInitialTime(String raw) {
    final trimmed = raw.trim().toUpperCase();
    final match12 = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$')
        .firstMatch(trimmed);
    if (match12 != null) {
      var hour = int.parse(match12.group(1)!);
      final minute = int.parse(match12.group(2)!);
      final period = match12.group(3)!;
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    final match24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (match24 != null) {
      final hour = int.parse(match24.group(1)!);
      final minute = int.parse(match24.group(2)!);
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return TimeOfDay.now();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseInitialTime(_timeController.text),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _timeController.text = picked.format(context).replaceAll('\u202F', ' ');
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final time = _timeController.text.trim();
    final subtitle = _subtitleController.text.trim();
    final existing = widget.initialRoutine;

    final routine = existing != null
        ? existing.copyWith(
            title: title,
            time: time,
            subtitle: subtitle,
            icon: _selectedIcon,
          )
        : Routine(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            time: time,
            title: title,
            subtitle: subtitle,
            icon: _selectedIcon,
          );

    Navigator.pop(context, routine);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRoutine != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Routine' : 'New Routine'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                validator: RoutineValidator.validateTitle,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: _pickTime,
                  validator: RoutineValidator.validateTime,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    hintText: 'Tap to pick a time',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: _pickTime,
                    ),
                  ),
                ),
              ),
              CustomTextField(
                label: 'Actions / Description',
                controller: _subtitleController,
                validator: RoutineValidator.validateSubtitle,
              ),
              const Text('Icon'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RoutineIcons.icons.entries.map((entry) {
                  final isSelected = _selectedIcon == entry.key;
                  return ChoiceChip(
                    label: Icon(
                      entry.value,
                      color: isSelected ? Colors.white : Colors.teal,
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: Colors.teal,
                    onSelected: (_) {
                      setState(() {
                        _selectedIcon = entry.key;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
