abstract final class RoutineValidator {
  static final RegExp _time24Regex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
  static final RegExp _time12Regex = RegExp(
    r'^(0?[1-9]|1[0-2]):[0-5]\d[\s\u202F]?(AM|PM)$',
    caseSensitive: false,
  );

  static String? validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter a routine title';
    }
    if (trimmed.length < 2) {
      return 'Title must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'Title must be at most 50 characters';
    }
    return null;
  }

  static String? validateTime(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please pick a time';
    }
    if (!_time12Regex.hasMatch(trimmed) && !_time24Regex.hasMatch(trimmed)) {
      return 'Enter a valid time (e.g. 07:00 AM or 18:30)';
    }
    return null;
  }

  static String? validateSubtitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter routine actions';
    }
    if (trimmed.length < 3) {
      return 'Description must be at least 3 characters';
    }
    if (trimmed.length > 150) {
      return 'Description must be at most 150 characters';
    }
    return null;
  }
}
