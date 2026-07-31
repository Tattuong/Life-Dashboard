class Goal {
  final String id;
  final String title;
  final String unit;
  final double current;
  final double target;
  final String icon;
  final bool achieved;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.unit,
    required this.current,
    required this.target,
    this.icon = 'flag',
    this.achieved = false,
    required this.createdAt,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0;
  int get progressPercent => (progress * 100).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'unit': unit,
        'current': current,
        'target': target,
        'icon': icon,
        'achieved': achieved,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        unit: json['unit'] as String? ?? '',
        current: (json['current'] as num?)?.toDouble() ?? 0,
        target: (json['target'] as num?)?.toDouble() ?? 100,
        icon: json['icon'] as String? ?? 'flag',
        achieved: json['achieved'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Goal copyWith({
    String? title,
    String? unit,
    double? current,
    double? target,
    String? icon,
    bool? achieved,
  }) =>
      Goal(
        id: id,
        title: title ?? this.title,
        unit: unit ?? this.unit,
        current: current ?? this.current,
        target: target ?? this.target,
        icon: icon ?? this.icon,
        achieved: achieved ?? this.achieved,
        createdAt: createdAt,
      );
}
