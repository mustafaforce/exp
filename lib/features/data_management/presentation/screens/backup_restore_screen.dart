import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Backup exports your entire database. '
                          'Restore replaces all current data with a backup file.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _backup(context),
            icon: const Icon(Icons.download),
            label: const Text('Create Backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _restore(context, ref),
            icon: const Icon(Icons.upload),
            label: const Text('Restore from Backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _backup(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/expense_tracker.db');

      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No database found')),
          );
        }
        return;
      }

      final backupDir = await getTemporaryDirectory();
      final backupPath =
          '${backupDir.path}/expense_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.db';
      await dbFile.copy(backupPath);

      await Share.shareXFiles(
        [XFile(backupPath)],
        text: 'Expense Tracker Backup',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'This will REPLACE all your current data with the backup. '
          'This action cannot be undone. Make sure you have a current backup first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) return;

      final backupFile = File(result.files.single.path!);
      if (!await backupFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup file not found')),
          );
        }
        return;
      }

      // Close current database
      await ref.read(databaseProvider).close();

      // Copy backup over current database
      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/expense_tracker.db');
      await backupFile.copy(dbFile.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database restored. Restarting app...'),
          ),
        );
        // Invalidate all providers to reload data
        ref.invalidate(databaseProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }
}
