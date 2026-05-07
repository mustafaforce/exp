import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/animated_balance.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expenses/presentation/screens/add_edit_expense_screen.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../expenses/providers/expenses_provider.dart';
import '../../../expenses/presentation/widgets/transaction_tile.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../../transfers/presentation/screens/transfer_screen.dart';
import '../../../recurring/providers/recurring_provider.dart';
import '../../../insights/providers/insights_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _processRecurring();
    }
  }

  Future<void> _processRecurring() async {
    final count = await ref
        .read(recurringProvider.notifier)
        .processDueTransactions();
    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count recurring transaction${count > 1 ? 's' : ''} added'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalBalance = ref.watch(totalBalanceProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 22),
            onPressed: () => _addTransaction(context, ref, 'expense'),
            tooltip: 'Add expense',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expensesProvider);
          ref.invalidate(insightsProvider);
          ref.invalidate(accountsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance card
              _BalanceCard(balance: totalBalance),
              const SizedBox(height: 8),

              // Quick actions row
              Row(
                children: [
                  Expanded(
                    child: _CompactAction(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expense',
                      color: theme.colorScheme.error,
                      onTap: () => _addTransaction(context, ref, 'expense'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CompactAction(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Income',
                      color: const Color(0xFF10B981),
                      onTap: () => _addTransaction(context, ref, 'income'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CompactAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Transfer',
                      color: theme.colorScheme.primary,
                      onTap: () => _openTransfer(context, ref),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Monthly summary
              insightsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (data) {
                  if (data.totalExpenses == 0 && data.totalIncome == 0) {
                    return const SizedBox.shrink();
                  }
                  return _MonthlySummary(
                    income: data.totalIncome,
                    expenses: data.totalExpenses,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Recent transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent', style: theme.textTheme.titleLarge),
                  if (expensesAsync.valueOrNull?.isNotEmpty == true)
                    GestureDetector(
                      onTap: () {
                        // Switch to transactions tab
                        final shell = context.findAncestorStateOfType<State>();
                        if (shell != null && shell.mounted) {
                          // Navigate via parent MainShell
                        }
                      },
                      child: Text(
                        'See all',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              expensesAsync.when(
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Error: $e', style: theme.textTheme.bodySmall),
                ),
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Center(
                          child: Text(
                            'No transactions yet — tap + to start',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  final recent = expenses.take(5).toList();
                  return Card(
                    child: Column(
                      children: [
                        for (int i = 0; i < recent.length; i++) ...[
                          TransactionTile(
                            expense: recent[i],
                            onTap: () => _editExpense(context, recent[i]),
                          ),
                          if (i < recent.length - 1)
                            Divider(
                              height: 0.5,
                              indent: 48,
                              color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTransaction(BuildContext context, WidgetRef ref, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(initialType: type),
      ),
    ).then((result) {
      if (result is Map && result['expense'] is ExpenseModel) {
        ref.read(expensesProvider.notifier).addExpense(result['expense'] as ExpenseModel);
      } else if (result is ExpenseModel) {
        ref.read(expensesProvider.notifier).addExpense(result);
      }
    });
  }

  void _editExpense(BuildContext context, dynamic expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(expense: expense.expense),
      ),
    ).then((result) {
      if (result is Map && result['expense'] is ExpenseModel) {
        ref.read(expensesProvider.notifier)
            .updateExpense(expense.expense, result['expense'] as ExpenseModel);
      } else if (result is ExpenseModel) {
        ref.read(expensesProvider.notifier)
            .updateExpense(expense.expense, result);
      }
    });
  }

  void _openTransfer(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransferScreen()),
    ).then((result) {
      if (result == true) {
        ref.invalidate(expensesProvider);
      }
    });
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedBalance(
                    balance: balance,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 36,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CompactAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  final double income;
  final double expenses;

  const _MonthlySummary({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = income - expenses;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Income',
                amount: CurrencyFormatter.format(income),
                color: const Color(0xFF10B981),
              ),
            ),
            Container(
              width: 0.5,
              height: 28,
              color: theme.colorScheme.outline,
            ),
            Expanded(
              child: _MiniStat(
                label: 'Expenses',
                amount: CurrencyFormatter.format(expenses),
                color: theme.colorScheme.error,
              ),
            ),
            Container(
              width: 0.5,
              height: 28,
              color: theme.colorScheme.outline,
            ),
            Expanded(
              child: _MiniStat(
                label: 'Net',
                amount: CurrencyFormatter.format(net.abs()),
                color: net >= 0 ? const Color(0xFF10B981) : theme.colorScheme.error,
                prefix: net >= 0 ? '+' : '-',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final String prefix;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$prefix$amount',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
