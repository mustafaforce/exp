import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';

final currencySymbolMap = {
  'USD': '\$',
  'BDT': '৳',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  'PKR': 'Rs',
  'INR': '₹',
};

final currencyCodeProvider = StateProvider<String>((ref) => 'USD');

final currencySymbolProvider = Provider<String>((ref) {
  final code = ref.watch(currencyCodeProvider);
  return currencySymbolMap[code] ?? '\$';
});

final initCurrencyProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  final rows = await database.query(
    'settings',
    where: 'key = ?',
    whereArgs: ['currency'],
  );
  if (rows.isNotEmpty) {
    final code = rows.first['value'] as String?;
    if (code != null && code.isNotEmpty) {
      ref.read(currencyCodeProvider.notifier).state = code;
      CurrencyFormatter.setSymbol(currencySymbolMap[code] ?? '\$');
    }
  }
});

Future<void> changeCurrency(WidgetRef ref, String code) async {
  final symbol = currencySymbolMap[code] ?? '\$';
  CurrencyFormatter.setSymbol(symbol);
  ref.read(currencyCodeProvider.notifier).state = code;

  final db = ref.read(databaseProvider);
  final database = await db.database;
  await database.update(
    'settings',
    {'value': code},
    where: 'key = ?',
    whereArgs: ['currency'],
  );
}
