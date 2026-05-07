import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_balance.dart';
import '../../../accounts/data/models/account_model.dart';

class AccountSelector extends StatelessWidget {
  final AccountModel? selectedAccount;
  final List<AccountModel> accounts;
  final ValueChanged<AccountModel> onSelected;
  final String label;

  const AccountSelector({
    super.key,
    required this.selectedAccount,
    required this.accounts,
    required this.onSelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              final isSelected = account.id == selectedAccount?.id;
              return GestureDetector(
                onTap: () => onSelected(account),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name,
                          style: theme.textTheme.titleMedium),
                      const Spacer(),
                      AnimatedBalance(
                        balance: account.balance,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
