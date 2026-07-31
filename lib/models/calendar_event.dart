class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String category;
  final int colorIndex;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location = '',
    this.category = 'General',
    this.colorIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'location': location,
        'category': category,
        'colorIndex': colorIndex,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        location: json['location'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        colorIndex: json['colorIndex'] as int? ?? 0,
      );

  CalendarEvent copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? category,
    int? colorIndex,
  }) =>
      CalendarEvent(
        id: id,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        location: location ?? this.location,
        category: category ?? this.category,
        colorIndex: colorIndex ?? this.colorIndex,
      );
}
