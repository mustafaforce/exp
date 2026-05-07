import 'package:flutter/material.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../payees/presentation/screens/payees_screen.dart';
import '../../../recurring/presentation/screens/recurring_screen.dart';
import '../../../budgets/presentation/screens/budgets_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../data_management/presentation/screens/backup_restore_screen.dart';
import '../../../data_management/presentation/screens/import_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          _SectionHeader(title: 'Management'),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Accounts',
            onTap: () => _push(context, const AccountsScreen()),
          ),
          _SettingsTile(
            icon: Icons.category_outlined,
            label: 'Categories',
            onTap: () => _push(context, const CategoriesScreen()),
          ),
          _SettingsTile(
            icon: Icons.people_outline,
            label: 'Payees',
            onTap: () => _push(context, const PayeesScreen()),
          ),
          _SettingsTile(
            icon: Icons.repeat_rounded,
            label: 'Recurring',
            onTap: () => _push(context, const RecurringScreen()),
          ),
          _SettingsTile(
            icon: Icons.track_changes_rounded,
            label: 'Budgets',
            onTap: () => _push(context, const BudgetsScreen()),
          ),
          _SettingsTile(
            icon: Icons.assessment_outlined,
            label: 'Reports',
            onTap: () => _push(context, const ReportsScreen()),
          ),
          Divider(
            height: 1,
            indent: 12,
            endIndent: 12,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          _SectionHeader(title: 'Data'),
          _SettingsTile(
            icon: Icons.cloud_upload_outlined,
            label: 'Backup & Restore',
            onTap: () => _push(context, const BackupRestoreScreen()),
          ),
          _SettingsTile(
            icon: Icons.file_upload_outlined,
            label: 'Import CSV',
            onTap: () => _push(context, const ImportScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: theme.textTheme.titleMedium),
            ),
            Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
