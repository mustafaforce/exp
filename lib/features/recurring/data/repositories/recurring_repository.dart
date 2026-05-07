import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../models/recurring_model.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecurringRepository(db);
});

class RecurringRepository {
  final AppDatabase _db;

  RecurringRepository(this._db);

  Future<List<RecurringModel>> getAll({bool? isActive}) async {
    final database = await _db.database;
    String? where;
    if (isActive != null) {
      where = 'is_active = ?';
    }
    final rows = await database.query(
      'recurring_transactions',
      where: where,
      whereArgs: isActive != null ? [isActive ? 1 : 0] : null,
      orderBy: 'next_date ASC',
    );
    return rows.map(RecurringModel.fromMap).toList();
  }

  Future<int> insert(RecurringModel recurring) async {
    final database = await _db.database;
    return database.insert(
        'recurring_transactions', recurring.toMap());
  }

  Future<int> update(RecurringModel recurring) async {
    final database = await _db.database;
    return database.update(
      'recurring_transactions',
      recurring.toMap(),
      where: 'id = ?',
      whereArgs: [recurring.id],
    );
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleActive(int id, bool isActive) async {
    final database = await _db.database;
    await database.update(
      'recurring_transactions',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<RecurringModel>> getDue(DateTime date) async {
    final database = await _db.database;
    final dateStr = _formatDate(date);
    final rows = await database.rawQuery('''
      SELECT * FROM recurring_transactions
      WHERE is_active = 1 AND next_date <= ?
      AND (end_date IS NULL OR end_date >= ?)
    ''', [dateStr, dateStr]);
    return rows.map(RecurringModel.fromMap).toList();
  }

  Future<void> advanceNextDate(int id, String frequency) async {
    final database = await _db.database;
    final recurring = await getById(id);
    if (recurring == null) return;

    final nextDate =
        DateTime.parse(recurring.nextDate);
    DateTime newDate;

    switch (frequency) {
      case 'daily':
        newDate = nextDate.add(const Duration(days: 1));
        break;
      case 'weekly':
        newDate = nextDate.add(const Duration(days: 7));
        break;
      case 'biweekly':
        newDate = nextDate.add(const Duration(days: 14));
        break;
      case 'monthly':
        newDate = DateTime(nextDate.year, nextDate.month + 1,
            nextDate.day);
        break;
      case 'yearly':
        newDate = DateTime(nextDate.year + 1, nextDate.month,
            nextDate.day);
        break;
      default:
        newDate = nextDate.add(const Duration(days: 30));
    }

    await database.update(
      'recurring_transactions',
      {'next_date': _formatDate(newDate)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<RecurringModel?> getById(int id) async {
    final database = await _db.database;
    final rows = await database.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return RecurringModel.fromMap(rows.first);
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
