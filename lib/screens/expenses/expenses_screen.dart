import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/expense.dart';
import '../../providers/life_provider.dart';
import '../../widgets/app_ui.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late DateTime _focusedMonth;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  Future<void> _showAddExpenseDialog() async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var category = ExpenseCategory.defaults.first.name;
    var expenseDate = DateTime.now();
    var colorIndex = 0;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppStrings.t(context, 'addExpense')),
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
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: AppStrings.t(context, 'amount'),
                    prefixText: '\$ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t(context, 'date')),
                  trailing: Text(DateFormat.yMMMd().format(expenseDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: expenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => expenseDate = picked);
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
                  runSpacing: 8,
                  children: ExpenseCategory.defaults.map((cat) {
                    final selected = category == cat.name;
                    final color = AppColors.categoryPalette[cat.colorIndex % AppColors.categoryPalette.length];
                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: selected,
                      selectedColor: color.withValues(alpha: 0.15),
                      avatar: CircleAvatar(radius: 6, backgroundColor: color),
                      onSelected: (_) => setDialogState(() {
                        category = cat.name;
                        colorIndex = cat.colorIndex;
                      }),
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
                if (titleCtrl.text.trim().isEmpty || double.tryParse(amountCtrl.text) == null) return;
                Navigator.pop(ctx, true);
              },
              child: Text(AppStrings.t(context, 'save')),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;

    await context.read<LifeProvider>().addExpense(
          Expense(
            id: _uuid.v4(),
            title: titleCtrl.text.trim(),
            amount: double.parse(amountCtrl.text),
            category: category,
            date: expenseDate,
            colorIndex: colorIndex,
          ),
        );

    titleCtrl.dispose();
    amountCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final life = context.watch<LifeProvider>();
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final monthExpenses = life.expensesForMonth(year, month);
    final total = life.totalExpensesForMonth(year, month);
    final categoryTotals = life.categoryTotalsForMonth(year, month);
    final monthLabel = DateFormat.yMMMM().format(_focusedMonth);

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recent = [...monthExpenses]..sort((a, b) => b.date.compareTo(a.date));

    return AppPageScaffold(
      title: AppStrings.t(context, 'expenses'),
      subtitle: monthLabel,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
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
                child: Text(monthLabel, textAlign: TextAlign.center, style: AppTypography.labelBold(size: 16)),
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
        AppGlassCard(
          child: Column(
            children: [
              Text(
                AppStrings.t(context, 'totalExpenses'),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppTypography.displayLarge(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (sortedCategories.isEmpty)
          AppEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            message: AppStrings.t(context, 'emptyExpenses'),
            actionLabel: AppStrings.t(context, 'addExpense'),
            onAction: _showAddExpenseDialog,
          )
        else ...[
          AppGlassCard(
            child: SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 44,
                        sections: _buildPieSections(sortedCategories, total),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sortedCategories.map((entry) {
                        final color = _colorForCategory(entry.key, sortedCategories);
                        final pct = total > 0 ? (entry.value / total * 100).round() : 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('$pct%', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppSectionHeader(AppStrings.t(context, 'recentTransactions'), icon: Icons.receipt_long_outlined),
          ...recent.take(20).map((expense) => _ExpenseTile(expense: expense)),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(List<MapEntry<String, double>> categories, double total) {
    if (total <= 0) return [];

    return categories.map((entry) {
      final color = _colorForCategory(entry.key, categories);
      final pct = entry.value / total * 100;
      return PieChartSectionData(
        value: entry.value,
        title: pct >= 8 ? '${pct.round()}%' : '',
        color: color,
        radius: 52,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
      );
    }).toList();
  }

  Color _colorForCategory(String category, List<MapEntry<String, double>> categories) {
    final match = ExpenseCategory.defaults.where((c) => c.name == category).firstOrNull;
    if (match != null) {
      return AppColors.categoryPalette[match.colorIndex % AppColors.categoryPalette.length];
    }
    final index = categories.indexWhere((e) => e.key == category);
    return AppColors.categoryPalette[index % AppColors.categoryPalette.length];
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;

  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryPalette[expense.colorIndex % AppColors.categoryPalette.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: AppTypography.labelBold(size: 14)),
                  Text(
                    '${expense.category} · ${DateFormat.MMMd().format(expense.date)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '-\$${expense.amount.toStringAsFixed(2)}',
              style: AppTypography.labelBold(size: 14, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
