import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/life_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_engagement_cards.dart';
import '../calendar/calendar_screen.dart';
import '../countdown/countdown_screen.dart';
import '../expenses/expenses_screen.dart';
import '../goals/goals_screen.dart';
import '../mood/mood_screen.dart';
import '../shop/shop_screen.dart';
import '../sleep/sleep_screen.dart';
import '../steps/steps_screen.dart';
import '../todo/todo_screen.dart';
import '../water/water_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.t(context, 'goodMorning');
    if (hour < 17) return AppStrings.t(context, 'goodAfternoon');
    return AppStrings.t(context, 'goodEvening');
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          life.userName.isEmpty
                              ? _greeting(context)
                              : '${_greeting(context)}, ${life.userName}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CoinBalanceChip(),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _TodayScoreCard(score: life.todayScore),
            ),
          ),
          const SliverToBoxAdapter(child: CoinUnlockTeaser()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              delegate: SliverChildListDelegate([
                _ModuleCard(
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.primaryBlue,
                  title: AppStrings.t(context, 'calendar'),
                  subtitle: AppStrings.t(context, 'eventsToday', {'count': '${life.todayEventCount}'}),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
                ),
                _ModuleCard(
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  title: AppStrings.t(context, 'todo'),
                  subtitle: AppStrings.t(context, 'tasksCount', {'count': '${life.todayTodoCount}'}),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TodoScreen())),
                ),
                _ModuleCard(
                  icon: Icons.flag_rounded,
                  color: AppColors.pastelOrange,
                  title: AppStrings.t(context, 'goals'),
                  subtitle: AppStrings.t(context, 'activeGoals', {'count': '${life.activeGoalCount}'}),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
                ),
                _ModuleCard(
                  icon: Icons.timer_outlined,
                  color: AppColors.pastelPurple,
                  title: AppStrings.t(context, 'countdown'),
                  subtitle: AppStrings.t(context, 'countdownEvents', {'count': '${life.countdowns.length}'}),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CountdownScreen())),
                ),
                _ModuleCard(
                  icon: Icons.water_drop_outlined,
                  color: const Color(0xFF06B6D4),
                  title: AppStrings.t(context, 'water'),
                  subtitle: AppStrings.t(context, 'glassesCount', {
                    'current': '${life.todayWater.glasses}',
                    'goal': '${life.todayWater.goal}',
                  }),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterScreen())),
                ),
                _ModuleCard(
                  icon: Icons.bedtime_outlined,
                  color: const Color(0xFF6366F1),
                  title: AppStrings.t(context, 'sleep'),
                  subtitle: life.lastNightSleep?.durationText ?? '--',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen())),
                ),
                _ModuleCard(
                  icon: Icons.directions_walk_rounded,
                  color: AppColors.pastelTealDark,
                  title: AppStrings.t(context, 'steps'),
                  subtitle: AppStrings.t(context, 'stepsCount', {'count': _formatNumber(life.todaySteps.steps)}),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StepsScreen())),
                ),
                _ModuleCard(
                  icon: Icons.emoji_emotions_outlined,
                  color: AppColors.coin,
                  title: AppStrings.t(context, 'mood'),
                  subtitle: life.todayMood?.label ?? AppStrings.t(context, 'moodHappy'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen())),
                ),
                _ModuleCard(
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.error,
                  title: AppStrings.t(context, 'expenses'),
                  subtitle: '\$${life.totalExpensesForMonth(DateTime.now().year, DateTime.now().month).toStringAsFixed(0)}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen())),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _TodayScoreCard extends StatelessWidget {
  final int score;

  const _TodayScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t(context, 'todayScore'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '$score%',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();
    final skin = shop.activeCardStyle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(skin.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(skin.borderRadius),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
