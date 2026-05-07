import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/data/repositories/expense_repository.dart';

class SearchFilters {
  String? query;
  String? dateFrom;
  String? dateTo;
  List<int>? categoryIds;
  List<int>? accountIds;
  double? minAmount;
  double? maxAmount;
  String? type;
  String sortBy;
  bool sortAsc;

  SearchFilters({
    this.query,
    this.dateFrom,
    this.dateTo,
    this.categoryIds,
    this.accountIds,
    this.minAmount,
    this.maxAmount,
    this.type,
    this.sortBy = 'date',
    this.sortAsc = false,
  });

  SearchFilters copy() => SearchFilters(
        query: query,
        dateFrom: dateFrom,
        dateTo: dateTo,
        categoryIds: categoryIds != null ? List.from(categoryIds!) : null,
        accountIds: accountIds != null ? List.from(accountIds!) : null,
        minAmount: minAmount,
        maxAmount: maxAmount,
        type: type,
        sortBy: sortBy,
        sortAsc: sortAsc,
      );

  bool get hasActiveFilters =>
      query != null ||
      dateFrom != null ||
      dateTo != null ||
      categoryIds != null ||
      accountIds != null ||
      minAmount != null ||
      maxAmount != null ||
      type != null;

  int get activeFilterCount {
    int count = 0;
    if (query != null) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (categoryIds != null) count++;
    if (accountIds != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (type != null) count++;
    return count;
  }

  String get orderBy {
    switch (sortBy) {
      case 'amount':
        return 'e.amount ${sortAsc ? 'ASC' : 'DESC'}';
      case 'category':
        return 'c.name ${sortAsc ? 'ASC' : 'DESC'}';
      default:
        return 'e.date ${sortAsc ? 'ASC' : 'DESC'}';
    }
  }
}

final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersNotifier, SearchFilters>(
  (ref) => SearchFiltersNotifier(),
);

class SearchFiltersNotifier extends StateNotifier<SearchFilters> {
  SearchFiltersNotifier() : super(SearchFilters());

  void setQuery(String? q) =>
      state.query = (q != null && q.isNotEmpty) ? q : null;
  void setDateRange(String? from, String? to) {
    state.dateFrom = from;
    state.dateTo = to;
  }
  void setCategoryIds(List<int>? ids) => state.categoryIds = ids;
  void setAccountIds(List<int>? ids) => state.accountIds = ids;
  void setAmountRange(double? min, double? max) {
    state.minAmount = min;
    state.maxAmount = max;
  }
  void setType(String? type) => state.type = type;
  void setSortBy(String sortBy) => state.sortBy = sortBy;
  void toggleSortAsc() => state.sortAsc = !state.sortAsc;
  void clear() => state = SearchFilters();
}

final searchResultsProvider =
    FutureProvider<List<ExpenseWithDetails>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final repo = ref.read(expenseRepositoryProvider);

  return repo.getAll(
    type: filters.type,
    dateFrom: filters.dateFrom,
    dateTo: filters.dateTo,
    searchQuery: filters.query,
    orderBy: filters.orderBy,
  );
});
