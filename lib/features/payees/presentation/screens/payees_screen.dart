import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../categories/providers/categories_provider.dart';
import '../../data/models/payee_model.dart';
import '../../providers/payees_provider.dart';

class PayeesScreen extends ConsumerStatefulWidget {
  const PayeesScreen({super.key});

  @override
  ConsumerState<PayeesScreen> createState() => _PayeesScreenState();
}

class _PayeesScreenState extends ConsumerState<PayeesScreen> {
  final _searchController = TextEditingController();
  final _addController = TextEditingController();
  int? _selectedCategoryId;
  bool _showAddForm = false;

  @override
  void dispose() {
    _searchController.dispose();
    _addController.dispose();
    super.dispose();
  }

  void _addPayee() {
    final name = _addController.text.trim();
    if (name.isEmpty) return;
    ref.read(payeesProvider.notifier).addPayee(
          PayeeModel(
            name: name,
            defaultCategoryId: _selectedCategoryId,
          ),
        );
    _addController.clear();
    setState(() {
      _showAddForm = false;
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payeesAsync = ref.watch(payeesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payees'),
        actions: [
          IconButton(
            icon: Icon(_showAddForm ? Icons.close : Icons.add),
            onPressed: () =>
                setState(() => _showAddForm = !_showAddForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showAddForm)
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      labelText: 'Payee Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                    data: (cats) {
                      final expenseCats = cats
                          .where((c) => c.isExpense && c.parentId == null)
                          .toList();
                      return DropdownButtonFormField<int?>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Default Category (optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('None'),
                          ),
                          ...expenseCats.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _addPayee,
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search payees...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: payeesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (payees) {
                final query = _searchController.text.toLowerCase();
                final filtered = payees.where((p) {
                  return p.name.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    headline: 'No payees found',
                    description:
                        'Add payees to auto-fill details when recording expenses.',
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final payee = filtered[index];
                    return Dismissible(
                      key: ValueKey(payee.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) =>
                          _confirmDelete(context, payee),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: theme.colorScheme.error,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primaryContainer,
                          child: Text(
                            payee.name[0].toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(payee.name),
                        onTap: () => _editPayee(context, payee),
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

  Future<bool?> _confirmDelete(
      BuildContext context, PayeeModel payee) {
    return ConfirmationDialog.show(
      context,
      title: 'Delete Payee',
      message: 'Delete "${payee.name}"?',
      confirmLabel: 'Delete',
      confirmColor: Theme.of(context).colorScheme.error,
      icon: Icons.delete_outline,
    ).then((confirmed) {
      if (confirmed == true && payee.id != null) {
        ref
            .read(payeesProvider.notifier)
            .deletePayee(payee.id!);
      }
      return false;
    });
  }

  void _editPayee(BuildContext context, PayeeModel payee) {
    final controller = TextEditingController(text: payee.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Payee'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Payee Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && payee.id != null) {
                // Update not implemented in provider yet, so delete + re-add
                ref
                    .read(payeesProvider.notifier)
                    .deletePayee(payee.id!);
                ref.read(payeesProvider.notifier).addPayee(
                      PayeeModel(
                        name: name,
                        defaultCategoryId:
                            payee.defaultCategoryId,
                      ),
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
