import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/category_repository.dart';
import '../data/models/category_model.dart';

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

final filteredCategoriesProvider = Provider.family<List<CategoryModel>, String>(
  (ref, type) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    return categories.where((c) => c.type == type).toList();
  },
);

final topLevelCategoriesProvider = Provider.family<List<CategoryModel>, String>(
  (ref, type) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    return categories
        .where((c) => c.type == type && c.parentId == null)
        .toList();
  },
);

final subCategoriesProvider = Provider.family<List<CategoryModel>, int>(
  (ref, parentId) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    return categories.where((c) => c.parentId == parentId).toList();
  },
);

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    final repo = ref.read(categoryRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addCategory(CategoryModel category) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.insert(category);
    ref.invalidateSelf();
  }

  Future<void> updateCategory(CategoryModel category) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.update(category);
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(int id) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
