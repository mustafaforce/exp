import 'package:flutter/material.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/repositories/expense_repository.dart';

class TransactionTile extends StatelessWidget {
  final ExpenseWithDetails expense;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exp = expense.expense;
    final isExpense = exp.isExpense;
    final isTransfer = exp.isTransfer;
    final isIncome = exp.isIncome;

    Color amountColor;
    String prefix;
    if (isTransfer) {
      amountColor = theme.colorScheme.primary;
      prefix = '';
    } else if (isExpense) {
      amountColor = theme.colorScheme.error;
      prefix = '-';
    } else {
      amountColor = const Color(0xFF10B981);
      prefix = '+';
    }

    final categoryColor = expense.categoryColor != null
        ? _parseHex(expense.categoryColor!)
        : theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            expense.categoryIcon != null
                ? CategoryIcon(
                    iconName: expense.categoryIcon!,
                    color: categoryColor,
                    size: 32,
                  )
                : CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      isTransfer ? Icons.swap_horiz : Icons.receipt_long,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isIncome)
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(Icons.south_west, size: 10, color: amountColor),
                        ),
                      Expanded(
                        child: Text(
                          expense.payeeName ?? expense.categoryName ?? 'Unknown',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (exp.note != null && exp.note!.isNotEmpty)
                    Text(
                      exp.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$prefix${CurrencyFormatter.format(exp.amount)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (isTransfer)
                  Text(
                    'Transfer',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
