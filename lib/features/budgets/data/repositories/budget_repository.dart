import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../models/budget_model.dart';
import '../../../categories/data/models/category_model.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepository(db);
});

class BudgetWithSpending {
  final BudgetModel budget;
  final CategoryModel? category;
  final double spent;
  final double percentage;
  final List<Map<String, dynamic>> recentTransactions;

  BudgetWithSpending({
    required this.budget,
    this.category,
    required this.spent,
    required this.percentage,
    this.recentTransactions = const [],
  });
}

class BudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  Future<List<BudgetModel>> getAll() async {
    final database = await _db.database;
    final rows =
        await database.query('budgets', orderBy: 'created_at DESC');
    return rows.map(BudgetModel.fromMap).toList();
  }

  Future<BudgetModel?> getById(int id) async {
    final database = await _db.database;
    final rows =
        await database.query('budgets', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return BudgetModel.fromMap(rows.first);
  }

  Future<int> insert(BudgetModel budget) async {
    final database = await _db.database;
    return database.insert('budgets', budget.toMap());
  }

  Future<int> update(BudgetModel budget) async {
    final database = await _db.database;
    return database.update('budgets', budget.toMap(),
        where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database
        .delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BudgetWithSpending>> getWithSpending(
      String period, String startDate, String endDate) async {
    final budgets = await getAll();

    final result = <BudgetWithSpending>[];
    for (final budget in budgets) {
      final spent = await _getSpending(
          budget.categoryId, startDate, endDate);

      final category = budget.categoryId != null
          ? await _getCategory(budget.categoryId!)
          : null;

      result.add(BudgetWithSpending(
        budget: budget,
        category: category,
        spent: spent,
        percentage:
            budget.amount > 0 ? (spent / budget.amount) * 100 : 0.0,
      ));
    }

    return result;
  }

  Future<double> getTotalBudget() async {
    final budgets = await getAll();
    double totalBudget = 0;
    for (final b in budgets) {
      totalBudget += b.amount;
    }
    return totalBudget;
  }

  Future<double> getTotalSpending(
      String startDate, String endDate) async {
    final database = await _db.database;
    final result = await database.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE type = 'expense' AND date >= ? AND date <= ?",
      [startDate, endDate],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> _getSpending(
      int? categoryId, String startDate, String endDate) async {
    final database = await _db.database;
    if (categoryId == null) {
      final result = await database.rawQuery(
        "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE type = 'expense' AND date >= ? AND date <= ?",
        [startDate, endDate],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    }

    final result = await database.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE type = 'expense' AND category_id = ? AND date >= ? AND date <= ?",
      [categoryId, startDate, endDate],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<CategoryModel?> _getCategory(int id) async {
    final database = await _db.database;
    final rows = await database.query(
        'categories', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return CategoryModel.fromMap(rows.first);
  }
}
