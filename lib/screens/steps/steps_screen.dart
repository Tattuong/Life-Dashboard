import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/health_log.dart';
import '../../providers/life_provider.dart';
import '../../widgets/app_ui.dart';

class StepsScreen extends StatelessWidget {
  const StepsScreen({super.key});

  Future<void> _showUpdateDialog(BuildContext context) async {
    final life = context.read<LifeProvider>();
    final controller = TextEditingController(text: '${life.todaySteps.steps}');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'logSteps')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppStrings.t(context, 'steps'),
            suffixText: '/ ${life.stepsGoal}',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(
            onPressed: () async {
              final steps = int.tryParse(controller.text.trim()) ?? 0;
              await life.updateSteps(steps.clamp(0, 999999));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(AppStrings.t(context, 'save')),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  String _formatSteps(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final steps = life.todaySteps;
    final week = life.stepsLast7Days();
    final progress = steps.progress;

    return AppPageScaffold(
      title: AppStrings.t(context, 'steps'),
      subtitle: AppStrings.t(context, 'ofGoal', {'goal': _formatSteps(steps.goal)}),
      children: [
        AppGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _StepsRingPainter(progress: progress, color: AppColors.pastelTealDark),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatSteps(steps.steps),
                          style: AppTypography.displayLarge(color: AppColors.pastelTealDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).round()}%',
                          style: AppTypography.labelBold(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.t(context, 'ofGoal', {'goal': _formatSteps(steps.goal)}),
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatTile(icon: Icons.straighten_rounded, label: AppStrings.t(context, 'distance'), value: '${steps.distanceKm.toStringAsFixed(1)} ${AppStrings.t(context, 'km')}')),
            const SizedBox(width: 10),
            Expanded(child: _StatTile(icon: Icons.local_fire_department_outlined, label: AppStrings.t(context, 'calories'), value: '${steps.calories} ${AppStrings.t(context, 'kcal')}')),
            const SizedBox(width: 10),
            Expanded(child: _StatTile(icon: Icons.timer_outlined, label: AppStrings.t(context, 'activeTime'), value: '${steps.activeMinutes} ${AppStrings.t(context, 'min')}')),
          ],
        ),
        AppSectionHeader(AppStrings.t(context, 'weeklyHistory'), icon: Icons.bar_chart_rounded),
        AppGlassCard(
          child: SizedBox(
            height: 200,
            child: _StepsWeekChart(data: week),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _showUpdateDialog(context),
          icon: const Icon(Icons.edit_outlined),
          label: Text(AppStrings.t(context, 'logSteps')),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.pastelTealDark),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.labelBold(size: 13)),
        ],
      ),
    );
  }
}

class _StepsRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _StepsRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const stroke = 14.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _StepsRingPainter old) => old.progress != progress;
}

class _StepsWeekChart extends StatelessWidget {
  final List<StepsLog> data;

  const _StepsWeekChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((s) => s.goal).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
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
              getTitlesWidget: (v, _) {
                final n = v.toInt();
                final label = n >= 1000 ? '${(n / 1000).toStringAsFixed(0)}k' : '$n';
                return Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant));
              },
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
          final log = data[i];
          final reached = log.steps >= log.goal;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: log.steps.toDouble(),
                color: reached ? AppColors.pastelTealDark : AppColors.pastelTealDark.withValues(alpha: 0.55),
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.06),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
