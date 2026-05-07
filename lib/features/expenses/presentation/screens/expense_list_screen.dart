import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expenses_provider.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_expense_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          if (_filter != 'all')
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                setState(() => _filter = 'all');
                ref.read(expensesProvider.notifier).clearFilters();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == 'all',
                  onTap: () {
                    setState(() => _filter = 'all');
                    ref.read(expensesProvider.notifier).clearFilters();
                  },
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Week',
                  selected: _filter == 'week',
                  onTap: () {
                    setState(() => _filter = 'week');
                    final range = DateUtilsX.getCurrentWeekRange();
                    ref.read(expensesProvider.notifier).setFilters(
                          dateFrom: DateUtilsX.toDb(range[0]),
                          dateTo: DateUtilsX.toDb(range[1]),
                        );
                  },
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Month',
                  selected: _filter == 'month',
                  onTap: () {
                    setState(() => _filter = 'month');
                    final range = DateUtilsX.getCurrentMonthRange();
                    ref.read(expensesProvider.notifier).setFilters(
                          dateFrom: DateUtilsX.toDb(range[0]),
                          dateTo: DateUtilsX.toDb(range[1]),
                        );
                  },
                ),
              ],
            ),
          ),

          // Expense list
          Expanded(
            child: expensesAsync.when(
              loading: () => _buildShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    headline: 'No transactions yet',
                    description: 'Tap + to record your first expense or income.',
                    ctaLabel: 'Add Transaction',
                    onCta: () => _addExpense(context),
                  );
                }

                final grouped = _groupByDate(expenses);
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(expensesProvider);
                  },
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 72),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final date = grouped.keys.elementAt(index);
                        final items = grouped[date]!;

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 300),
                          child: SlideAnimation(
                            verticalOffset: 30,
                            child: FadeInAnimation(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _DateHeader(date: date),
                                  ...items.map((item) => TransactionTile(
                                        expense: item,
                                        onTap: () => _editExpense(context, item),
                                        onLongPress: () => _showOptionsSheet(context, item),
                                      )),
                                  Divider(
                                    height: 0.5,
                                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _addExpense(context),
        child: const Icon(Icons.add, size: 20),
      ),
    );
  }

  Widget _buildShimmer() {
    return Skeletonizer(
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const CircleAvatar(radius: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Loading payee'),
                    SizedBox(height: 2),
                    Text('Loading note'),
                  ],
                ),
              ),
              const Text('\$99.99'),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<ExpenseWithDetails>> _groupByDate(
      List<ExpenseWithDetails> expenses) {
    final map = <String, List<ExpenseWithDetails>>{};
    for (final exp in expenses) {
      map.putIfAbsent(exp.expense.date, () => []).add(exp);
    }
    return map;
  }

  void _addExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
    ).then((result) {
      ExpenseModel? expense;
      if (result is Map && result['expense'] is ExpenseModel) {
        expense = result['expense'] as ExpenseModel;
      } else if (result is ExpenseModel) {
        expense = result;
      }
      if (expense != null) {
        HapticFeedback.lightImpact();
        ref.read(expensesProvider.notifier).addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${expense.type == 'income' ? 'Income' : 'Expense'} saved'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _editExpense(BuildContext context, ExpenseWithDetails expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(expense: expense.expense),
      ),
    ).then((result) {
      ExpenseModel? updated;
      if (result is Map && result['expense'] is ExpenseModel) {
        updated = result['expense'] as ExpenseModel;
      } else if (result is ExpenseModel) {
        updated = result;
      }
      if (updated != null) {
        HapticFeedback.lightImpact();
        ref.read(expensesProvider.notifier)
            .updateExpense(expense.expense, updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction updated'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _showOptionsSheet(BuildContext context, ExpenseWithDetails item) {
    final theme = Theme.of(context);
    final exp = item.expense;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.payeeName ?? item.categoryName ?? 'Transaction',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${exp.isExpense ? '-' : exp.isIncome ? '+' : ''}${CurrencyFormatter.format(exp.amount)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.edit_outlined, size: 20,
                  color: theme.colorScheme.onSurface),
              title: const Text('Edit'),
              dense: true,
              onTap: () {
                Navigator.pop(ctx);
                _editExpense(context, item);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, size: 20,
                  color: theme.colorScheme.error),
              title: Text('Delete',
                  style: TextStyle(color: theme.colorScheme.error)),
              dense: true,
              onTap: () {
                Navigator.pop(ctx);
                _deleteExpense(context, item);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _deleteExpense(BuildContext context, ExpenseWithDetails expense) {
    if (expense.expense.id == null) return;
    HapticFeedback.mediumImpact();
    ref.read(expensesProvider.notifier).deleteExpense(expense.expense.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateTime = DateUtilsX.fromDb(date);
    final label = DateUtilsX.relative(dateTime);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
