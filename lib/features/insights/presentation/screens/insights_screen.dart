import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../providers/insights_provider.dart';
import '../widgets/net_worth_card.dart';
import '../widgets/cash_flow_card.dart';
import '../widgets/donut_chart_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/trend_line_chart.dart';
import '../widgets/top_categories_list.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: insightsAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          if (data.totalExpenses == 0 && data.totalIncome == 0) {
            return EmptyState(
              icon: Icons.pie_chart_outline,
              headline: 'Not enough data yet',
              description: 'Add a few transactions to unlock insights.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 20),
            child: Column(
              children: [
                NetWorthCard(netWorth: data.netWorth),
                const SizedBox(height: 8),
                CashFlowCard(
                  totalIncome: data.totalIncome,
                  totalExpenses: data.totalExpenses,
                  netCashFlow: data.netCashFlow,
                ),
                const SizedBox(height: 8),
                DonutChartCard(
                  data: data.categoryBreakdown,
                  totalExpenses: data.totalExpenses,
                ),
                const SizedBox(height: 8),
                WeeklyBarChart(data: data.weeklySpending),
                const SizedBox(height: 8),
                TrendLineChart(data: data.monthlyTrend),
                const SizedBox(height: 8),
                TopCategoriesList(
                  data: data.topCategories,
                  totalExpenses: data.totalExpenses,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
