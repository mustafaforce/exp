import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/category_defaults.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../data/repositories/budget_repository.dart';

class BudgetDetailScreen extends StatelessWidget {
  final BudgetWithSpending data;

  const BudgetDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = data.category;
    final remaining = data.budget.amount - data.spent;
    final dailyAvg = DateTime.now().day > 0
        ? data.spent / DateTime.now().day
        : 0.0;
    final daysLeft = _daysLeftInMonth();
    final projectedEnd = dailyAvg * (DateTime.now().day + daysLeft);

    Color categoryColor;
    if (category != null) {
      categoryColor = CategoryDefaults.hexToColor(category.color);
    } else {
      categoryColor = theme.colorScheme.primary;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name ?? 'Overall Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero category icon
            Center(
              child: Column(
                children: [
                  if (category != null)
                    CategoryIcon(
                      iconName: category.icon,
                      color: categoryColor,
                      size: 72,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    CurrencyFormatter.format(data.spent),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'of ${CurrencyFormatter.format(data.budget.amount)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 20,
                color: theme.colorScheme.surfaceContainerHighest,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      (data.percentage.clamp(0, 100) / 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: data.percentage >= 90
                          ? theme.colorScheme.error
                          : data.percentage >= 70
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.percentage.toStringAsFixed(0)}% spent',
              style: theme.textTheme.labelLarge?.copyWith(
                color: data.percentage >= 90
                    ? theme.colorScheme.error
                    : data.percentage >= 70
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),

            // Stats grid
            Row(
              children: [
                _StatCard(
                  icon: Icons.trending_down,
                  label: 'Daily Avg',
                  value: CurrencyFormatter.format(dailyAvg),
                  color: theme.colorScheme.primary,
                  flex: 1,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.calendar_view_month,
                  label: 'Days Left',
                  value: '$daysLeft',
                  color: theme.colorScheme.secondary,
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.account_balance_wallet,
                  label: 'Remaining',
                  value: CurrencyFormatter.format(
                      remaining > 0 ? remaining : 0),
                  color: remaining >= 0
                      ? const Color(0xFF10B981)
                      : theme.colorScheme.error,
                  flex: 1,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.trending_up,
                  label: 'Projected',
                  value: CurrencyFormatter.format(projectedEnd),
                  color: projectedEnd > data.budget.amount
                      ? theme.colorScheme.error
                      : const Color(0xFF10B981),
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transactions list
            Text('Transactions',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (data.recentTransactions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No transactions this month',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              ...data.recentTransactions.map((t) => ListTile(
                    title: Text(t['note'] ?? 'Expense'),
                    trailing: Text(
                      '-${CurrencyFormatter.format(((t['amount'] as num).toDouble()))}',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  )),
              ],
        ),
      ),
    );
  }

  int _daysLeftInMonth() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int flex;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFeatures: const [
                    FontFeature.tabularFigures()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
