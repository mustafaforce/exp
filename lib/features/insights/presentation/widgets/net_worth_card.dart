import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_balance.dart';

class NetWorthCard extends StatelessWidget {
  final double netWorth;

  const NetWorthCard({super.key, required this.netWorth});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.account_balance_rounded,
                size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net Worth',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                AnimatedBalance(
                  balance: netWorth,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: netWorth >= 0
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
