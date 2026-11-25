import 'package:material_ui/material_ui.dart';

abstract final class TimeParser {
  static final RegExp _time12Regex = RegExp(
    r'^(\d{1,2}):(\d{2})[\s\u202F]*(AM|PM)$',
  );
  static final RegExp _time24Regex = RegExp(r'^(\d{1,2}):(\d{2})$');

  static TimeOfDay parseOrNow(String raw) {
    final trimmed = raw.trim().toUpperCase();
    final match12 = _time12Regex.firstMatch(trimmed);
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

    final match24 = _time24Regex.firstMatch(trimmed);
    if (match24 != null) {
      final hour = int.parse(match24.group(1)!);
      final minute = int.parse(match24.group(2)!);
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return TimeOfDay.now();
  }
}
