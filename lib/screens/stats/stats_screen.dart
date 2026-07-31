import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/health_log.dart';
import '../../providers/life_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_ui.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final shop = context.watch<ShopProvider>();
    final premium = shop.hasPremiumCharts;

    return AppPageScaffold(
      embedded: true,
      title: AppStrings.t(context, 'statsOverview'),
      subtitle: AppStrings.t(context, 'weeklyProgress'),
      children: [
        _OverviewGrid(life: life),
        AppSectionHeader(AppStrings.t(context, 'water'), icon: Icons.water_drop_outlined),
        AppGlassCard(
          child: SizedBox(
            height: premium ? 220 : 180,
            child: _ModuleWeekChart(
              premium: premium,
              color: const Color(0xFF06B6D4),
              values: life.waterLast7Days().map((w) => w.glasses.toDouble()).toList(),
              maxY: life.waterGoal.toDouble(),
              dates: life.waterLast7Days().map((w) => w.date).toList(),
              labelFormat: (v) => '${v.toInt()}',
            ),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'sleep'), icon: Icons.bedtime_outlined),
        AppGlassCard(
          child: SizedBox(
            height: premium ? 220 : 180,
            child: _ModuleWeekChart(
              premium: premium,
              color: const Color(0xFF6366F1),
              values: life.sleepLast7Days().map((s) => s.minutes / 60).toList(),
              maxY: 10,
              dates: life.sleepLast7Days().map((s) => s.date).toList(),
              labelFormat: (v) => '${v.toStringAsFixed(1)}h',
            ),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'steps'), icon: Icons.directions_walk_rounded),
        AppGlassCard(
          child: SizedBox(
            height: premium ? 220 : 180,
            child: _ModuleWeekChart(
              premium: premium,
              color: AppColors.pastelTealDark,
              values: life.stepsLast7Days().map((s) => s.steps.toDouble()).toList(),
              maxY: life.stepsGoal.toDouble(),
              dates: life.stepsLast7Days().map((s) => s.date).toList(),
              labelFormat: (v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '${v.toInt()}',
            ),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'mood'), icon: Icons.emoji_emotions_outlined),
        AppGlassCard(
          child: SizedBox(
            height: premium ? 220 : 180,
            child: _MoodSummaryChart(life: life, premium: premium),
          ),
        ),
        if (!premium)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              AppStrings.t(context, 'shopFeatChartsDesc'),
              style: const TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  final LifeProvider life;

  const _OverviewGrid({required this.life});

  @override
  Widget build(BuildContext context) {
    final water = life.todayWater;
    final steps = life.todaySteps;
    final sleep = life.lastNightSleep;
    final mood = life.todayMood;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        _OverviewCard(
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF06B6D4),
          title: AppStrings.t(context, 'water'),
          value: '${water.glasses}/${water.goal}',
          subtitle: AppStrings.t(context, 'glasses'),
        ),
        _OverviewCard(
          icon: Icons.bedtime_outlined,
          color: const Color(0xFF6366F1),
          title: AppStrings.t(context, 'sleep'),
          value: sleep?.durationText ?? '--',
          subtitle: AppStrings.t(context, 'lastNight'),
        ),
        _OverviewCard(
          icon: Icons.directions_walk_rounded,
          color: AppColors.pastelTealDark,
          title: AppStrings.t(context, 'steps'),
          value: '${(steps.progress * 100).round()}%',
          subtitle: '${steps.steps} / ${steps.goal}',
        ),
        _OverviewCard(
          icon: Icons.emoji_emotions_outlined,
          color: AppColors.coin,
          title: AppStrings.t(context, 'mood'),
          value: mood?.emoji ?? '😐',
          subtitle: mood?.label ?? AppStrings.t(context, 'noData'),
        ),
        _OverviewCard(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
          title: AppStrings.t(context, 'todo'),
          value: '${life.todayTodoCount}',
          subtitle: AppStrings.t(context, 'tasksCount', {'count': '${life.todayTodos.length}'}),
        ),
        _OverviewCard(
          icon: Icons.flag_rounded,
          color: AppColors.pastelOrange,
          title: AppStrings.t(context, 'goals'),
          value: '${life.activeGoalCount}',
          subtitle: AppStrings.t(context, 'active'),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _OverviewCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.labelBold(size: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleWeekChart extends StatelessWidget {
  final bool premium;
  final Color color;
  final List<double> values;
  final double maxY;
  final List<DateTime> dates;
  final String Function(double) labelFormat;

  const _ModuleWeekChart({
    required this.premium,
    required this.color,
    required this.values,
    required this.maxY,
    required this.dates,
    required this.labelFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (premium) {
      final spots = <FlSpot>[];
      for (var i = 0; i < values.length; i++) {
        spots.add(FlSpot(i.toDouble(), values[i]));
      }
      return LineChart(
        LineChartData(
          maxY: maxY > 0 ? maxY : 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.onSurfaceVariant.withValues(alpha: 0.1)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: AppColors.onSurfaceVariant.withValues(alpha: 0.1))),
          titlesData: _titles(context),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.15)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxY > 0 ? maxY : 1,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(context),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              ),
            ],
          );
        }),
      ),
    );
  }

  FlTitlesData _titles(BuildContext context) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: premium,
          reservedSize: premium ? 36 : 0,
          getTitlesWidget: (v, _) => Text(labelFormat(v), style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= dates.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(DateFormat('E').format(dates[i]), style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            );
          },
        ),
      ),
    );
  }
}

class _MoodSummaryChart extends StatelessWidget {
  final LifeProvider life;
  final bool premium;

  const _MoodSummaryChart({required this.life, required this.premium});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final spots = <FlSpot>[];

    for (var i = 0; i < 7; i++) {
      final m = life.moodForDate(today.subtract(Duration(days: 6 - i)));
      if (m != null) spots.add(FlSpot(i.toDouble(), m.mood.toDouble()));
    }

    if (spots.isEmpty) {
      return Center(child: Text(AppStrings.t(context, 'noData'), style: const TextStyle(color: AppColors.onSurfaceVariant)));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 4,
        gridData: FlGridData(
          show: premium,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (v) => FlLine(color: AppColors.onSurfaceVariant.withValues(alpha: 0.1)),
        ),
        borderData: FlBorderData(show: premium),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: premium,
              reservedSize: premium ? 28 : 0,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt().clamp(0, 4);
                return Text(MoodLog.moodEmojis[i], style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i > 6) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('E').format(today.subtract(Duration(days: 6 - i))), style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: premium,
            color: AppColors.coin,
            barWidth: premium ? 3 : 2,
            dotData: FlDotData(show: premium),
            belowBarData: BarAreaData(show: premium, color: AppColors.coin.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}
