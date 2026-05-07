import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/data/models/category_model.dart';

class SplitEditor extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<SplitRowData> splits;
  final ValueChanged<List<SplitRowData>> onChanged;
  final double totalAmount;

  const SplitEditor({
    super.key,
    required this.categories,
    required this.splits,
    required this.onChanged,
    required this.totalAmount,
  });

  @override
  State<SplitEditor> createState() => _SplitEditorState();
}

class _SplitEditorState extends State<SplitEditor> {
  void _addSplit() {
    final newSplits = [
      ...widget.splits,
      SplitRowData(
        categoryId: widget.categories.first.id!,
        amount: 0.0,
        controller: TextEditingController(),
      ),
    ];
    widget.onChanged(newSplits);
  }

  void _removeSplit(int index) {
    final newSplits = [...widget.splits];
    newSplits[index].controller.dispose();
    newSplits.removeAt(index);
    widget.onChanged(newSplits);
  }

  void _updateCategory(int index, int categoryId) {
    final newSplits = [...widget.splits];
    newSplits[index].categoryId = categoryId;
    widget.onChanged(newSplits);
  }

  void _updateAmount(int index, String text) {
    final newSplits = [...widget.splits];
    newSplits[index].amount = double.tryParse(text) ?? 0.0;
    widget.onChanged(newSplits);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSplits =
        widget.splits.fold<double>(0.0, (sum, s) => sum + s.amount);
    final isValid =
        (totalSplits - widget.totalAmount).abs() < 0.01;
    final isOver = totalSplits > widget.totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Split Transaction',
                style: theme.textTheme.titleMedium),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: _addSplit,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Split'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.splits.asMap().entries.map((entry) {
          final index = entry.key;
          final split = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    initialValue: split.categoryId,
                    isDense: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: widget.categories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) _updateCategory(index, v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: split.controller,
                    decoration: InputDecoration(
                      prefixText: CurrencyFormatter.symbol,
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => _updateAmount(index, v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      size: 20, color: Colors.red),
                  onPressed: () => _removeSplit(index),
                ),
              ],
            ),
          );
        }),
        const Divider(),
        Row(
          children: [
            const Text('Total: ',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${CurrencyFormatter.symbol}${totalSplits.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isOver
                    ? theme.colorScheme.error
                    : isValid
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
              ),
            ),
            if (!isValid)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '/ ${CurrencyFormatter.symbol}${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            if (isValid)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle,
                    size: 18, color: Colors.green),
              ),
          ],
        ),
      ],
    );
  }
}

class SplitRowData {
  int categoryId;
  double amount;
  TextEditingController controller;

  SplitRowData({
    required this.categoryId,
    required this.amount,
    required this.controller,
  });
}
