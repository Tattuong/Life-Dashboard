import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/todo_task.dart';
import '../../providers/life_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_ui.dart';

enum _TodoTab { today, tomorrow, upcoming }

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  _TodoTab _tab = _TodoTab.today;
  final _uuid = const Uuid();

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  List<TodoTask> _tasksForTab(LifeProvider life) {
    final today = _today();
    final tomorrow = today.add(const Duration(days: 1));

    return switch (_tab) {
      _TodoTab.today => life.todosForDate(today),
      _TodoTab.tomorrow => life.todosForDate(tomorrow),
      _TodoTab.upcoming => life.todos.where((t) {
          final d = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
          return d.isAfter(tomorrow);
        }).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
    };
  }

  Future<void> _toggleTask(TodoTask task) async {
    final life = context.read<LifeProvider>();
    final wasCompleted = task.completed;
    await life.toggleTodo(task.id);
    if (!wasCompleted && mounted) {
      await context.read<ShopProvider>().rewardForTaskComplete();
    }
  }

  Future<void> _showAddTaskDialog() async {
    final titleCtrl = TextEditingController();
    var dueDate = switch (_tab) {
      _TodoTab.today => _today(),
      _TodoTab.tomorrow => _today().add(const Duration(days: 1)),
      _TodoTab.upcoming => _today().add(const Duration(days: 2)),
    };
    var taskTime = TimeOfDay.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppStrings.t(context, 'addTask')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.t(context, 'title'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t(context, 'date')),
                  trailing: Text(DateFormat.yMMMd().format(dueDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: _today(),
                      lastDate: _today().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => dueDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t(context, 'time')),
                  trailing: Text(taskTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: taskTime);
                    if (picked != null) setDialogState(() => taskTime = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
            FilledButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: Text(AppStrings.t(context, 'save')),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;

    final timeStr =
        '${taskTime.hour.toString().padLeft(2, '0')}:${taskTime.minute.toString().padLeft(2, '0')}';

    await context.read<LifeProvider>().addTodo(
          TodoTask(
            id: _uuid.v4(),
            title: titleCtrl.text.trim(),
            dueDate: dueDate,
            time: timeStr,
          ),
        );

    titleCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final tasks = _tasksForTab(life);
    final pending = tasks.where((t) => !t.completed).length;

    return AppPageScaffold(
      title: AppStrings.t(context, 'todo'),
      subtitle: AppStrings.t(context, 'tasksCount', {'count': '$pending'}),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AppFilterChip(
                label: AppStrings.t(context, 'today'),
                selected: _tab == _TodoTab.today,
                onTap: () => setState(() => _tab = _TodoTab.today),
              ),
              AppFilterChip(
                label: AppStrings.t(context, 'tomorrow'),
                selected: _tab == _TodoTab.tomorrow,
                onTap: () => setState(() => _tab = _TodoTab.tomorrow),
              ),
              AppFilterChip(
                label: AppStrings.t(context, 'upcoming'),
                selected: _tab == _TodoTab.upcoming,
                onTap: () => setState(() => _tab = _TodoTab.upcoming),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          AppEmptyState(
            icon: Icons.check_circle_outline,
            message: AppStrings.t(context, 'emptyTasks'),
            actionLabel: AppStrings.t(context, 'addTask'),
            onAction: _showAddTaskDialog,
          )
        else
          ...tasks.map(
            (task) => _TaskTile(
              task: task,
              showDate: _tab == _TodoTab.upcoming,
              onToggle: () => _toggleTask(task),
            ),
          ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TodoTask task;
  final bool showDate;
  final VoidCallback onToggle;

  const _TaskTile({required this.task, required this.showDate, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                      color: task.completed ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  if (task.time != null || showDate)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _subtitle(),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            if (task.completed)
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (task.time != null) parts.add(task.time!);
    if (showDate) parts.add(DateFormat.MMMd().format(task.dueDate));
    return parts.join(' · ');
  }
}
