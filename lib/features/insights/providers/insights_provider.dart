import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';

class InsightsData {
  final double totalExpenses;
  final double totalIncome;
  final double netCashFlow;
  final double netWorth;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<DailySpending> weeklySpending;
  final List<MonthlyTrend> monthlyTrend;
  final List<CategoryRank> topCategories;

  InsightsData({
    required this.totalExpenses,
    required this.totalIncome,
    required this.netCashFlow,
    required this.netWorth,
    required this.categoryBreakdown,
    required this.weeklySpending,
    required this.monthlyTrend,
    required this.topCategories,
  });
}

class CategoryBreakdown {
  final String categoryName;
  final String icon;
  final String color;
  final double amount;
  final double percentage;

  CategoryBreakdown({
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

class DailySpending {
  final String day;
  final double amount;
  final bool isToday;

  DailySpending({
    required this.day,
    required this.amount,
    this.isToday = false,
  });
}

class MonthlyTrend {
  final String month;
  final double amount;

  MonthlyTrend({required this.month, required this.amount});
}

class CategoryRank {
  final String categoryName;
  final String icon;
  final String color;
  final double amount;
  final double percentage;

  CategoryRank({
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

final insightsProvider = FutureProvider<InsightsData>((ref) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  final now = DateTime.now();

  // Current month range
  final monthStart =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  final monthEnd = _formatDate(DateTime(now.year, now.month + 1, 0));

  // Total expenses this month
  final totalExp = await _getTotal(database, 'expense', monthStart, monthEnd);

  // Total income this month
  final totalInc = await _getTotal(database, 'income', monthStart, monthEnd);

  // Category breakdown
  final catBreakdown = await _getCategoryBreakdown(database, monthStart, monthEnd);

  // Weekly spending (current week)
  final weekly = await _getWeeklySpending(database);

  // Monthly trend (last 6 months)
  final trend = await _getMonthlyTrend(database);

  // Top categories
  final topCats = catBreakdown
      .map((c) => CategoryRank(
            categoryName: c.categoryName,
            icon: c.icon,
            color: c.color,
            amount: c.amount,
            percentage: c.percentage,
          ))
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  // Net worth
  final accounts = await database.query('accounts',
      where: 'is_active = 1');
  double netWorth = 0;
  for (final a in accounts) {
    netWorth += (a['balance'] as num?)?.toDouble() ?? 0.0;
  }

  return InsightsData(
    totalExpenses: totalExp,
    totalIncome: totalInc,
    netCashFlow: totalInc - totalExp,
    netWorth: netWorth,
    categoryBreakdown: catBreakdown,
    weeklySpending: weekly,
    monthlyTrend: trend,
    topCategories: topCats.take(5).toList(),
  );
});

Future<double> _getTotal(
    Database db, String type, String start, String end) async {
  final result = await db.rawQuery(
    "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE type = ? AND date >= ? AND date <= ?",
    [type, start, end],
  );
  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
}

Future<List<CategoryBreakdown>> _getCategoryBreakdown(
    Database db, String start, String end) async {
  final rows = await db.rawQuery('''
    SELECT c.name, c.icon, c.color, COALESCE(SUM(e.amount), 0) as total
    FROM expenses e
    LEFT JOIN categories c ON e.category_id = c.id
    WHERE e.type = 'expense' AND e.date >= ? AND e.date <= ?
    GROUP BY e.category_id
    ORDER BY total DESC
  ''', [start, end]);

  final grandTotal =
      rows.fold<double>(0.0, (sum, r) => sum + ((r['total'] as num?)?.toDouble() ?? 0.0));

  return rows.map((r) {
    final amount = (r['total'] as num?)?.toDouble() ?? 0.0;
    return CategoryBreakdown(
      categoryName: (r['name'] as String?) ?? 'Uncategorized',
      icon: (r['icon'] as String?) ?? 'category',
      color: (r['color'] as String?) ?? '#94A3B8',
      amount: amount,
      percentage: grandTotal > 0 ? (amount / grandTotal) * 100 : 0.0,
    );
  }).toList();
}

Future<List<DailySpending>> _getWeeklySpending(Database db) async {
  final now = DateTime.now();
  final weekday = now.weekday;
  final weekStart = now.subtract(Duration(days: weekday - 1));
  final startStr = _formatDate(weekStart);
  final endStr = _formatDate(now);

  final rows = await db.rawQuery('''
    SELECT date, SUM(amount) as total
    FROM expenses
    WHERE type = 'expense' AND date >= ? AND date <= ?
    GROUP BY date
  ''', [startStr, endStr]);

  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final result = <DailySpending>[];

  for (int i = 0; i < 7; i++) {
    final day = weekStart.add(Duration(days: i));
    final dayStr = _formatDate(day);
    final found = rows.firstWhere(
      (r) => r['date'] == dayStr,
      orElse: () => {'total': 0.0},
    );
    result.add(DailySpending(
      day: dayNames[i],
      amount: (found['total'] as num?)?.toDouble() ?? 0.0,
      isToday: i == weekday - 1,
    ));
  }

  return result;
}

Future<List<MonthlyTrend>> _getMonthlyTrend(Database db) async {
  final now = DateTime.now();
  final result = <MonthlyTrend>[];

  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthStart = _formatDate(month);
    final monthEnd = _formatDate(DateTime(month.year, month.month + 1, 0));

    final row = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE type = 'expense' AND date >= ? AND date <= ?",
      [monthStart, monthEnd],
    );

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    result.add(MonthlyTrend(
      month: monthNames[month.month - 1],
      amount: (row.first['total'] as num?)?.toDouble() ?? 0.0,
    ));
  }

  return result;
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
