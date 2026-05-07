import 'package:intl/intl.dart';

class DateUtilsX {
  DateUtilsX._();

  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('EEE, MMM d');
  static final _displayFull = DateFormat('EEEE, MMMM d, yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _monthDay = DateFormat('MMM d');

  static String toDb(DateTime date) => _dateFormat.format(date);

  static DateTime fromDb(String date) => _dateFormat.parse(date);

  static String display(DateTime date) => _displayFormat.format(date);

  static String displayFull(DateTime date) => _displayFull.format(date);

  static String monthYear(DateTime date) => _monthYear.format(date);

  static String monthDay(DateTime date) => _monthDay.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    final diff = today.difference(dateDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
      if (diff < 7) return dateDay.weekdayName;

    return display(date);
  }

  static List<DateTime> getCurrentMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return [start, end];
  }

  static List<DateTime> getCurrentWeekRange() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final start = now.subtract(Duration(days: weekday - 1));
    final end = start.add(const Duration(days: 6));
    return [start, end];
  }
}

extension WeekdayName on DateTime {
  String get weekdayName {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }
}

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
