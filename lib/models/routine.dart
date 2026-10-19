import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 0)
class Routine extends HiveObject {
  @HiveField(0)
  String time;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  String icon;

  @HiveField(4)
  bool isActive;

  Routine({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isActive = true,
  });
}
