import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/app_database.dart';

class ReportData {
  final String startDate;
  final String endDate;
  final double totalIncome;
  final double totalExpenses;
  final double net;
  final List<ReportCategoryRow> categoryRows;
  final List<ReportTransactionRow> transactions;
  final double dailyAverage;

  ReportData({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.net,
    required this.categoryRows,
    required this.transactions,
    required this.dailyAverage,
  });
}

class ReportCategoryRow {
  final String category;
  final double amount;
  final double percentage;

  ReportCategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class ReportTransactionRow {
  final String date;
  final String type;
  final String? category;
  final String? payee;
  final String? note;
  final double amount;

  ReportTransactionRow({
    required this.date,
    required this.type,
    required this.category,
    required this.payee,
    required this.note,
    required this.amount,
  });
}

final reportsProvider =
    FutureProvider.family<ReportData?, Map<String, String>>((ref, dateRange) {
  return _generateReport(
      ref, dateRange['start']!, dateRange['end']!);
});

Future<ReportData> _generateReport(
    Ref ref, String startDate, String endDate) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;

  // Total income
  final incomeResult = await database.rawQuery(
    "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE type = 'income' AND date >= ? AND date <= ?",
    [startDate, endDate],
  );
  final totalIncome =
      (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;

  // Total expenses
  final expenseResult = await database.rawQuery(
    "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE type = 'expense' AND date >= ? AND date <= ?",
    [startDate, endDate],
  );
  final totalExpenses =
      (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

  // Category breakdown
  final catRows = await database.rawQuery('''
    SELECT c.name, COALESCE(SUM(e.amount), 0) as total
    FROM expenses e
    LEFT JOIN categories c ON e.category_id = c.id
    WHERE e.type = 'expense' AND e.date >= ? AND e.date <= ?
    GROUP BY e.category_id
    ORDER BY total DESC
  ''', [startDate, endDate]);

  final catList = catRows.map((r) {
    final amount = (r['total'] as num?)?.toDouble() ?? 0.0;
    return ReportCategoryRow(
      category: (r['name'] as String?) ?? 'Uncategorized',
      amount: amount,
      percentage:
          totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0.0,
    );
  }).toList();

  // Transactions
  final txnRows = await database.rawQuery('''
    SELECT e.date, e.type, c.name as category, p.name as payee, e.note, e.amount
    FROM expenses e
    LEFT JOIN categories c ON e.category_id = c.id
    LEFT JOIN payees p ON e.payee_id = p.id
    WHERE e.date >= ? AND e.date <= ?
    ORDER BY e.date DESC
  ''', [startDate, endDate]);

  final txns = txnRows.map((r) {
    return ReportTransactionRow(
      date: (r['date'] as String?) ?? '',
      type: (r['type'] as String?) ?? '',
      category: r['category'] as String?,
      payee: r['payee'] as String?,
      note: r['note'] as String?,
      amount: (r['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }).toList();

  // Daily average
  final start = DateTime.parse(startDate);
  final end = DateTime.parse(endDate);
  final days = end.difference(start).inDays + 1;
  final dailyAverage = days > 0 ? totalExpenses / days : 0.0;

  return ReportData(
    startDate: startDate,
    endDate: endDate,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    net: totalIncome - totalExpenses,
    categoryRows: catList,
    transactions: txns,
    dailyAverage: dailyAverage,
  );
}

Future<String> exportToCsv(ReportData data) async {
  final rows = <List<String>>[
    ['Date', 'Type', 'Category', 'Payee', 'Note', 'Amount'],
  ];

  for (final txn in data.transactions) {
    rows.add([
      txn.date,
      txn.type,
      txn.category ?? '',
      txn.payee ?? '',
      txn.note ?? '',
      txn.amount.toStringAsFixed(2),
    ]);
  }

  final csv = const ListToCsvConverter().convert(rows);
  final dir = await getTemporaryDirectory();
  final file = File(
      '${dir.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.csv');
  await file.writeAsString(csv);
  return file.path;
}

Future<void> shareFile(String path) async {
  await Share.shareXFiles([XFile(path)], text: 'Expense Report');
}
