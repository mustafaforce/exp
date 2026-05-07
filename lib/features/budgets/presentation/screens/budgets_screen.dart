import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../providers/budgets_provider.dart';
import '../widgets/budget_card.dart';
import 'add_budget_screen.dart';
import 'budget_detail_screen.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetsAsync = ref.watch(budgetsProvider);
    final totalData = ref.watch(totalBudgetSpendingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _addBudget(context, ref),
        child: const Icon(Icons.add, size: 20),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return EmptyState(
              icon: Icons.track_changes_outlined,
              headline: 'No budgets created',
              description: 'Set spending limits to stay on track.',
              ctaLabel: 'Create Budget',
              onCta: () => _addBudget(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetsProvider);
            },
            child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 72),
              itemCount: budgets.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final totalBudget = totalData['budget'] ?? 0.0;
                  final totalSpent = totalData['spent'] ?? 0.0;
                  final pct = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AnimationConfiguration.staggeredList(
                      position: 0,
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(
                          child: Card(
                            color: theme.colorScheme.primary,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Budget',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                          )),
                                      Text('${pct.toStringAsFixed(0)}%',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: Colors.white70,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: SizedBox(
                                      height: 4,
                                      child: LinearProgressIndicator(
                                        value: (pct / 100).clamp(0, 1),
                                        backgroundColor: Colors.white24,
                                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(totalSpent),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'of ${CurrencyFormatter.format(totalBudget)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final data = budgets[index - 1];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 300),
                  child: SlideAnimation(
                    verticalOffset: 30,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: BudgetCard(
                          data: data,
                          onTap: () => _openDetail(context, data),
                          onDelete: () => _deleteBudget(context, ref, data),
                        ),
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
    );
  }

  void _addBudget(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
    );
  }

  void _openDetail(BuildContext context, dynamic data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BudgetDetailScreen(data: data)),
    );
  }

  Future<void> _deleteBudget(
      BuildContext context, WidgetRef ref, dynamic data) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Budget',
      message: 'Delete budget for "${data.category?.name ?? 'Overall'}"?',
      confirmLabel: 'Delete',
      confirmColor: Theme.of(context).colorScheme.error,
      icon: Icons.delete_outline,
    );
    if (confirmed == true && data.budget.id != null) {
      ref.read(budgetsProvider.notifier).deleteBudget(data.budget.id!);
    }
  }
}
