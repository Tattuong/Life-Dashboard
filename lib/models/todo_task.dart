class TodoTask {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool completed;
  final String? time;
  final int priority;

  TodoTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.completed = false,
    this.time,
    this.priority = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'completed': completed,
        'time': time,
        'priority': priority,
      };

  factory TodoTask.fromJson(Map<String, dynamic> json) => TodoTask(
        id: json['id'] as String,
        title: json['title'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        completed: json['completed'] as bool? ?? false,
        time: json['time'] as String?,
        priority: json['priority'] as int? ?? 0,
      );

  TodoTask copyWith({String? title, DateTime? dueDate, bool? completed, String? time, int? priority}) =>
      TodoTask(
        id: id,
        title: title ?? this.title,
        dueDate: dueDate ?? this.dueDate,
        completed: completed ?? this.completed,
        time: time ?? this.time,
        priority: priority ?? this.priority,
      );
}
