import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/calendar_event.dart';
import '../models/countdown_event.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../models/health_log.dart';
import '../models/todo_task.dart';

class LifeProvider extends ChangeNotifier {
  static const _eventsKey = 'ld_calendar_events';
  static const _todosKey = 'ld_todos';
  static const _goalsKey = 'ld_goals';
  static const _countdownsKey = 'ld_countdowns';
  static const _expensesKey = 'ld_expenses';
  static const _waterKey = 'ld_water';
  static const _sleepKey = 'ld_sleep';
  static const _stepsKey = 'ld_steps';
  static const _moodKey = 'ld_mood';
  static const _profileKey = 'ld_profile';

  final _uuid = const Uuid();

  List<CalendarEvent> _events = [];
  List<TodoTask> _todos = [];
  List<Goal> _goals = [];
  List<CountdownEvent> _countdowns = [];
  List<Expense> _expenses = [];
  List<WaterLog> _waterLogs = [];
  List<SleepLog> _sleepLogs = [];
  List<StepsLog> _stepsLogs = [];
  List<MoodLog> _moodLogs = [];
  String _userName = '';
  int _waterGoal = 8;
  int _stepsGoal = 10000;

  List<CalendarEvent> get events => List.unmodifiable(_events);
  List<TodoTask> get todos => List.unmodifiable(_todos);
  List<Goal> get goals => List.unmodifiable(_goals);
  List<CountdownEvent> get countdowns => List.unmodifiable(_countdowns);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<WaterLog> get waterLogs => List.unmodifiable(_waterLogs);
  List<SleepLog> get sleepLogs => List.unmodifiable(_sleepLogs);
  List<StepsLog> get stepsLogs => List.unmodifiable(_stepsLogs);
  List<MoodLog> get moodLogs => List.unmodifiable(_moodLogs);
  String get userName => _userName;
  int get waterGoal => _waterGoal;
  int get stepsGoal => _stepsGoal;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    await _loadAll();
    _initialized = true;
    notifyListeners();
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  // --- Calendar ---
  List<CalendarEvent> eventsForDate(DateTime date) {
    return _events.where((e) {
      final d = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
      final target = DateTime(date.year, date.month, date.day);
      return d == target;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  int get todayEventCount => eventsForDate(_today()).length;

  Future<void> addEvent(CalendarEvent event) async {
    _events.add(event);
    await _saveList(_eventsKey, _events.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i >= 0) _events[i] = event;
    await _saveList(_eventsKey, _events.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _saveList(_eventsKey, _events.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  // --- Todo ---
  List<TodoTask> todosForDate(DateTime date) {
    return _todos.where((t) {
      final d = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      final target = DateTime(date.year, date.month, date.day);
      return d == target;
    }).toList();
  }

  List<TodoTask> get todayTodos => todosForDate(_today());
  int get todayTodoCount => todayTodos.where((t) => !t.completed).length;

  Future<void> addTodo(TodoTask task) async {
    _todos.add(task);
    await _saveList(_todosKey, _todos.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> toggleTodo(String id) async {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _todos[i] = _todos[i].copyWith(completed: !_todos[i].completed);
      await _saveList(_todosKey, _todos.map((e) => e.toJson()).toList());
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await _saveList(_todosKey, _todos.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  // --- Goals ---
  List<Goal> get activeGoals => _goals.where((g) => !g.achieved).toList();
  List<Goal> get achievedGoals => _goals.where((g) => g.achieved).toList();
  int get activeGoalCount => activeGoals.length;

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _saveList(_goalsKey, _goals.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> updateGoalProgress(String id, double current) async {
    final i = _goals.indexWhere((g) => g.id == id);
    if (i >= 0) {
      final achieved = current >= _goals[i].target;
      _goals[i] = _goals[i].copyWith(current: current, achieved: achieved);
      await _saveList(_goalsKey, _goals.map((e) => e.toJson()).toList());
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveList(_goalsKey, _goals.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  // --- Countdown ---
  Future<void> addCountdown(CountdownEvent event) async {
    _countdowns.add(event);
    await _saveList(_countdownsKey, _countdowns.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> deleteCountdown(String id) async {
    _countdowns.removeWhere((c) => c.id == id);
    await _saveList(_countdownsKey, _countdowns.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  // --- Expenses ---
  List<Expense> expensesForMonth(int year, int month) {
    return _expenses.where((e) => e.date.year == year && e.date.month == month).toList();
  }

  double totalExpensesForMonth(int year, int month) {
    return expensesForMonth(year, month).fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> categoryTotalsForMonth(int year, int month) {
    final map = <String, double>{};
    for (final e in expensesForMonth(year, month)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await _saveList(_expensesKey, _expenses.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _saveList(_expensesKey, _expenses.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  // --- Water ---
  WaterLog? waterForDate(DateTime date) {
    final key = _dateKey(date);
    try {
      return _waterLogs.firstWhere((w) => _dateKey(w.date) == key);
    } catch (_) {
      return null;
    }
  }

  WaterLog get todayWater => waterForDate(_today()) ?? WaterLog(id: '', date: _today(), glasses: 0, goal: _waterGoal);

  Future<void> addWaterGlass() async {
    final today = _today();
    final existing = waterForDate(today);
    if (existing != null) {
      final i = _waterLogs.indexWhere((w) => w.id == existing.id);
      _waterLogs[i] = WaterLog(id: existing.id, date: today, glasses: existing.glasses + 1, goal: _waterGoal);
    } else {
      _waterLogs.add(WaterLog(id: _uuid.v4(), date: today, glasses: 1, goal: _waterGoal));
    }
    await _saveList(_waterKey, _waterLogs.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  List<WaterLog> waterLast7Days() {
    final result = <WaterLog>[];
    for (var i = 6; i >= 0; i--) {
      final d = _today().subtract(Duration(days: i));
      result.add(waterForDate(d) ?? WaterLog(id: '', date: d, glasses: 0, goal: _waterGoal));
    }
    return result;
  }

  // --- Sleep ---
  SleepLog? sleepForDate(DateTime date) {
    final key = _dateKey(date);
    try {
      return _sleepLogs.firstWhere((s) => _dateKey(s.date) == key);
    } catch (_) {
      return null;
    }
  }

  SleepLog? get lastNightSleep {
    final yesterday = _today().subtract(const Duration(days: 1));
    return sleepForDate(yesterday) ?? sleepForDate(_today());
  }

  Future<void> logSleep(SleepLog log) async {
    final key = _dateKey(log.date);
    _sleepLogs.removeWhere((s) => _dateKey(s.date) == key);
    _sleepLogs.add(log);
    await _saveList(_sleepKey, _sleepLogs.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  List<SleepLog> sleepLast7Days() {
    final result = <SleepLog>[];
    for (var i = 6; i >= 0; i--) {
      final d = _today().subtract(Duration(days: i));
      result.add(sleepForDate(d) ?? SleepLog(id: '', date: d, minutes: 0));
    }
    return result;
  }

  // --- Steps ---
  StepsLog? stepsForDate(DateTime date) {
    final key = _dateKey(date);
    try {
      return _stepsLogs.firstWhere((s) => _dateKey(s.date) == key);
    } catch (_) {
      return null;
    }
  }

  StepsLog get todaySteps => stepsForDate(_today()) ??
      StepsLog(id: '', date: _today(), steps: 0, goal: _stepsGoal);

  Future<void> updateSteps(int steps) async {
    final today = _today();
    final existing = stepsForDate(today);
    final distance = steps * 0.000762;
    final calories = (steps * 0.04).round();
    final active = (steps / 100).round();
    if (existing != null && existing.id.isNotEmpty) {
      final i = _stepsLogs.indexWhere((s) => s.id == existing.id);
      _stepsLogs[i] = StepsLog(
        id: existing.id,
        date: today,
        steps: steps,
        goal: _stepsGoal,
        distanceKm: distance,
        calories: calories,
        activeMinutes: active,
      );
    } else {
      _stepsLogs.add(StepsLog(
        id: _uuid.v4(),
        date: today,
        steps: steps,
        goal: _stepsGoal,
        distanceKm: distance,
        calories: calories,
        activeMinutes: active,
      ));
    }
    await _saveList(_stepsKey, _stepsLogs.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  List<StepsLog> stepsLast7Days() {
    final result = <StepsLog>[];
    for (var i = 6; i >= 0; i--) {
      final d = _today().subtract(Duration(days: i));
      result.add(stepsForDate(d) ?? StepsLog(id: '', date: d, steps: 0, goal: _stepsGoal));
    }
    return result;
  }

  // --- Mood ---
  MoodLog? moodForDate(DateTime date) {
    final key = _dateKey(date);
    try {
      return _moodLogs.firstWhere((m) => _dateKey(m.date) == key);
    } catch (_) {
      return null;
    }
  }

  MoodLog? get todayMood => moodForDate(_today());

  Future<void> logMood(int mood, {String? note}) async {
    final today = _today();
    final existing = moodForDate(today);
    if (existing != null) {
      final i = _moodLogs.indexWhere((m) => m.id == existing.id);
      _moodLogs[i] = MoodLog(id: existing.id, date: today, mood: mood, note: note);
    } else {
      _moodLogs.add(MoodLog(id: _uuid.v4(), date: today, mood: mood, note: note));
    }
    await _saveList(_moodKey, _moodLogs.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  List<MoodLog> moodLast7Days() {
    final result = <MoodLog>[];
    for (var i = 6; i >= 0; i--) {
      final d = _today().subtract(Duration(days: i));
      final m = moodForDate(d);
      if (m != null) result.add(m);
    }
    return result;
  }

  // --- Today Score ---
  int get todayScore {
    var score = 0;
    final water = todayWater;
    score += ((water.glasses / water.goal) * 20).clamp(0, 20).round();
    final steps = todaySteps;
    score += ((steps.steps / steps.goal) * 20).clamp(0, 20).round();
    final sleep = lastNightSleep;
    if (sleep != null && sleep.minutes > 0) {
      score += sleep.minutes >= 420 ? 20 : (sleep.minutes / 420 * 20).round();
    }
    final mood = todayMood;
    if (mood != null) score += (mood.mood + 1) * 4;
    final todos = todayTodos;
    if (todos.isNotEmpty) {
      final done = todos.where((t) => t.completed).length;
      score += ((done / todos.length) * 20).round();
    } else {
      score += 10;
    }
    return score.clamp(0, 100);
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await StorageService.instance.saveData(_profileKey, {'name': name});
    notifyListeners();
  }

  // --- Persistence ---
  Future<void> _saveList(String key, List<Map<String, dynamic>> data) async {
    await StorageService.instance.saveString(key, StorageService.encodeList(data));
  }

  Future<List<Map<String, dynamic>>> _loadList(String key) async {
    final raw = await StorageService.instance.getString(key);
    if (raw == null) return [];
    return StorageService.decodeList(raw);
  }

  Future<void> _loadAll() async {
    _events = (await _loadList(_eventsKey)).map(CalendarEvent.fromJson).toList();
    _todos = (await _loadList(_todosKey)).map(TodoTask.fromJson).toList();
    _goals = (await _loadList(_goalsKey)).map(Goal.fromJson).toList();
    _countdowns = (await _loadList(_countdownsKey)).map(CountdownEvent.fromJson).toList();
    _expenses = (await _loadList(_expensesKey)).map(Expense.fromJson).toList();
    _waterLogs = (await _loadList(_waterKey)).map(WaterLog.fromJson).toList();
    _sleepLogs = (await _loadList(_sleepKey)).map(SleepLog.fromJson).toList();
    _stepsLogs = (await _loadList(_stepsKey)).map(StepsLog.fromJson).toList();
    _moodLogs = (await _loadList(_moodKey)).map(MoodLog.fromJson).toList();
    final profile = await StorageService.instance.getData(_profileKey);
    if (profile != null) _userName = profile['name'] as String? ?? '';
  }

  Map<String, dynamic> exportAllData() => {
        'events': _events.map((e) => e.toJson()).toList(),
        'todos': _todos.map((e) => e.toJson()).toList(),
        'goals': _goals.map((e) => e.toJson()).toList(),
        'countdowns': _countdowns.map((e) => e.toJson()).toList(),
        'expenses': _expenses.map((e) => e.toJson()).toList(),
        'water': _waterLogs.map((e) => e.toJson()).toList(),
        'sleep': _sleepLogs.map((e) => e.toJson()).toList(),
        'steps': _stepsLogs.map((e) => e.toJson()).toList(),
        'mood': _moodLogs.map((e) => e.toJson()).toList(),
      };
}
