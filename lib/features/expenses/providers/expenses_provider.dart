import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/expense_repository.dart';
import '../data/models/expense_model.dart';

final expensesProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<ExpenseWithDetails>>(
  ExpensesNotifier.new,
);

final expensesByDateProvider = Provider.family<List<ExpenseWithDetails>, String>(
  (ref, date) {
    final expenses = ref.watch(expensesProvider).valueOrNull ?? [];
    return expenses.where((e) => e.expense.date == date).toList();
  },
);

class ExpensesNotifier extends AsyncNotifier<List<ExpenseWithDetails>> {
  String? _typeFilter;
  String? _dateFrom;
  String? _dateTo;
  int? _categoryId;
  int? _accountId;
  String? _searchQuery;

  void setFilters({
    String? type,
    String? dateFrom,
    String? dateTo,
    int? categoryId,
    int? accountId,
    String? searchQuery,
  }) {
    _typeFilter = type;
    _dateFrom = dateFrom;
    _dateTo = dateTo;
    _categoryId = categoryId;
    _accountId = accountId;
    _searchQuery = searchQuery;
    ref.invalidateSelf();
  }

  void clearFilters() {
    _typeFilter = null;
    _dateFrom = null;
    _dateTo = null;
    _categoryId = null;
    _accountId = null;
    _searchQuery = null;
    ref.invalidateSelf();
  }

  @override
  Future<List<ExpenseWithDetails>> build() async {
    final repo = ref.read(expenseRepositoryProvider);
    return repo.getAll(
      type: _typeFilter,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      categoryId: _categoryId,
      accountId: _accountId,
      searchQuery: _searchQuery,
    );
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.insert(expense);
    ref.invalidateSelf();
    ref.invalidate(accountBalancesProvider);
  }

  Future<void> updateExpense(
      ExpenseModel oldExpense, ExpenseModel newExpense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.update(oldExpense, newExpense);
    ref.invalidateSelf();
    ref.invalidate(accountBalancesProvider);
  }

  Future<void> deleteExpense(int id) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
    ref.invalidate(accountBalancesProvider);
  }
}

final accountBalancesProvider = FutureProvider<void>((ref) async {
  // Dummy provider to trigger refreshes when balances change
});
