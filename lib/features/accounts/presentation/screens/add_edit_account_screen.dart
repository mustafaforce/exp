import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/account_model.dart';

class AddEditAccountScreen extends StatefulWidget {
  final AccountModel? account;

  const AddEditAccountScreen({super.key, this.account});

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'cash';
  String _currency = 'USD';
  bool _isSaving = false;

  static const _types = ['cash', 'bank', 'credit_card', 'savings', 'investment'];
  static const _currencies = ['USD', 'BDT', 'EUR', 'GBP', 'JPY', 'PKR', 'INR'];

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    if (acc != null) {
      _nameController.text = acc.name;
      _balanceController.text = acc.balance.toStringAsFixed(2);
      _type = acc.type;
      _currency = acc.currency ?? 'USD';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    final balance = double.tryParse(balanceText) ?? 0.0;
    final now = DateTime.now().toIso8601String();
    final account = AccountModel(
      id: widget.account?.id,
      name: name,
      type: _type,
      balance: balance,
      currency: _currency,
      isActive: true,
      createdAt: widget.account?.createdAt ?? now,
    );

    Navigator.pop(context, account);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Account' : 'Add Account'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. Wallet, Bank Account',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: !isEditing,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              decoration: InputDecoration(
                labelText: 'Initial Balance',
                prefixText: _currency == 'USD' ? '\$ ' : _currency == 'BDT' ? '৳ ' : '$_currency ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
              items: _types.map((t) {
                String label;
                switch (t) {
                  case 'cash':
                    label = 'Cash';
                    break;
                  case 'bank':
                    label = 'Bank';
                    break;
                  case 'credit_card':
                    label = 'Credit Card';
                    break;
                  case 'savings':
                    label = 'Savings';
                    break;
                  case 'investment':
                    label = 'Investment';
                    break;
                  default:
                    label = t;
                }
                return DropdownMenuItem(value: t, child: Text(label));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _currency = v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
