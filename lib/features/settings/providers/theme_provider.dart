import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final initThemeProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  final rows = await database.query(
    'settings',
    where: 'key = ?',
    whereArgs: ['theme_mode'],
  );
  if (rows.isNotEmpty) {
    final value = rows.first['value'] as String?;
    switch (value) {
      case 'light':
        ref.read(themeModeProvider.notifier).state = ThemeMode.light;
      case 'dark':
        ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
      default:
        ref.read(themeModeProvider.notifier).state = ThemeMode.system;
    }
  }
});

Future<void> changeThemeMode(WidgetRef ref, ThemeMode mode) async {
  ref.read(themeModeProvider.notifier).state = mode;

  final db = ref.read(databaseProvider);
  final database = await db.database;

  final value = switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  final existing = await database.query(
    'settings',
    where: 'key = ?',
    whereArgs: ['theme_mode'],
  );

  if (existing.isEmpty) {
    await database.insert('settings', {
      'key': 'theme_mode',
      'value': value,
    });
  } else {
    await database.update(
      'settings',
      {'value': value},
      where: 'key = ?',
      whereArgs: ['theme_mode'],
    );
  }
}
