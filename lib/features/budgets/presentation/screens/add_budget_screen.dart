import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget_model.dart';
import '../../providers/budgets_provider.dart';
import '../../../categories/providers/categories_provider.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _amountController = TextEditingController();
  int? _categoryId;
  bool _isOverall = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now().toIso8601String();
    final nowDate = DateTime.now();
    final startDate =
        '${nowDate.year}-${nowDate.month.toString().padLeft(2, '0')}-01';

    final budget = BudgetModel(
      categoryId: _isOverall ? null : _categoryId,
      amount: amount,
      period: 'monthly',
      startDate: startDate,
      createdAt: now,
    );

    ref.read(budgetsProvider.notifier).addBudget(budget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Overall Budget'),
              subtitle: const Text(
                  'Budget for all categories combined'),
              value: _isOverall,
              onChanged: (v) =>
                  setState(() => _isOverall = v),
            ),
            if (!_isOverall) ...[
              const SizedBox(height: 8),
              categoriesAsync.when(
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
                data: (cats) {
                  final expenseCats = cats
                      .where((c) =>
                          c.isExpense && c.parentId == null)
                      .toList();
                  return DropdownButtonFormField<int?>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: expenseCats
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _categoryId = v),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monthly Budget',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: const Text('Save Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
