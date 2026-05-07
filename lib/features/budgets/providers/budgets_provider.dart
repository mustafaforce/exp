import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/budget_repository.dart';
import '../data/models/budget_model.dart';

final budgetsProvider =
    AsyncNotifierProvider<BudgetsNotifier, List<BudgetWithSpending>>(
  BudgetsNotifier.new,
);

final totalBudgetSpendingProvider = Provider<Map<String, double>>((ref) {
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? [];
  double totalBudget = 0;
  double totalSpent = 0;
  for (final b in budgets) {
    totalBudget += b.budget.amount;
    totalSpent += b.spent;
  }
  return {'budget': totalBudget, 'spent': totalSpent};
});

class BudgetsNotifier extends AsyncNotifier<List<BudgetWithSpending>> {
  @override
  Future<List<BudgetWithSpending>> build() async {
    final repo = ref.read(budgetRepositoryProvider);
    final now = DateTime.now();
    final startDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final lastDay =
        DateTime(now.year, now.month + 1, 0);
    final endDate =
        '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';
    return repo.getWithSpending('monthly', startDate, endDate);
  }

  Future<void> addBudget(BudgetModel budget) async {
    final repo = ref.read(budgetRepositoryProvider);
    await repo.insert(budget);
    ref.invalidateSelf();
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final repo = ref.read(budgetRepositoryProvider);
    await repo.update(budget);
    ref.invalidateSelf();
  }

  Future<void> deleteBudget(int id) async {
    final repo = ref.read(budgetRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
