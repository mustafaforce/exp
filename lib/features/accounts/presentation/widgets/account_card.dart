import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_balance.dart';
import '../../data/models/account_model.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AccountIcon(type: account.type),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      account.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _typeLabel(account.type),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedBalance(
                balance: account.balance,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'cash': return 'Cash';
      case 'bank': return 'Bank';
      case 'credit_card': return 'Credit';
      case 'savings': return 'Savings';
      case 'investment': return 'Investment';
      default: return type;
    }
  }
}

class _AccountIcon extends StatelessWidget {
  final String type;
  const _AccountIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    switch (type) {
      case 'cash': icon = Icons.money; break;
      case 'bank': icon = Icons.account_balance; break;
      case 'credit_card': icon = Icons.credit_card; break;
      case 'savings': icon = Icons.savings; break;
      case 'investment': icon = Icons.trending_up; break;
      default: icon = Icons.account_balance_wallet;
    }

    return CircleAvatar(
      radius: 14,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(icon, size: 14, color: theme.colorScheme.primary),
    );
  }
}
