import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/constants/category_defaults.dart';
import '../../providers/insights_provider.dart';

class TopCategoriesList extends StatelessWidget {
  final List<CategoryRank> data;
  final double totalExpenses;

  const TopCategoriesList({
    super.key,
    required this.data,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Categories', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ...data.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final color = CategoryDefaults.hexToColor(item.color);
              final fraction = totalExpenses > 0
                  ? (item.amount / totalExpenses).clamp(0.0, 1.0)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      child: Text(
                        '${idx + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    CategoryIcon(iconName: item.icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.categoryName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              )),
                          const SizedBox(height: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: SizedBox(
                              height: 4,
                              child: LinearProgressIndicator(
                                value: fraction,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(item.amount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.percentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
