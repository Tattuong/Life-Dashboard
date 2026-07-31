import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/shop_provider.dart';
import 'calendar/calendar_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'stats/stats_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final preset = shop.activeTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? preset.darkBackground : preset.background,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          StatsScreen(),
          CalendarScreen(embedded: true),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, bottom > 0 ? bottom : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: AppStrings.t(context, 'tabHome'),
            active: index == 0,
            icon: Icons.home_rounded,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            label: AppStrings.t(context, 'tabStats'),
            active: index == 1,
            icon: Icons.bar_chart_rounded,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            label: AppStrings.t(context, 'tabCalendar'),
            active: index == 2,
            icon: Icons.calendar_month_rounded,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            label: AppStrings.t(context, 'tabProfile'),
            active: index == 3,
            icon: Icons.person_rounded,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primaryBlue;
    const inactiveColor = AppColors.textMuted;
    final color = active ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
