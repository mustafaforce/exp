import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../providers/insights_provider.dart';

class TrendLineChart extends StatelessWidget {
  final List<MonthlyTrend> data;

  const TrendLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.every((d) => d.amount == 0)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('No trend data yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ),
        ),
      );
    }

    final maxAmount =
        data.fold<double>(0, (max, d) => d.amount > max ? d.amount : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Trend', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxAmount * 1.2,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            CurrencyFormatter.format(spot.y),
                            TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              data[idx].month,
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.amount);
                      }).toList(),
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: theme.colorScheme.primary,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 2.5,
                            color: theme.colorScheme.primary,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
