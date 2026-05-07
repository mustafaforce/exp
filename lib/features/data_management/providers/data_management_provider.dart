import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';
import '../../expenses/data/models/expense_model.dart';

final importProvider = Provider<CsvImporter>((ref) {
  final db = ref.read(databaseProvider);
  return CsvImporter(db);
});

class ImportResult {
  final int imported;
  final int skipped;
  final List<String> errors;

  ImportResult({
    required this.imported,
    required this.skipped,
    this.errors = const [],
  });
}

class CsvImporter {
  final AppDatabase _db;

  CsvImporter(this._db);

  Future<List<List<dynamic>>> parseFile(String path) async {
    final file = File(path);
    final content = await file.readAsString();
    return const CsvToListConverter().convert(content);
  }

  Future<ImportResult> import({
    required List<List<dynamic>> rows,
    required int dateCol,
    required int amountCol,
    int? categoryCol,
    int? noteCol,
    int? typeCol,
    bool hasHeader = true,
  }) async {
    final database = await _db.database;
    int imported = 0;
    int skipped = 0;
    final errors = <String>[];

    final startIndex = hasHeader ? 1 : 0;

    for (int i = startIndex; i < rows.length; i++) {
      try {
        final row = rows[i];
        if (row.length <= amountCol || row.length <= dateCol) {
          skipped++;
          continue;
        }

        final dateStr = row[dateCol].toString().trim();
        final amountStr = row[amountCol].toString().trim();

        DateTime? date;
        try {
          date = DateTime.parse(dateStr);
        } catch (_) {
          // Try common formats
          try {
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              date = DateTime(
                  int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
            }
          } catch (_) {
            skipped++;
            errors.add('Row $i: Invalid date "$dateStr"');
            continue;
          }
        }

        final amount = double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (amount == null || amount <= 0) {
          skipped++;
          errors.add('Row $i: Invalid amount "$amountStr"');
          continue;
        }

        final type = typeCol != null && row.length > typeCol
            ? row[typeCol].toString().trim().toLowerCase()
            : 'expense';
        final note = noteCol != null && row.length > noteCol
            ? row[noteCol].toString().trim()
            : null;

        // Get default account
        final accounts = await database.query('accounts',
            where: 'is_active = 1', limit: 1);
        if (accounts.isEmpty) {
          skipped++;
          errors.add('Row $i: No active account found');
          continue;
        }
        final accountId = accounts.first['id'] as int;

        // Find or create category
        int? categoryId;
        if (categoryCol != null && row.length > categoryCol) {
          final catName = row[categoryCol].toString().trim();
          if (catName.isNotEmpty) {
            final cats = await database.query('categories',
                where: 'name LIKE ? AND type = ?',
                whereArgs: [catName, type]);
            if (cats.isNotEmpty) {
              categoryId = cats.first['id'] as int;
            }
          }
        }

        final now = DateTime.now().toIso8601String();
        final expense = ExpenseModel(
          amount: amount,
          type: type == 'income' ? 'income' : 'expense',
          categoryId: categoryId,
          accountId: accountId,
          note: note,
          date: DateUtilsX.toDb(date!),
          createdAt: now,
          updatedAt: now,
        );

        await database.insert('expenses', expense.toMap());

        // Update account balance
        if (type == 'expense') {
          await database.rawUpdate(
            'UPDATE accounts SET balance = balance - ? WHERE id = ?',
            [amount, accountId],
          );
        } else {
          await database.rawUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            [amount, accountId],
          );
        }

        imported++;
      } catch (e) {
        skipped++;
        errors.add('Row $i: $e');
      }
    }

    return ImportResult(imported: imported, skipped: skipped, errors: errors);
  }
}
