import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../payees/presentation/screens/payees_screen.dart';
import '../../../recurring/presentation/screens/recurring_screen.dart';
import '../../../budgets/presentation/screens/budgets_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../data_management/presentation/screens/backup_restore_screen.dart';
import '../../../data_management/presentation/screens/import_screen.dart';
import '../../providers/currency_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyCodeProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

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
          _SectionHeader(title: 'Preferences'),
          _ThemeModeTile(),
          _CurrencyTile(
            currencyCode: currencyCode,
            currencySymbol: currencySymbol,
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

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeModeProvider);
    final label = switch (currentMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
    final icon = switch (currentMode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };

    return InkWell(
      onTap: () => _showThemePicker(context, ref, currentMode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Theme', style: theme.textTheme.titleMedium),
            ),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                size: 16, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(
      BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Theme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final entry in {
              ThemeMode.system: ('System', Icons.brightness_auto_outlined),
              ThemeMode.light: ('Light', Icons.light_mode_outlined),
              ThemeMode.dark: ('Dark', Icons.dark_mode_outlined),
            }.entries)
              ListTile(
                leading: Icon(entry.value.$2),
                title: Text(entry.value.$1),
                trailing: current == entry.key
                    ? Icon(Icons.check,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  changeThemeMode(ref, entry.key);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyTile extends ConsumerWidget {
  final String currencyCode;
  final String currencySymbol;

  const _CurrencyTile({
    required this.currencyCode,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showCurrencyPicker(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.monetization_on_outlined,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Currency',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              '$currencySymbol $currencyCode',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                size: 16, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final supported = currencySymbolMap.keys.toList();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Currency',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...supported.map((code) {
              final symbol = currencySymbolMap[code] ?? '';
              return ListTile(
                title: Text('$symbol $code'),
                trailing: currencyCode == code
                    ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  changeCurrency(ref, code);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
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
