import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/widgets/animated_balance.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../data/models/account_model.dart';
import '../../providers/accounts_provider.dart';
import '../widgets/account_card.dart';
import 'add_edit_account_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _addAccount(context, ref),
        child: const Icon(Icons.add, size: 20),
      ),
      body: accountsAsync.when(
        loading: () => const Center(
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              headline: 'No accounts set up',
              description: 'Add your first account to start tracking balances.',
              ctaLabel: 'Add Account',
              onCta: () => _addAccount(context, ref),
            );
          }

          return Column(
            children: [
              // Total balance compact
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Total', style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                    const Spacer(),
                    AnimatedBalance(
                      balance: totalBalance,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: totalBalance >= 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),

              // Horizontal account cards
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          horizontalOffset: 60,
                          child: FadeInAnimation(
                            child: AccountCard(
                              account: accounts[index],
                              onTap: () => _editAccount(context, ref, accounts[index]),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),

              // Account list
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return Dismissible(
                      key: ValueKey(account.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context, ref, account),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: theme.colorScheme.error,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 18),
                      ),
                      child: InkWell(
                        onTap: () => _editAccount(context, ref, account),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(_accountIcon(account.type),
                                  size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(account.name, style: theme.textTheme.titleMedium),
                                    Text(account.type, style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    )),
                                  ],
                                ),
                              ),
                              AnimatedBalance(
                                balance: account.balance,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'cash': return Icons.money;
      case 'bank': return Icons.account_balance;
      case 'credit_card': return Icons.credit_card;
      case 'savings': return Icons.savings;
      case 'investment': return Icons.trending_up;
      default: return Icons.account_balance_wallet;
    }
  }

  void _addAccount(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditAccountScreen()),
    ).then((result) {
      if (result is AccountModel) {
        ref.read(accountsProvider.notifier).addAccount(result);
      }
    });
  }

  void _editAccount(BuildContext context, WidgetRef ref, AccountModel account) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditAccountScreen(account: account)),
    ).then((result) {
      if (result is AccountModel) {
        ref.read(accountsProvider.notifier).updateAccount(result);
      }
    });
  }

  Future<bool?> _confirmDelete(
      BuildContext context, WidgetRef ref, AccountModel account) async {
    return ConfirmationDialog.show(
      context,
      title: 'Delete Account',
      message: 'Delete "${account.name}"? Transactions linked to it will remain.',
      confirmLabel: 'Delete',
      confirmColor: Theme.of(context).colorScheme.error,
      icon: Icons.delete_outline,
    ).then((confirmed) {
      if (confirmed == true && account.id != null) {
        ref.read(accountsProvider.notifier).deleteAccount(account.id!);
      }
      return false;
    });
  }
}
