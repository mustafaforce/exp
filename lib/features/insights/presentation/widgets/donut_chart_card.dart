import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/category_defaults.dart';
import '../../providers/insights_provider.dart';

class DonutChartCard extends StatelessWidget {
  final List<CategoryBreakdown> data;
  final double totalExpenses;

  const DonutChartCard({
    super.key,
    required this.data,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('No spending data yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: _sections(context),
                      centerSpaceRadius: 36,
                      sectionsSpace: 1.5,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.format(totalExpenses),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...data.take(5).map((item) {
                        final color = CategoryDefaults.hexToColor(item.color);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.categoryName,
                                  style: theme.textTheme.labelSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${item.percentage.toStringAsFixed(0)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _sections(BuildContext context) {
    return data.map((item) {
      final color = CategoryDefaults.hexToColor(item.color);
      return PieChartSectionData(
        color: color,
        value: item.percentage,
        title: '',
        radius: 20,
      );
    }).toList();
  }
}
