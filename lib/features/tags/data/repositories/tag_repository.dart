import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../models/tag_model.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TagRepository(db);
});

class TagRepository {
  final AppDatabase _db;

  TagRepository(this._db);

  Future<List<TagModel>> getAll() async {
    final database = await _db.database;
    final rows = await database.query('tags', orderBy: 'name ASC');
    return rows.map(TagModel.fromMap).toList();
  }

  Future<TagModel?> getById(int id) async {
    final database = await _db.database;
    final rows = await database.query(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return TagModel.fromMap(rows.first);
  }

  Future<int> insert(TagModel tag) async {
    final database = await _db.database;
    return database.insert('tags', tag.toMap());
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete('tags', where: 'id = ?', whereArgs: [id]);
  }
}
