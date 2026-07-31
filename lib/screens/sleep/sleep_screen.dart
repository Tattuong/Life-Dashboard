import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/health_log.dart';
import '../../providers/life_provider.dart';
import '../../widgets/app_ui.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  Future<void> _showLogDialog(BuildContext context) async {
    final life = context.read<LifeProvider>();
    final sleep = life.lastNightSleep;

    var hours = (sleep?.minutes ?? 420) ~/ 60;
    var mins = (sleep?.minutes ?? 420) % 60;
    var quality = sleep?.quality ?? 'Good';
    var sleepTime = sleep?.sleepTime ?? '23:00';
    var wakeTime = sleep?.wakeTime ?? '07:00';

    final qualities = ['Excellent', 'Good', 'Fair', 'Poor'];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(AppStrings.t(context, 'logSleep')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: hours.clamp(0, 14),
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'hours')),
                        items: List.generate(15, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                        onChanged: (v) => setState(() => hours = v ?? hours),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: mins.clamp(0, 59),
                        decoration: InputDecoration(labelText: AppStrings.t(context, 'min')),
                        items: List.generate(12, (i) => DropdownMenuItem(value: i * 5, child: Text('${i * 5}'))),
                        onChanged: (v) => setState(() => mins = v ?? mins),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: qualities.contains(quality) ? quality : 'Good',
                  decoration: InputDecoration(labelText: AppStrings.t(context, 'sleepQuality')),
                  items: qualities
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text(_qualityLabel(context, q)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => quality = v ?? quality),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t(context, 'sleepTime')),
                  subtitle: Text(sleepTime),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final parts = sleepTime.split(':');
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                    );
                    if (picked != null) {
                      setState(() {
                        sleepTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t(context, 'wakeTime')),
                  subtitle: Text(wakeTime),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final parts = wakeTime.split(':');
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                    );
                    if (picked != null) {
                      setState(() {
                        wakeTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.t(context, 'cancel'))),
            FilledButton(
              onPressed: () async {
                final totalMinutes = hours * 60 + mins;
                final deep = (totalMinutes * 0.2).round();
                final light = (totalMinutes * 0.45).round();
                final rem = (totalMinutes * 0.28).round();
                final awake = (totalMinutes * 0.07).round();
                final now = DateTime.now();
                final date = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));

                await life.logSleep(SleepLog(
                  id: const Uuid().v4(),
                  date: date,
                  minutes: totalMinutes,
                  quality: quality,
                  deepMinutes: deep,
                  lightMinutes: light,
                  remMinutes: rem,
                  awakeMinutes: awake,
                  sleepTime: sleepTime,
                  wakeTime: wakeTime,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(AppStrings.t(context, 'save')),
            ),
          ],
        ),
      ),
    );
  }

  String _qualityLabel(BuildContext context, String quality) {
    return switch (quality.toLowerCase()) {
      'excellent' => AppStrings.t(context, 'excellent'),
      'good' => AppStrings.t(context, 'good'),
      'fair' => 'Fair',
      'poor' => AppStrings.t(context, 'bad'),
      _ => quality,
    };
  }

  Color _qualityColor(String quality) {
    return switch (quality.toLowerCase()) {
      'excellent' => AppColors.success,
      'good' => AppColors.primaryBlue,
      'fair' => AppColors.warning,
      _ => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final sleep = life.lastNightSleep;
    final week = life.sleepLast7Days();

    return AppPageScaffold(
      title: AppStrings.t(context, 'sleep'),
      subtitle: AppStrings.t(context, 'lastNight'),
      children: [
        AppGlassCard(
          child: sleep == null || sleep.minutes == 0
              ? AppEmptyState(
                  icon: Icons.bedtime_outlined,
                  message: AppStrings.t(context, 'noData'),
                  actionLabel: AppStrings.t(context, 'logSleep'),
                  onAction: () => _showLogDialog(context),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.t(context, 'lastNight'), style: AppTypography.labelBold(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 6),
                              Text(sleep.durationText, style: AppTypography.displayLarge(color: const Color(0xFF6366F1))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _qualityColor(sleep.quality).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            sleep.quality,
                            style: AppTypography.labelBold(color: _qualityColor(sleep.quality), size: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _InfoChip(icon: Icons.star_rounded, label: AppStrings.t(context, 'sleepQuality'), value: '${sleep.qualityScore}'),
                        const SizedBox(width: 12),
                        _InfoChip(icon: Icons.nightlight_round, label: AppStrings.t(context, 'sleepTime'), value: sleep.sleepTime),
                        const SizedBox(width: 12),
                        _InfoChip(icon: Icons.wb_sunny_outlined, label: AppStrings.t(context, 'wakeTime'), value: sleep.wakeTime),
                      ],
                    ),
                  ],
                ),
        ),
        if (sleep != null && sleep.minutes > 0) ...[
          AppSectionHeader(AppStrings.t(context, 'progress'), icon: Icons.stacked_bar_chart_rounded),
          AppGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StageLegend(sleep: sleep),
                const SizedBox(height: 16),
                SizedBox(height: 48, child: _SleepStagesChart(sleep: sleep)),
              ],
            ),
          ),
        ],
        AppSectionHeader(AppStrings.t(context, 'weeklyHistory'), icon: Icons.bar_chart_rounded),
        AppGlassCard(
          child: SizedBox(
            height: 200,
            child: _SleepWeekChart(data: week),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _showLogDialog(context),
          icon: const Icon(Icons.bedtime_outlined),
          label: Text(AppStrings.t(context, 'logSleep')),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6366F1)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            Text(value, style: AppTypography.labelBold(size: 13)),
          ],
        ),
      ),
    );
  }
}

