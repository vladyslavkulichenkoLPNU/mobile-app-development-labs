import 'package:flutter/material.dart';

abstract final class RoutineIcons {
  static const Map<String, IconData> icons = {
    'wb_sunny': Icons.wb_sunny,
    'security': Icons.security,
    'nightlight_round': Icons.nightlight_round,
    'device_hub': Icons.device_hub,
  };

  static IconData fromName(String name) {
    return icons[name] ?? Icons.device_hub;
  }
}
