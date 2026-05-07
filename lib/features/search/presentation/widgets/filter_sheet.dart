import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../accounts/data/models/account_model.dart';

class FilterSheet extends StatefulWidget {
  final String? type;
  final String? dateFrom;
  final String? dateTo;
  final List<int>? categoryIds;
  final List<int>? accountIds;
  final double? minAmount;
  final double? maxAmount;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;

  const FilterSheet({
    super.key,
    this.type,
    this.dateFrom,
    this.dateTo,
    this.categoryIds,
    this.accountIds,
    this.minAmount,
    this.maxAmount,
    required this.categories,
    required this.accounts,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _type;
  late List<int> _categoryIds;
  late List<int> _accountIds;
  late double? _minAmount;
  late double? _maxAmount;
  late DateTime? _dateFrom;
  late DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _categoryIds = widget.categoryIds ?? [];
    _accountIds = widget.accountIds ?? [];
    _minAmount = widget.minAmount;
    _maxAmount = widget.maxAmount;
    _dateFrom =
        widget.dateFrom != null ? DateUtilsX.fromDb(widget.dateFrom!) : null;
    _dateTo =
        widget.dateTo != null ? DateUtilsX.fromDb(widget.dateTo!) : null;
  }

  void _apply() {
    Navigator.pop(context, {
      'type': _type,
      'dateFrom':
          _dateFrom != null ? DateUtilsX.toDb(_dateFrom!) : null,
      'dateTo':
          _dateTo != null ? DateUtilsX.toDb(_dateTo!) : null,
      'categoryIds':
          _categoryIds.isEmpty ? null : _categoryIds,
      'accountIds': _accountIds.isEmpty ? null : _accountIds,
      'minAmount': _minAmount,
      'maxAmount': _maxAmount,
    });
  }

  void _clear() {
    Navigator.pop(context, {'clear': true});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseCats = widget.categories
        .where((c) => c.isExpense && c.parentId == null)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Filters',
                    style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton(
                    onPressed: _clear,
                    child: const Text('Clear All')),
                TextButton(
                    onPressed: _apply,
                    child: const Text('Apply')),
              ],
            ),
            const SizedBox(height: 16),

            // Type
            Text('Type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _type == null,
                  onSelected: (_) =>
                      setState(() => _type = null),
                ),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: _type == 'expense',
                  onSelected: (_) =>
                      setState(() => _type = 'expense'),
                ),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: _type == 'income',
                  onSelected: (_) =>
                      setState(() => _type = 'income'),
                ),
                ChoiceChip(
                  label: const Text('Transfer'),
                  selected: _type == 'transfer',
                  onSelected: (_) =>
                      setState(() => _type = 'transfer'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date range
            Text('Date Range', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _dateFrom ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _dateFrom = date);
                      }
                    },
                    child: Text(
                      _dateFrom != null
                          ? DateUtilsX.display(_dateFrom!)
                          : 'From',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to'),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _dateTo ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _dateTo = date);
                      }
                    },
                    child: Text(
                      _dateTo != null
                          ? DateUtilsX.display(_dateTo!)
                          : 'To',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categories
            Text('Categories',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: expenseCats.map((cat) {
                final selected =
                    _categoryIds.contains(cat.id);
                return FilterChip(
                  label: Text(cat.name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v && cat.id != null) {
                        _categoryIds.add(cat.id!);
                      } else {
                        _categoryIds.remove(cat.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Accounts
            Text('Accounts',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.accounts.map((acc) {
                final selected =
                    _accountIds.contains(acc.id);
                return FilterChip(
                  label: Text(acc.name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v && acc.id != null) {
                        _accountIds.add(acc.id!);
                      } else {
                        _accountIds.remove(acc.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Amount range
            Text('Amount Range',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _minAmount =
                        double.tryParse(v),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—'),
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _maxAmount =
                        double.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
