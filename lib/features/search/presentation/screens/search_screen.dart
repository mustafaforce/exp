import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../categories/providers/categories_provider.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../../expenses/presentation/widgets/transaction_tile.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../expenses/data/repositories/expense_repository.dart';
import '../../../expenses/presentation/screens/add_edit_expense_screen.dart';
import '../../../expenses/providers/expenses_provider.dart';
import '../../providers/search_provider.dart';
import '../widgets/filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchFiltersProvider.notifier).setQuery(value);
    });
  }

  void _openFilterSheet() async {
    final categories = ref.read(categoriesProvider).valueOrNull ?? [];
    final accounts = ref.read(accountsProvider).valueOrNull ?? [];
    final filters = ref.read(searchFiltersProvider);

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FilterSheet(
        type: filters.type,
        dateFrom: filters.dateFrom,
        dateTo: filters.dateTo,
        categoryIds: filters.categoryIds,
        accountIds: filters.accountIds,
        minAmount: filters.minAmount,
        maxAmount: filters.maxAmount,
        categories: categories,
        accounts: accounts,
      ),
    );

    if (result == null) return;
    if (result['clear'] == true) {
      ref.read(searchFiltersProvider.notifier).clear();
      return;
    }

    final notifier = ref.read(searchFiltersProvider.notifier);
    notifier.setType(result['type'] as String?);
    notifier.setDateRange(
        result['dateFrom'] as String?, result['dateTo'] as String?);
    notifier.setCategoryIds(result['categoryIds'] as List<int>?);
    notifier.setAccountIds(result['accountIds'] as List<int>?);
    notifier.setAmountRange(
        result['minAmount'] as double?, result['maxAmount'] as double?);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchResultsProvider);
    final filters = ref.watch(searchFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.activeFilterCount > 0,
              label: Text('${filters.activeFilterCount}',
                  style: const TextStyle(fontSize: 9)),
              child: const Icon(Icons.filter_list, size: 20),
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 4),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchFiltersProvider.notifier).setQuery(null);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.sort, size: 16),
                          onPressed: () {
                            ref.read(searchFiltersProvider.notifier).toggleSortAsc();
                          },
                        ),
                  filled: true,
                ),
                onChanged: _onSearchChanged,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),

          // Active filters
          if (filters.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: [
                  if (filters.type != null)
                    _SmallChip(
                      label: filters.type!,
                      onDelete: () =>
                          ref.read(searchFiltersProvider.notifier).setType(null),
                    ),
                  if (filters.dateFrom != null)
                    _SmallChip(
                      label: 'From ${filters.dateFrom}',
                      onDelete: () {
                        ref.read(searchFiltersProvider.notifier)
                            .setDateRange(null, filters.dateTo);
                      },
                    ),
                  if (filters.dateTo != null)
                    _SmallChip(
                      label: 'To ${filters.dateTo}',
                      onDelete: () {
                        ref.read(searchFiltersProvider.notifier)
                            .setDateRange(filters.dateFrom, null);
                      },
                    ),
                  _SmallChip(
                    label: '${filters.sortBy} ${filters.sortAsc ? '↑' : '↓'}',
                    onDelete: () =>
                        ref.read(searchFiltersProvider.notifier).clear(),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (results) {
                if (results.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    headline: 'No matches',
                    description: 'Try adjusting filters or search terms.',
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 250),
                        child: SlideAnimation(
                          verticalOffset: 20,
                          child: FadeInAnimation(
                            child: TransactionTile(
                              expense: item,
                              onTap: () => _editTransaction(item),
                              onLongPress: () => _deleteTransaction(item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editTransaction(ExpenseWithDetails item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(expense: item.expense),
      ),
    ).then((result) {
      if (result is Map && result['expense'] is ExpenseModel) {
        ref.read(expensesProvider.notifier)
            .updateExpense(item.expense, result['expense'] as ExpenseModel);
      } else if (result is ExpenseModel) {
        ref.read(expensesProvider.notifier).updateExpense(item.expense, result);
      }
    });
  }

  Future<void> _deleteTransaction(ExpenseWithDetails item) async {
    if (item.expense.id != null) {
      ref.read(expensesProvider.notifier).deleteExpense(item.expense.id!);
    }
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _SmallChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      deleteIcon: const Icon(Icons.close, size: 12),
      onDeleted: onDelete,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
