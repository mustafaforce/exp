import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/providers/categories_provider.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../data/models/recurring_model.dart';
import '../../providers/recurring_provider.dart';
import '../widgets/frequency_picker.dart';

class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  bool _showAddForm = false;

  final _amountController = TextEditingController();
  String _type = 'expense';
  int? _categoryId;
  int? _accountId;
  String _frequency = 'monthly';
  late DateTime _startDate;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0 || _accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter amount and select account'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final recurring = RecurringModel(
      amount: amount,
      type: _type,
      categoryId: _categoryId,
      accountId: _accountId!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      frequency: _frequency,
      nextDate: DateUtilsX.toDb(_startDate),
      isActive: true,
      createdAt: now,
    );

    ref.read(recurringProvider.notifier).addRecurring(recurring);
    _clearForm();
  }

  void _clearForm() {
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _showAddForm = false;
      _categoryId = null;
      _accountId = null;
      _frequency = 'monthly';
      _startDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recurringAsync = ref.watch(recurringProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring'),
        actions: [
          IconButton(
            icon: Icon(_showAddForm ? Icons.close : Icons.add, size: 20),
            onPressed: () => setState(() => _showAddForm = !_showAddForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showAddForm)
            Container(
              padding: const EdgeInsets.all(10),
              color: theme.colorScheme.surfaceContainerHighest,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypeChip(
                          label: 'Expense',
                          selected: _type == 'expense',
                          color: theme.colorScheme.error,
                          onTap: () => setState(() => _type = 'expense'),
                        ),
                        const SizedBox(width: 6),
                        _TypeChip(
                          label: 'Income',
                          selected: _type == 'income',
                          color: const Color(0xFF10B981),
                          onTap: () => setState(() => _type = 'income'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: const TextStyle(fontSize: 13),
                        prefixText: '${CurrencyFormatter.symbol} ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                      data: (cats) {
                        final filtered = cats
                            .where((c) => c.type == _type && c.parentId == null)
                            .toList();
                        return DropdownButtonFormField<int?>(
                          initialValue: _categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(fontSize: 13),
                          ),
                          items: filtered
                              .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) => setState(() => _categoryId = v),
                          isDense: true,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    accountsAsync.when(
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                      data: (accs) {
                        return DropdownButtonFormField<int?>(
                          initialValue: _accountId,
                          decoration: const InputDecoration(
                            labelText: 'Account',
                            labelStyle: TextStyle(fontSize: 13),
                          ),
                          items: accs
                              .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) => setState(() => _accountId = v),
                          isDense: true,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('Frequency', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    FrequencyPicker(
                      selected: _frequency,
                      onSelected: (f) => setState(() => _frequency = f),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text('Start: ${DateUtilsX.display(_startDate)}',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        labelStyle: TextStyle(fontSize: 13),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: recurringAsync.when(
              loading: () => const Center(
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (recurrings) {
                if (recurrings.isEmpty && !_showAddForm) {
                  return EmptyState(
                    icon: Icons.repeat_outlined,
                    headline: 'No recurring transactions',
                    description: 'Automate bills and subscriptions.',
                    ctaLabel: 'Add Recurring',
                    onCta: () => setState(() => _showAddForm = true),
                  );
                }

                return ListView.builder(
                  itemCount: recurrings.length,
                  itemBuilder: (context, index) {
                    final r = recurrings[index];
                    return Dismissible(
                      key: ValueKey(r.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context, r),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: theme.colorScheme.error,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: r.isActive
                                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                  : theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                r.type == 'expense'
                                    ? Icons.trending_down
                                    : Icons.trending_up,
                                size: 14,
                                color: r.isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${r.type == 'expense' ? '-' : '+'}${CurrencyFormatter.symbol}${r.amount.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: r.isActive ? null : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${FrequencyPicker.display(r.frequency)} · ${r.note ?? 'No note'}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateUtilsX.display(DateTime.parse(r.nextDate)),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(
                              height: 28,
                              child: Switch(
                                value: r.isActive,
                                onChanged: (v) {
                                  if (r.id != null) {
                                    ref.read(recurringProvider.notifier)
                                        .toggleActive(r.id!, v);
                                  }
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, RecurringModel r) {
    return ConfirmationDialog.show(
      context,
      title: 'Delete Recurring',
      message: 'Delete this recurring transaction?',
      confirmLabel: 'Delete',
      confirmColor: Theme.of(context).colorScheme.error,
      icon: Icons.delete_outline,
    ).then((confirmed) {
      if (confirmed == true && r.id != null) {
        ref.read(recurringProvider.notifier).deleteRecurring(r.id!);
      }
      return false;
    });
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outline,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? color : null,
          fontWeight: selected ? FontWeight.w600 : null,
          fontSize: 12,
        )),
      ),
    );
  }
}
