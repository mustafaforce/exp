import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  final rows = await database.query(
    'settings',
    where: 'key = ?',
    whereArgs: ['onboarding_done'],
  );
  if (rows.isEmpty) return false;
  return rows.first['value'] == 'true';
});

Future<void> markOnboardingDone(WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;

  final existing = await database.query(
    'settings',
    where: 'key = ?',
    whereArgs: ['onboarding_done'],
  );

  if (existing.isEmpty) {
    await database.insert('settings', {
      'key': 'onboarding_done',
      'value': 'true',
    });
  } else {
    await database.update(
      'settings',
      {'value': 'true'},
      where: 'key = ?',
      whereArgs: ['onboarding_done'],
    );
  }

  ref.invalidate(onboardingDoneProvider);
}
