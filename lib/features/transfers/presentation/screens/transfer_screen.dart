import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../expenses/providers/expenses_provider.dart';
import '../widgets/account_selector.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _amountController = TextEditingController();
  AccountModel? _fromAccount;
  AccountModel? _toAccount;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (_fromAccount == null || _toAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both accounts')),
      );
      return;
    }
    if (_fromAccount!.id == _toAccount!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accounts must be different')),
      );
      return;
    }

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
    final date = DateUtilsX.toDb(DateTime.now());

    final transferExpense = ExpenseModel(
      amount: amount,
      type: 'transfer',
      accountId: _fromAccount!.id!,
      toAccountId: _toAccount!.id!,
      note: 'Transfer to ${_toAccount!.name}',
      date: date,
      createdAt: now,
      updatedAt: now,
    );

    ref.read(expensesProvider.notifier).addExpense(transferExpense);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountSelector(
                  label: 'From',
                  selectedAccount: _fromAccount,
                  accounts: accounts,
                  onSelected: (acc) =>
                      setState(() => _fromAccount = acc),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Icon(
                        Icons.arrow_downward,
                        size: 32,
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.5 + (value * 0.5)),
                      );
                    },
                    onEnd: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: 16),
                AccountSelector(
                  label: 'To',
                  selectedAccount: _toAccount,
                  accounts: accounts,
                  onSelected: (acc) =>
                      setState(() => _toAccount = acc),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${CurrencyFormatter.symbol} ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  autofocus: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(
                        _isSaving ? 'Transferring...' : 'Transfer'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
