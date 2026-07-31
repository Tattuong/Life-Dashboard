import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/health_log.dart';
import '../../providers/life_provider.dart';
import '../../widgets/app_ui.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  static const _moodKeys = ['veryBad', 'bad', 'neutral', 'good', 'great'];

  List<MoodLog?> _weekMoods(LifeProvider life) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) => life.moodForDate(today.subtract(Duration(days: 6 - i))));
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final today = life.todayMood;
    final week = _weekMoods(life);

    return AppPageScaffold(
      title: AppStrings.t(context, 'mood'),
      subtitle: AppStrings.t(context, 'howAreYou'),
      children: [
        AppGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            children: [
              Text(
                today?.emoji ?? '😐',
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 8),
              Text(
                today?.label ?? AppStrings.t(context, 'neutral'),
                style: AppTypography.titleLarge(color: AppColors.coin),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.t(context, 'howAreYou'),
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: List.generate(5, (i) {
              final selected = today?.mood == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 3, right: i == 4 ? 0 : 3),
                  child: GestureDetector(
                    onTap: () => life.logMood(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.coin.withValues(alpha: 0.18) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.coin : AppColors.onSurfaceVariant.withValues(alpha: 0.15),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(MoodLog.moodEmojis[i], style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.t(context, _moodKeys[i]),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? AppColors.coin : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'weeklyHistory'), icon: Icons.show_chart_rounded),
        AppGlassCard(
          child: SizedBox(
            height: 200,
            child: _MoodWeekChart(data: week),
          ),
        ),
      ],
    );
  }
}

class _MoodWeekChart extends StatelessWidget {
  final List<MoodLog?> data;

  const _MoodWeekChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final m = data[i];
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
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (v) => FlLine(color: AppColors.onSurfaceVariant.withValues(alpha: 0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
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
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final date = DateTime.now().subtract(Duration(days: 6 - i));
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.coin,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 5,
                color: AppColors.coin,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.coin.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
