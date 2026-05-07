import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import '../constants/category_defaults.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

class AppDatabase {
  static Database? _instance;

  Future<Database> get database async {
    _instance ??= await _init();
    return _instance!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'expense_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    for (final table in Tables.allTables) {
      await db.execute(table);
    }
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    for (final cat in CategoryDefaults.expenseCategories) {
      await db.insert('categories', {
        ...cat,
        'created_at': now,
      });
    }

    for (final cat in CategoryDefaults.incomeCategories) {
      await db.insert('categories', {
        ...cat,
        'created_at': now,
      });
    }

    await db.insert('accounts', {
      'name': 'Cash',
      'type': 'cash',
      'balance': 0,
      'icon': 'cash',
      'color': '#10B981',
      'currency': 'USD',
      'is_active': 1,
      'created_at': now,
    });
  }

  Future<void> close() async {
    final db = _instance;
    if (db != null) {
      await db.close();
      _instance = null;
    }
  }
}
