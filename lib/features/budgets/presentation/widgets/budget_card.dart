import 'package:flutter/material.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/category_defaults.dart';
import '../../data/repositories/budget_repository.dart';
import 'budget_progress_bar.dart';

class BudgetCard extends StatelessWidget {
  final BudgetWithSpending data;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.data,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = data.category;

    Color categoryColor;
    if (category != null) {
      categoryColor = CategoryDefaults.hexToColor(category.color);
    } else {
      categoryColor = theme.colorScheme.primary;
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (category != null)
                    CategoryIcon(
                      iconName: category.icon,
                      color: categoryColor,
                      size: 28,
                    )
                  else
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.account_balance_wallet,
                          color: theme.colorScheme.primary, size: 14),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category?.name ?? 'Overall',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${data.percentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _colorForPercentage(data.percentage),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.close, size: 14,
                        color: theme.colorScheme.outline),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              BudgetProgressBar(percentage: data.percentage, height: 6),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(data.spent),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'of ${CurrencyFormatter.format(data.budget.amount)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForPercentage(double pct) {
    if (pct >= 90) return const Color(0xFFEF4444);
    if (pct >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }
}
