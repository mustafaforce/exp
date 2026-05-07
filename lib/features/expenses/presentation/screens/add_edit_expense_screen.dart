import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/category_defaults.dart';
import '../../../categories/providers/categories_provider.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../../payees/data/models/payee_model.dart';
import '../../../payees/providers/payees_provider.dart';
import '../../../tags/providers/tags_provider.dart';
import '../../../tags/data/models/tag_model.dart';
import '../../../tags/presentation/widgets/tag_chips.dart';
import '../../../splits/presentation/widgets/split_editor.dart';
import '../../../splits/data/models/split_model.dart';
import '../../data/models/expense_model.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  final String initialType;

  const AddEditExpenseScreen({
    super.key,
    this.expense,
    this.initialType = 'expense',
  });

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  late String _type;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  int? _categoryId;
  int? _accountId;
  int? _payeeId;
  final List<int> _selectedTagIds = [];
  bool _isSplit = false;
  List<SplitRowData> _splits = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.expense;
    _type = exp?.type ?? widget.initialType;
    if (exp != null) {
      _amountController.text = exp.amount.toStringAsFixed(2);
      _categoryId = exp.categoryId;
      _accountId = exp.accountId;
      _payeeId = exp.payeeId;
      _noteController.text = exp.note ?? '';
      _selectedDate = DateUtilsX.fromDb(exp.date);
    } else {
      _selectedDate = DateTime.now();
    }
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

    setState(() => _isSaving = true);

    final now = DateTime.now().toIso8601String();
    final expense = ExpenseModel(
      id: widget.expense?.id,
      amount: amount,
      type: _type,
      categoryId: _isSplit ? null : _categoryId,
      accountId: _accountId!,
      payeeId: _payeeId,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: DateUtilsX.toDb(_selectedDate),
      createdAt: widget.expense?.createdAt ?? now,
      updatedAt: now,
    );

    final result = {
      'expense': expense,
      'splits': _isSplit
          ? _splits
              .map((s) => SplitModel(
                    expenseId: 0,
                    categoryId: s.categoryId,
                    amount: s.amount,
                  ))
              .toList()
          : <SplitModel>[],
    };

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.expense != null;
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final payeesAsync = ref.watch(payeesProvider);
    final tagsAsync = ref.watch(tagsProvider);

    final isExpense = _type == 'expense';
    final accentColor = isExpense ? theme.colorScheme.error : const Color(0xFF10B981);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Edit ${_type.capitalize}'
            : 'Add ${_type.capitalize}'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text('Save', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            if (!isEditing)
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
            if (!isEditing) const SizedBox(height: 10),

            // Amount
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: const TextStyle(fontSize: 13),
                prefixText: '${CurrencyFormatter.symbol} ',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: !isEditing,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 10),

            // Split toggle
            Row(
              children: [
                Text('Split', style: theme.textTheme.bodySmall),
                const SizedBox(width: 6),
                SizedBox(
                  height: 24,
                  child: Switch(
                    value: _isSplit,
                    onChanged: (v) => setState(() => _isSplit = v),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Category or Split Editor
            if (_isSplit)
              categoriesAsync.when(
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
                data: (categories) {
                  final filtered = categories
                      .where((c) => c.type == _type && c.parentId == null)
                      .toList();
                  return SplitEditor(
                    categories: filtered,
                    splits: _splits,
                    onChanged: (s) => setState(() => _splits = s),
                    totalAmount: double.tryParse(_amountController.text) ?? 0.0,
                  );
                },
              )
            else ...[
              Text('Category', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              categoriesAsync.when(
                loading: () => const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, _) => Text('Error: $e'),
                data: (categories) {
                  final filtered = categories
                      .where((c) => c.type == _type && c.parentId == null)
                      .toList();
                  return Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: filtered.map((cat) {
                      final selected = _categoryId == cat.id;
                      final color = CategoryDefaults.hexToColor(cat.color);
                      return ChoiceChip(
                        label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                        selected: selected,
                        selectedColor: color.withValues(alpha: 0.15),
                        avatar: Icon(
                          _getIcon(cat.icon),
                          size: 14,
                          color: selected ? color : null,
                        ),
                        onSelected: (v) =>
                            setState(() => _categoryId = v ? cat.id : null),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),

            // Account
            Text('Account', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            accountsAsync.when(
              loading: () => const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (accounts) {
                return Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: accounts.map((acc) {
                    final selected = _accountId == acc.id;
                    return ChoiceChip(
                      label: Text(acc.name, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (v) =>
                          setState(() => _accountId = v ? acc.id : null),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 10),

            // Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(DateUtilsX.displayFull(_selectedDate),
                        style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 16,
                        color: theme.colorScheme.outline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Payee autocomplete
            Text('Payee', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            payeesAsync.when(
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
              data: (payees) {
                return Autocomplete<PayeeModel>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) return [];
                    return payees.where((p) => p.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  displayStringForOption: (p) => p.name,
                  onSelected: (p) => setState(() => _payeeId = p.id),
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search payee...',
                        hintStyle: TextStyle(fontSize: 13),
                      ),
                      style: theme.textTheme.titleMedium,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 260,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final payee = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(payee),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Text(payee.name,
                                      style: theme.textTheme.bodyMedium),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                labelStyle: TextStyle(fontSize: 13),
                hintText: 'Optional description...',
                hintStyle: TextStyle(fontSize: 13),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),

            // Tags
            Text('Tags', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            tagsAsync.when(
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
              data: (tags) {
                return TagChips(
                  allTags: tags,
                  selectedTagIds: _selectedTagIds,
                  onToggle: (id) {
                    setState(() {
                      if (_selectedTagIds.contains(id)) {
                        _selectedTagIds.remove(id);
                      } else {
                        _selectedTagIds.add(id);
                      }
                    });
                  },
                  onCreate: (name) {
                    ref.read(tagsProvider.notifier).addTag(TagModel(name: name));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'movie': return Icons.movie;
      case 'receipt_long': return Icons.receipt_long;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'subscriptions': return Icons.subscriptions;
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'computer': return Icons.computer;
      case 'trending_up': return Icons.trending_up;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'category': return Icons.category;
      default: return Icons.category;
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outline,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Theme.of(context).colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

extension on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
