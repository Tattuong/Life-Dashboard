class WaterLog {
  final String id;
  final DateTime date;
  final int glasses;
  final int goal;

  WaterLog({
    required this.id,
    required this.date,
    required this.glasses,
    this.goal = 8,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'glasses': glasses,
        'goal': goal,
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        glasses: json['glasses'] as int? ?? 0,
        goal: json['goal'] as int? ?? 8,
      );
}

class SleepLog {
  final String id;
  final DateTime date;
  final int minutes;
  final String quality;
  final int deepMinutes;
  final int lightMinutes;
  final int remMinutes;
  final int awakeMinutes;
  final String sleepTime;
  final String wakeTime;

  SleepLog({
    required this.id,
    required this.date,
    required this.minutes,
    this.quality = 'Good',
    this.deepMinutes = 90,
    this.lightMinutes = 180,
    this.remMinutes = 90,
    this.awakeMinutes = 12,
    this.sleepTime = '23:00',
    this.wakeTime = '07:00',
  });

  String get durationText {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  int get qualityScore {
    if (minutes >= 420 && minutes <= 540) return 85;
    if (minutes >= 360) return 70;
    return 50;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'minutes': minutes,
        'quality': quality,
        'deepMinutes': deepMinutes,
        'lightMinutes': lightMinutes,
        'remMinutes': remMinutes,
        'awakeMinutes': awakeMinutes,
        'sleepTime': sleepTime,
        'wakeTime': wakeTime,
      };

  factory SleepLog.fromJson(Map<String, dynamic> json) => SleepLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        minutes: json['minutes'] as int? ?? 0,
        quality: json['quality'] as String? ?? 'Good',
        deepMinutes: json['deepMinutes'] as int? ?? 90,
        lightMinutes: json['lightMinutes'] as int? ?? 180,
        remMinutes: json['remMinutes'] as int? ?? 90,
        awakeMinutes: json['awakeMinutes'] as int? ?? 12,
        sleepTime: json['sleepTime'] as String? ?? '23:00',
        wakeTime: json['wakeTime'] as String? ?? '07:00',
      );
}

class StepsLog {
  final String id;
  final DateTime date;
  final int steps;
  final int goal;
  final double distanceKm;
  final int calories;
  final int activeMinutes;

  StepsLog({
    required this.id,
    required this.date,
    required this.steps,
    this.goal = 10000,
    this.distanceKm = 0,
    this.calories = 0,
    this.activeMinutes = 0,
  });

  double get progress => goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'steps': steps,
        'goal': goal,
        'distanceKm': distanceKm,
        'calories': calories,
        'activeMinutes': activeMinutes,
      };

  factory StepsLog.fromJson(Map<String, dynamic> json) => StepsLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        steps: json['steps'] as int? ?? 0,
        goal: json['goal'] as int? ?? 10000,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        calories: json['calories'] as int? ?? 0,
        activeMinutes: json['activeMinutes'] as int? ?? 0,
      );
}

class MoodLog {
  final String id;
  final DateTime date;
  final int mood; // 0=Very Bad, 1=Bad, 2=Neutral, 3=Good, 4=Great
  final String? note;

  MoodLog({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  static const moodLabels = ['Very Bad', 'Bad', 'Neutral', 'Good', 'Great'];
  static const moodEmojis = ['😢', '😔', '😐', '😊', '🤩'];

  String get label => moodLabels[mood.clamp(0, 4)];
  String get emoji => moodEmojis[mood.clamp(0, 4)];

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood,
        'note': note,
      };

  factory MoodLog.fromJson(Map<String, dynamic> json) => MoodLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mood: json['mood'] as int? ?? 2,
        note: json['note'] as String?,
      );
}
