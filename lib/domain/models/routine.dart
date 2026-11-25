class Routine {
  final String id;
  final String time;
  final String title;
  final String subtitle;
  final String icon;
  final bool isActive;

  const Routine({
    required this.id,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isActive = true,
  });

  Routine copyWith({
    String? id,
    String? time,
    String? title,
    String? subtitle,
    String? icon,
    bool? isActive,
  }) {
    return Routine(
      id: id ?? this.id,
      time: time ?? this.time,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}
