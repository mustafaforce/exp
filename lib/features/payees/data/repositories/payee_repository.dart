import '../../../../core/database/app_database.dart';
import '../models/payee_model.dart';

class PayeeRepository {
  final AppDatabase _db;

  PayeeRepository(this._db);

  Future<List<PayeeModel>> getAll() async {
    final database = await _db.database;
    final rows = await database.query('payees', orderBy: 'name ASC');
    return rows.map(PayeeModel.fromMap).toList();
  }

  Future<PayeeModel?> getById(int id) async {
    final database = await _db.database;
    final rows = await database.query(
      'payees',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return PayeeModel.fromMap(rows.first);
  }

  Future<int> insert(PayeeModel payee) async {
    final database = await _db.database;
    return database.insert('payees', payee.toMap());
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete('payees', where: 'id = ?', whereArgs: [id]);
  }
}
