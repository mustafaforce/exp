import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../models/account_model.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AccountRepository(db);
});

class AccountRepository {
  final AppDatabase _db;

  AccountRepository(this._db);

  Future<List<AccountModel>> getAll({bool onlyActive = true}) async {
    final database = await _db.database;
    final rows = await database.query(
      'accounts',
      where: onlyActive ? 'is_active = 1' : null,
      orderBy: 'name ASC',
    );
    return rows.map(AccountModel.fromMap).toList();
  }

  Future<AccountModel?> getById(int id) async {
    final database = await _db.database;
    final rows = await database.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return AccountModel.fromMap(rows.first);
  }

  Future<int> insert(AccountModel account) async {
    final database = await _db.database;
    return database.insert('accounts', account.toMap());
  }

  Future<int> update(AccountModel account) async {
    final database = await _db.database;
    return database.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> updateBalance(int accountId, double delta) async {
    final database = await _db.database;
    final account = await getById(accountId);
    if (account == null) return;
    await database.update(
      'accounts',
      {'balance': account.balance + delta},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<void> setBalance(int accountId, double balance) async {
    final database = await _db.database;
    await database.update(
      'accounts',
      {'balance': balance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
