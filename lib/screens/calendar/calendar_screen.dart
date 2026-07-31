import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/calendar_event.dart';
import '../../providers/life_provider.dart';
import '../../widgets/app_ui.dart';

class CalendarScreen extends StatefulWidget {
  final bool embedded;

  const CalendarScreen({super.key, this.embedded = false});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  final _uuid = const Uuid();

  static const _categories = ['Work', 'Health', 'Personal', 'General'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _weekStart(DateTime date) {
    final d = _dateOnly(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  Future<void> _showAddEventDialog() async {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    var category = _categories.first;
    var startTime = TimeOfDay.fromDateTime(
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 9, 0),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppStrings.t(context, 'addEvent')),
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
                  title: Text(AppStrings.t(context, 'time')),
                  trailing: Text(startTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: startTime);
                    if (picked != null) setDialogState(() => startTime = picked);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.t(context, 'location'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.t(context, 'category'), style: AppTypography.labelBold(size: 13)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final selected = category == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      onSelected: (_) => setDialogState(() => category = cat),
                    );
                  }).toList(),
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

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      startTime.hour,
      startTime.minute,
    );
    final colorIndex = _categories.indexOf(category).clamp(0, AppColors.categoryPalette.length - 1);

    await context.read<LifeProvider>().addEvent(
          CalendarEvent(
            id: _uuid.v4(),
            title: titleCtrl.text.trim(),
            startTime: start,
            endTime: start.add(const Duration(hours: 1)),
            location: locationCtrl.text.trim(),
            category: category,
            colorIndex: colorIndex,
          ),
        );

    titleCtrl.dispose();
    locationCtrl.dispose();
  }

  Widget _buildFab() => FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      );

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final events = life.eventsForDate(_selectedDate);
    final weekStart = _weekStart(_selectedDate);
    final monthLabel = DateFormat.yMMMM().format(_focusedMonth);

    final page = AppPageScaffold(
      embedded: widget.embedded,
      title: AppStrings.t(context, 'calendar'),
      subtitle: AppStrings.t(context, 'eventsToday', {'count': '${life.todayEventCount}'}),
      floatingActionButton: widget.embedded ? null : _buildFab(),
      children: [
        AppGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelBold(size: 16),
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (_, i) {
              final day = weekStart.add(Duration(days: i));
              final isSelected = _dateOnly(day) == _dateOnly(_selectedDate);
              final isToday = _dateOnly(day) == _dateOnly(DateTime.now());
              final dayEvents = life.eventsForDate(day);

              return Padding(
                padding: EdgeInsets.only(right: i < 6 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedDate = day;
                    _focusedMonth = DateTime(day.year, day.month);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isToday && !isSelected
                            ? AppColors.primary
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(day).substring(0, 3),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        AppSectionHeader(
          DateFormat.yMMMEd().format(_selectedDate),
          icon: Icons.event_note_rounded,
        ),
        if (events.isEmpty)
          AppEmptyState(
            icon: Icons.event_busy_outlined,
            message: AppStrings.t(context, 'emptyEvents'),
            actionLabel: AppStrings.t(context, 'addEvent'),
            onAction: _showAddEventDialog,
          )
        else
          ...events.map((event) => _EventTimelineTile(event: event)),
      ],
    );

    if (widget.embedded) {
      return Stack(
        children: [
          page,
          Positioned(right: 16, bottom: 16, child: _buildFab()),
        ],
      );
    }
    return page;
  }
}

class _EventTimelineTile extends StatelessWidget {
  final CalendarEvent event;

  const _EventTimelineTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryPalette[event.colorIndex % AppColors.categoryPalette.length];
    final timeFmt = DateFormat.jm();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeFmt.format(event.startTime),
                  style: AppTypography.labelBold(size: 12, color: AppColors.textSecondary),
                ),
                Text(
                  timeFmt.format(event.endTime),
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                Container(width: 2, height: 48, color: color.withValues(alpha: 0.25)),
              ],
            ),
          ),
          Expanded(
            child: AppGlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(event.title, style: AppTypography.labelBold(size: 15)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.category,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                    ],
                  ),
                  if (event.location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
