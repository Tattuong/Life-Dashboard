import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/goal.dart';
import '../../providers/life_provider.dart';
import '../../providers/shop_provider.dart';
import '../../screens/shop/shop_screen.dart';
import '../../widgets/app_ui.dart';

enum _GoalTab { active, achieved }

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  _GoalTab _tab = _GoalTab.active;
  final _uuid = const Uuid();

  IconData _iconFor(String icon) => switch (icon) {
        'scale' => Icons.monitor_weight_outlined,
        'savings' => Icons.savings_outlined,
        'book' => Icons.menu_book_outlined,
        'run' => Icons.directions_run_rounded,
        _ => Icons.flag_rounded,
      };

  Future<void> _showAddGoalDialog() async {
    final shop = context.read<ShopProvider>();
    final life = context.read<LifeProvider>();

    if (!shop.canAddGoal(life.goals.length)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t(context, 'limitReached')),
          action: SnackBarAction(
            label: AppStrings.t(context, 'myShop'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
          ),
        ),
      );
      return;
    }

    final titleCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'units');
    final targetCtrl = TextEditingController(text: '100');
    final currentCtrl = TextEditingController(text: '0');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.t(context, 'addGoal')),
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
              TextField(
                controller: unitCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.t(context, 'target'),
                  hintText: 'kg, \$, books...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: currentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: AppStrings.t(context, 'current'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: targetCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: AppStrings.t(context, 'target'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
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
    );

    if (saved != true || !mounted) return;

    await life.addGoal(
      Goal(
        id: _uuid.v4(),
        title: titleCtrl.text.trim(),
        unit: unitCtrl.text.trim().isEmpty ? 'units' : unitCtrl.text.trim(),
        current: double.tryParse(currentCtrl.text) ?? 0,
        target: double.tryParse(targetCtrl.text) ?? 100,
        createdAt: DateTime.now(),
      ),
    );

    titleCtrl.dispose();
    unitCtrl.dispose();
    targetCtrl.dispose();
    currentCtrl.dispose();
  }

  Future<void> _showProgressDialog(Goal goal) async {
    if (goal.achieved) return;

    final currentCtrl = TextEditingController(text: goal.current.toString());

    var sliderValue = goal.progress.clamp(0.0, 1.0);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(goal.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.t(context, 'progress'),
                style: AppTypography.labelBold(size: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: currentCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null && goal.target > 0) {
                    setDialogState(() => sliderValue = (parsed / goal.target).clamp(0.0, 1.0));
                  }
                },
                decoration: InputDecoration(
                  labelText: AppStrings.t(context, 'current'),
                  suffixText: '/ ${goal.target} ${goal.unit}',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: sliderValue,
                onChanged: (v) {
                  final val = (v * goal.target * 100).round() / 100;
                  currentCtrl.text = val.toString();
                  setDialogState(() => sliderValue = v);
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppStrings.t(context, 'save')),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;

    final newCurrent = double.tryParse(currentCtrl.text) ?? goal.current;
    final wasAchieved = goal.achieved;
    await context.read<LifeProvider>().updateGoalProgress(goal.id, newCurrent);

    if (!wasAchieved && newCurrent >= goal.target && mounted) {
      await context.read<ShopProvider>().rewardForGoalMilestone();
    }

    currentCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final goals = _tab == _GoalTab.active ? life.activeGoals : life.achievedGoals;

    return AppPageScaffold(
      title: AppStrings.t(context, 'goals'),
      subtitle: AppStrings.t(context, 'activeGoals', {'count': '${life.activeGoalCount}'}),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AppFilterChip(
                label: AppStrings.t(context, 'active'),
                selected: _tab == _GoalTab.active,
                onTap: () => setState(() => _tab = _GoalTab.active),
              ),
              AppFilterChip(
                label: AppStrings.t(context, 'achieved'),
                selected: _tab == _GoalTab.achieved,
                onTap: () => setState(() => _tab = _GoalTab.achieved),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (goals.isEmpty)
          AppEmptyState(
            icon: Icons.flag_outlined,
            message: AppStrings.t(context, 'emptyGoals'),
            actionLabel: AppStrings.t(context, 'addGoal'),
            onAction: _showAddGoalDialog,
          )
        else
          ...goals.map(
            (goal) => _GoalCard(
              goal: goal,
              icon: _iconFor(goal.icon),
              onTap: () => _showProgressDialog(goal),
            ),
          ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final IconData icon;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progressColor = goal.achieved ? AppColors.success : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppGlassCard(
        onTap: goal.achieved ? null : onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: progressColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: AppTypography.labelBold(size: 16)),
                      Text(
                        '${goal.current} / ${goal.target} ${goal.unit}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (goal.achieved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppStrings.t(context, 'achieved'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  )
                else
                  Text(
                    '${goal.progressPercent}%',
                    style: AppTypography.labelBold(size: 14, color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 10,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            if (!goal.achieved) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.t(context, 'progress'),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