class _StageLegend extends StatelessWidget {
  final SleepLog sleep;

  const _StageLegend({required this.sleep});

  @override
  Widget build(BuildContext context) {
    final stages = [
      (AppStrings.t(context, 'deepSleep'), sleep.deepMinutes, const Color(0xFF4338CA)),
      (AppStrings.t(context, 'lightSleep'), sleep.lightMinutes, const Color(0xFF818CF8)),
      (AppStrings.t(context, 'remSleep'), sleep.remMinutes, const Color(0xFFA78BFA)),
      (AppStrings.t(context, 'awake'), sleep.awakeMinutes, AppColors.warning),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: stages
          .map((s) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: s.$3, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 4),
                  Text('${s.$1} ${s.$2}${AppStrings.t(context, 'min')}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ))
          .toList(),
    );
  }
}

class _SleepStagesChart extends StatelessWidget {
  final SleepLog sleep;

  const _SleepStagesChart({required this.sleep});

  @override
  Widget build(BuildContext context) {
    final total = (sleep.deepMinutes + sleep.lightMinutes + sleep.remMinutes + sleep.awakeMinutes).toDouble();
    if (total <= 0) return const SizedBox.shrink();

    final segments = [
      (sleep.deepMinutes / total, const Color(0xFF4338CA)),
      (sleep.lightMinutes / total, const Color(0xFF818CF8)),
      (sleep.remMinutes / total, const Color(0xFFA78BFA)),
      (sleep.awakeMinutes / total, AppColors.warning),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: segments
            .where((s) => s.$1 > 0)
            .map((s) => Expanded(
                  flex: (s.$1 * 1000).round().clamp(1, 1000),
                  child: Container(color: s.$2),
                ))
            .toList(),
      ),
    );
  }
}

class _SleepWeekChart extends StatelessWidget {
  final List<SleepLog> data;

  const _SleepWeekChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((s) => s.minutes).reduce((a, b) => a > b ? a : b).toDouble();
    final chartMax = maxY > 0 ? maxY : 480.0;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (v) => FlLine(color: AppColors.onSurfaceVariant.withValues(alpha: 0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text('${(v / 60).toStringAsFixed(0)}h', style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('E').format(data[i].date), style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].minutes.toDouble(),
                color: const Color(0xFF6366F1),
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}
