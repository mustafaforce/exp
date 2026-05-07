import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_balance.dart';

class CashFlowCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double netCashFlow;

  const CashFlowCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netCashFlow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cash Flow', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FlowItem(
                    label: 'Income',
                    amount: totalIncome,
                    color: const Color(0xFF10B981),
                    icon: Icons.south_west,
                  ),
                ),
                Container(width: 0.5, height: 32, color: theme.colorScheme.outline),
                Expanded(
                  child: _FlowItem(
                    label: 'Expenses',
                    amount: totalExpenses,
                    color: theme.colorScheme.error,
                    icon: Icons.north_east,
                  ),
                ),
              ],
            ),
            Divider(height: 16, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net', style: theme.textTheme.titleMedium),
                AnimatedBalance(
                  balance: netCashFlow,
                  showSign: true,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: netCashFlow >= 0
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _FlowItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
        AnimatedBalance(
          balance: amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
