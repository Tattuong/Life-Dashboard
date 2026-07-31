import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/countdown_event.dart';
import '../../providers/life_provider.dart';
import '../../providers/shop_provider.dart';
import '../../screens/shop/shop_screen.dart';
import '../../widgets/app_ui.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final _uuid = const Uuid();

  static const _icons = ['cake', 'flight', 'work', 'event', 'celebration', 'favorite'];

  IconData _iconFor(String icon) => switch (icon) {
        'cake' => Icons.cake_outlined,
        'flight' => Icons.flight_outlined,
        'work' => Icons.work_outline_rounded,
        'celebration' => Icons.celebration_outlined,
        'favorite' => Icons.favorite_outline_rounded,
        _ => Icons.event_outlined,
      };

  Future<void> _showAddDialog() async {
    final shop = context.read<ShopProvider>();
    final life = context.read<LifeProvider>();

    if (!shop.canAddCountdown(life.countdowns.length)) {
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
    var targetDate = DateTime.now().add(const Duration(days: 30));
    var selectedIcon = _icons.first;
    var colorIndex = 0;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppStrings.t(context, 'addCountdown')),
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
                  trailing: Text(DateFormat.yMMMd().format(targetDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setDialogState(() => targetDate = picked);
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.t(context, 'category'), style: AppTypography.labelBold(size: 13)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(AppColors.countdownColors.length, (i) {
                    final selected = colorIndex == i;
                    return GestureDetector(
                      onTap: () => setDialogState(() => colorIndex = i),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.countdownColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _icons.map((icon) {
                    final selected = selectedIcon == icon;
                    return ChoiceChip(
                      avatar: Icon(_iconFor(icon), size: 18),
                      label: Text(icon),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      onSelected: (_) => setDialogState(() => selectedIcon = icon),
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

    await life.addCountdown(
      CountdownEvent(
        id: _uuid.v4(),
        title: titleCtrl.text.trim(),
        targetDate: targetDate,
        icon: selectedIcon,
        colorIndex: colorIndex,
      ),
    );

    titleCtrl.dispose();
  }

  Future<void> _confirmDelete(CountdownEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.t(context, 'delete')),
        content: Text(event.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t(context, 'delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<LifeProvider>().deleteCountdown(event.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final countdowns = [...life.countdowns]..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    return AppPageScaffold(
      title: AppStrings.t(context, 'countdown'),
      subtitle: AppStrings.t(context, 'countdownEvents', {'count': '${countdowns.length}'}),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      children: [
        if (countdowns.isEmpty)
          AppEmptyState(
            icon: Icons.timer_outlined,
            message: AppStrings.t(context, 'emptyCountdown'),
            actionLabel: AppStrings.t(context, 'addCountdown'),
            onAction: _showAddDialog,
          )
        else
          ...countdowns.map((event) {
            final bgColor = AppColors.countdownColors[event.colorIndex % AppColors.countdownColors.length];
            final accent = AppColors.categoryPalette[event.colorIndex % AppColors.categoryPalette.length];
            final days = event.daysLeft;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onLongPress: () => _confirmDelete(event),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(_iconFor(event.icon), color: accent, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: AppTypography.labelBold(size: 16)),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().format(event.targetDate),
                              style: TextStyle(fontSize: 12, color: accent.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$days',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.t(context, 'daysLeft'),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
