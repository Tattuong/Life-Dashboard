class CountdownEvent {
  final String id;
  final String title;
  final DateTime targetDate;
  final String icon;
  final int colorIndex;

  CountdownEvent({
    required this.id,
    required this.title,
    required this.targetDate,
    this.icon = 'event',
    this.colorIndex = 0,
  });

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetDate': targetDate.toIso8601String(),
        'icon': icon,
        'colorIndex': colorIndex,
      };

  factory CountdownEvent.fromJson(Map<String, dynamic> json) => CountdownEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        targetDate: DateTime.parse(json['targetDate'] as String),
        icon: json['icon'] as String? ?? 'event',
        colorIndex: json['colorIndex'] as int? ?? 0,
      );

  CountdownEvent copyWith({String? title, DateTime? targetDate, String? icon, int? colorIndex}) =>
      CountdownEvent(
        id: id,
        title: title ?? this.title,
        targetDate: targetDate ?? this.targetDate,
        icon: icon ?? this.icon,
        colorIndex: colorIndex ?? this.colorIndex,
      );
}
