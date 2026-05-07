import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../models/split_model.dart';

final splitRepositoryProvider = Provider<SplitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SplitRepository(db);
});

class SplitRepository {
  final AppDatabase _db;

  SplitRepository(this._db);

  Future<List<SplitModel>> getByExpenseId(int expenseId) async {
    final database = await _db.database;
    final rows = await database.query(
      'splits',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    return rows.map(SplitModel.fromMap).toList();
  }

  Future<int> insert(SplitModel split) async {
    final database = await _db.database;
    return database.insert('splits', split.toMap());
  }

  Future<void> insertBatch(int expenseId, List<SplitModel> splits) async {
    final database = await _db.database;
    await database.transaction((txn) async {
      await txn.delete('splits',
          where: 'expense_id = ?', whereArgs: [expenseId]);
      for (final split in splits) {
        await txn.insert('splits', {
          'expense_id': expenseId,
          'category_id': split.categoryId,
          'amount': split.amount,
          'note': split.note,
        });
      }
    });
  }

  Future<void> deleteByExpenseId(int expenseId) async {
    final database = await _db.database;
    await database.delete('splits',
        where: 'expense_id = ?', whereArgs: [expenseId]);
  }
}
