import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/validators/routine_validator.dart';
import 'package:flutter_app/ui/utils/routine_icons.dart';
import 'package:flutter_app/ui/utils/time_parser.dart';
import 'package:flutter_app/ui/widgets/input_text_field.dart';
import 'package:flutter_app/ui/widgets/routine_icon_picker.dart';
import 'package:material_ui/material_ui.dart';

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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeParser.parseOrNow(_timeController.text),
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
              CustomTextField(
                label: 'Time',
                hintText: 'Tap to pick a time',
                controller: _timeController,
                readOnly: true,
                onTap: _pickTime,
                validator: RoutineValidator.validateTime,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _pickTime,
                ),
              ),
              CustomTextField(
                label: 'Actions / Description',
                controller: _subtitleController,
                validator: RoutineValidator.validateSubtitle,
              ),
              RoutineIconPicker(
                selectedIcon: _selectedIcon,
                onSelected: (icon) => setState(() => _selectedIcon = icon),
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
