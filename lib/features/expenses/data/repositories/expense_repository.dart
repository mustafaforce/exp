import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../models/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepository(db);
});

class ExpenseWithDetails {
  final ExpenseModel expense;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? accountName;
  final String? payeeName;
  final List<Map<String, dynamic>> tags;
  final List<Map<String, dynamic>> splits;

  const ExpenseWithDetails({
    required this.expense,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountName,
    this.payeeName,
    this.tags = const [],
    this.splits = const [],
  });
}

class ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepository(this._db);

  Future<List<ExpenseWithDetails>> getAll({
    String? type,
    String? dateFrom,
    String? dateTo,
    int? categoryId,
    int? accountId,
    String? searchQuery,
    String? orderBy = 'e.date DESC, e.created_at DESC',
  }) async {
    final database = await _db.database;
    final where = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      where.add('e.type = ?');
      args.add(type);
    }
    if (dateFrom != null) {
      where.add('e.date >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      where.add('e.date <= ?');
      args.add(dateTo);
    }
    if (categoryId != null) {
      where.add('e.category_id = ?');
      args.add(categoryId);
    }
    if (accountId != null) {
      where.add('(e.account_id = ? OR e.to_account_id = ?)');
      args.addAll([accountId, accountId]);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      where.add('(e.note LIKE ? OR p.name LIKE ?)');
      final q = '%$searchQuery%';
      args.addAll([q, q]);
    }

    final query = '''
      SELECT e.*, c.name as category_name, c.icon as category_icon,
             c.color as category_color, a.name as account_name, p.name as payee_name
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      LEFT JOIN accounts a ON e.account_id = a.id
      LEFT JOIN payees p ON e.payee_id = p.id
      ${where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : ''}
      ORDER BY $orderBy
    ''';

    final rows = await database.rawQuery(query, args);
    return rows.map((row) {
      final expense = ExpenseModel.fromMap(row);
      return ExpenseWithDetails(
        expense: expense,
        categoryName: row['category_name'] as String?,
        categoryIcon: row['category_icon'] as String?,
        categoryColor: row['category_color'] as String?,
        accountName: row['account_name'] as String?,
        payeeName: row['payee_name'] as String?,
      );
    }).toList();
  }

  Future<ExpenseWithDetails?> getById(int id) async {
    final database = await _db.database;
    final rows = await database.rawQuery('''
      SELECT e.*, c.name as category_name, c.icon as category_icon,
             c.color as category_color, a.name as account_name, p.name as payee_name
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      LEFT JOIN accounts a ON e.account_id = a.id
      LEFT JOIN payees p ON e.payee_id = p.id
      WHERE e.id = ?
    ''', [id]);

    if (rows.isEmpty) return null;
    final row = rows.first;
    final expense = ExpenseModel.fromMap(row);
    return ExpenseWithDetails(
      expense: expense,
      categoryName: row['category_name'] as String?,
      categoryIcon: row['category_icon'] as String?,
      categoryColor: row['category_color'] as String?,
      accountName: row['account_name'] as String?,
      payeeName: row['payee_name'] as String?,
    );
  }

  Future<int> insert(ExpenseModel expense) async {
    final database = await _db.database;
    final id = await database.insert('expenses', expense.toMap());

    if (expense.type == 'expense') {
      await _updateAccountBalance(expense.accountId, -expense.amount);
    } else if (expense.type == 'income') {
      await _updateAccountBalance(expense.accountId, expense.amount);
    } else if (expense.type == 'transfer') {
      if (expense.toAccountId != null) {
        await _updateAccountBalance(
            expense.accountId, -expense.amount);
        await _updateAccountBalance(
            expense.toAccountId!, expense.amount);
      }
    }

    return id;
  }

  Future<int> update(ExpenseModel oldExpense, ExpenseModel newExpense) async {
    final database = await _db.database;

    // Reverse old expense balance changes
    if (oldExpense.type == 'expense') {
      await _updateAccountBalance(
          oldExpense.accountId, oldExpense.amount);
    } else if (oldExpense.type == 'income') {
      await _updateAccountBalance(
          oldExpense.accountId, -oldExpense.amount);
    } else if (oldExpense.type == 'transfer') {
      if (oldExpense.toAccountId != null) {
        await _updateAccountBalance(
            oldExpense.accountId, oldExpense.amount);
        await _updateAccountBalance(
            oldExpense.toAccountId!, -oldExpense.amount);
      }
    }

    // Apply new expense balance changes
    if (newExpense.type == 'expense') {
      await _updateAccountBalance(
          newExpense.accountId, -newExpense.amount);
    } else if (newExpense.type == 'income') {
      await _updateAccountBalance(
          newExpense.accountId, newExpense.amount);
    } else if (newExpense.type == 'transfer') {
      if (newExpense.toAccountId != null) {
        await _updateAccountBalance(
            newExpense.accountId, -newExpense.amount);
        await _updateAccountBalance(
            newExpense.toAccountId!, newExpense.amount);
      }
    }

    return database.update(
      'expenses',
      newExpense.toMap(),
      where: 'id = ?',
      whereArgs: [newExpense.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await _db.database;
    final existing = await getById(id);
    if (existing == null) return;

    final exp = existing.expense;

    // Reverse balance changes
    if (exp.type == 'expense') {
      await _updateAccountBalance(exp.accountId, exp.amount);
    } else if (exp.type == 'income') {
      await _updateAccountBalance(exp.accountId, -exp.amount);
    } else if (exp.type == 'transfer') {
      if (exp.toAccountId != null) {
        await _updateAccountBalance(exp.accountId, exp.amount);
        await _updateAccountBalance(exp.toAccountId!, -exp.amount);
      }
    }

    await database.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotal({
    String? type,
    String? dateFrom,
    String? dateTo,
    int? categoryId,
    int? accountId,
  }) async {
    final database = await _db.database;
    final where = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (dateFrom != null) {
      where.add('date >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null) {
      where.add('date <= ?');
      args.add(dateTo);
    }
    if (categoryId != null) {
      where.add('category_id = ?');
      args.add(categoryId);
    }
    if (accountId != null) {
      where.add('(account_id = ? OR to_account_id = ?)');
      args.addAll([accountId, accountId]);
    }

    final result = await database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses '
      '${where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : ''}',
      args,
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> _updateAccountBalance(int accountId, double delta) async {
    final database = await _db.database;
    await database.rawUpdate(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      [delta, accountId],
    );
  }
}
