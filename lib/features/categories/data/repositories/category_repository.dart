import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../models/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db);
});

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  Future<List<CategoryModel>> getAll({String? type}) async {
    final database = await _db.database;
    String? where;
    if (type != null) where = 'type = ?';
    final rows = await database.query(
      'categories',
      where: where,
      whereArgs: type != null ? [type] : null,
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getTopLevel({String? type}) async {
    final database = await _db.database;
    String? where = 'parent_id IS NULL';
    List<dynamic>? args;
    if (type != null) {
      where += ' AND type = ?';
      args = [type];
    }
    final rows = await database.query(
      'categories',
      where: where,
      whereArgs: args,
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getSubCategories(int parentId) async {
    final database = await _db.database;
    final rows = await database.query(
      'categories',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<CategoryModel?> getById(int id) async {
    final database = await _db.database;
    final rows = await database.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return CategoryModel.fromMap(rows.first);
  }

  Future<int> insert(CategoryModel category) async {
    final database = await _db.database;
    return database.insert('categories', category.toMap());
  }

  Future<int> update(CategoryModel category) async {
    final database = await _db.database;
    return database.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    await database.delete(
      'categories',
      where: 'parent_id = ?',
      whereArgs: [id],
    );
    return database.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
