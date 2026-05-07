import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/recurring_repository.dart';
import '../data/models/recurring_model.dart';
import '../../expenses/data/models/expense_model.dart';
import '../../expenses/providers/expenses_provider.dart';

final recurringProvider =
    AsyncNotifierProvider<RecurringNotifier, List<RecurringModel>>(
  RecurringNotifier.new,
);

final generatedCountProvider = StateProvider<int>((ref) => 0);

class RecurringNotifier extends AsyncNotifier<List<RecurringModel>> {
  @override
  Future<List<RecurringModel>> build() async {
    final repo = ref.read(recurringRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addRecurring(RecurringModel recurring) async {
    final repo = ref.read(recurringRepositoryProvider);
    await repo.insert(recurring);
    ref.invalidateSelf();
  }

  Future<void> updateRecurring(RecurringModel recurring) async {
    final repo = ref.read(recurringRepositoryProvider);
    await repo.update(recurring);
    ref.invalidateSelf();
  }

  Future<void> deleteRecurring(int id) async {
    final repo = ref.read(recurringRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<void> toggleActive(int id, bool isActive) async {
    final repo = ref.read(recurringRepositoryProvider);
    await repo.toggleActive(id, isActive);
    ref.invalidateSelf();
  }

  Future<int> processDueTransactions() async {
    final repo = ref.read(recurringRepositoryProvider);
    final due = await repo.getDue(DateTime.now());
    if (due.isEmpty) return 0;

    int count = 0;
    for (final r in due) {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final expense = ExpenseModel(
        amount: r.amount,
        type: r.type,
        categoryId: r.categoryId,
        accountId: r.accountId,
        payeeId: r.payeeId,
        note: r.note,
        date: dateStr,
        recurringId: r.id,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      await ref.read(expensesProvider.notifier).addExpense(expense);
      await repo.advanceNextDate(r.id!, r.frequency);
      count++;
    }

    ref.read(generatedCountProvider.notifier).state = count;
    ref.invalidateSelf();
    return count;
  }
}
