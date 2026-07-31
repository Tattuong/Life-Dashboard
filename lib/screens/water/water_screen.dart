import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/health_log.dart';
import '../../providers/life_provider.dart';
import '../../widgets/app_ui.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final water = life.todayWater;
    final week = life.waterLast7Days();
    final progress = water.goal > 0 ? (water.glasses / water.goal).clamp(0.0, 1.0) : 0.0;

    return AppPageScaffold(
      title: AppStrings.t(context, 'water'),
      subtitle: AppStrings.t(context, 'glassesCount', {
        'current': '${water.glasses}',
        'goal': '${water.goal}',
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => life.addWaterGlass(),
        icon: const Icon(Icons.add_rounded),
        label: Text(AppStrings.t(context, 'addWater')),
      ),
      children: [
        AppGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                width: 120,
                child: CustomPaint(
                  painter: _WaterGlassPainter(
                    fillLevel: progress,
                    waterColor: const Color(0xFF06B6D4),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: AppTypography.labelBold(size: 18, color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${water.glasses}/${water.goal} ${AppStrings.t(context, 'glasses')}',
                style: AppTypography.titleLarge(color: const Color(0xFF06B6D4)),
              ),
              const SizedBox(height: 16),
              _DropProgressRow(current: water.glasses, goal: water.goal),
            ],
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'weeklyHistory'), icon: Icons.bar_chart_rounded),
        AppGlassCard(
          child: SizedBox(
            height: 200,
            child: _WaterWeekChart(data: week),
          ),
        ),
      ],
    );
  }
}

class _DropProgressRow extends StatelessWidget {
  final int current;
  final int goal;

  const _DropProgressRow({required this.current, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(goal, (i) {
        final filled = i < current;
        return Icon(
          Icons.water_drop,
          size: 28,
          color: filled ? const Color(0xFF06B6D4) : AppColors.onSurfaceVariant.withValues(alpha: 0.25),
        );
      }),
    );
  }
}

class _WaterWeekChart extends StatelessWidget {
  final List<WaterLog> data;

  const _WaterWeekChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text(AppStrings.t(context, 'noData'), style: const TextStyle(color: AppColors.onSurfaceVariant)));
    }

    final maxY = data.map((w) => w.goal).reduce((a, b) => a > b ? a : b).toDouble();
    final bars = <BarChartGroupData>[];

    for (var i = 0; i < data.length; i++) {
      final log = data[i];
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: log.glasses.toDouble(),
              color: const Color(0xFF06B6D4),
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      );
    }

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
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
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
                  child: Text(
                    DateFormat('E').format(data[i].date),
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: bars,
      ),
    );
  }
}

class _WaterGlassPainter extends CustomPainter {
  final double fillLevel;
  final Color waterColor;

  _WaterGlassPainter({required this.fillLevel, required this.waterColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glassPath = Path()
      ..moveTo(w * 0.25, h * 0.05)
      ..lineTo(w * 0.75, h * 0.05)
      ..lineTo(w * 0.65, h * 0.92)
      ..quadraticBezierTo(w * 0.5, h * 0.98, w * 0.35, h * 0.92)
      ..close();

    canvas.drawPath(
      glassPath,
      Paint()
        ..color = AppColors.onSurfaceVariant.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      glassPath,
      Paint()
        ..color = AppColors.onSurfaceVariant.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    if (fillLevel <= 0) return;

    canvas.save();
    canvas.clipPath(glassPath);

    final fillTop = h * (0.92 - fillLevel * 0.82);
    final waterRect = Rect.fromLTWH(0, fillTop, w, h);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [waterColor.withValues(alpha: 0.65), waterColor],
        ).createShader(waterRect),
    );

    canvas.drawLine(
      Offset(w * 0.3, fillTop + 8),
      Offset(w * 0.55, fillTop + 4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaterGlassPainter old) => old.fillLevel != fillLevel;
}
