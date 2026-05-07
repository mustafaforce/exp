import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String format(double amount) => _format.format(amount);

  static String formatShort(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return _format.format(amount);
  }

  static String formatAmount(double amount, {bool showSign = false}) {
    final formatted = _format.format(amount.abs());
    if (showSign && amount < 0) return '-$formatted';
    if (showSign && amount > 0) return '+$formatted';
    return formatted;
  }
}
