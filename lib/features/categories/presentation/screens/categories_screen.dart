import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../data/models/category_model.dart';
import '../../providers/categories_provider.dart';
import '../widgets/category_list_tile.dart';
import 'add_edit_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addCategory(context, ref, 'expense'),
          child: const Icon(Icons.add),
        ),
        body: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (categories) {
            return TabBarView(
              children: [
                _CategoryList(
                  categories: categories.where((c) => c.type == 'expense').toList(),
                  ref: ref,
                  type: 'expense',
                ),
                _CategoryList(
                  categories: categories.where((c) => c.type == 'income').toList(),
                  ref: ref,
                  type: 'income',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addCategory(BuildContext context, WidgetRef ref, String type) {
    final topLevel = ref.read(topLevelCategoriesProvider(type));
    Navigator.push(
      context,
      MaterialPageRouter(
        builder: (_) => AddEditCategoryScreen(
          type: type,
          topLevelCategories: topLevel,
        ),
      ),
    ).then((result) {
      if (result is CategoryModel) {
        ref.read(categoriesProvider.notifier).addCategory(result);
      }
    });
  }
}

class _CategoryList extends ConsumerWidget {
  final List<CategoryModel> categories;
  final WidgetRef ref;
  final String type;

  const _CategoryList({
    required this.categories,
    required this.ref,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topLevel = categories.where((c) => c.parentId == null).toList();

    if (topLevel.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        headline: 'No categories yet',
        description: 'Create categories to organize your spending.',
        ctaLabel: 'Add Category',
        onCta: () => _add(context),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: topLevel.length,
        itemBuilder: (context, index) {
          final cat = topLevel[index];
          final subs = categories.where((c) => c.parentId == cat.id).toList();

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: Column(
                  children: [
                    CategoryListTile(
                      category: cat,
                      subcategoryCount: subs.length,
                      onTap: () => _edit(context, cat),
                      onDelete: () => _delete(context, cat),
                    ),
                    if (subs.isNotEmpty)
                      ...subs.map(
                        (sub) => Padding(
                          padding: const EdgeInsets.only(left: 64),
                          child: CategoryListTile(
                            category: sub,
                            onTap: () => _edit(context, sub),
                            onDelete: () => _delete(context, sub),
                          ),
                        ),
                      ),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _add(BuildContext context) {
    final topLevel = ref.read(topLevelCategoriesProvider(type));
    Navigator.push(
      context,
      MaterialPageRouter(
        builder: (_) => AddEditCategoryScreen(
          type: type,
          topLevelCategories: topLevel,
        ),
      ),
    ).then((result) {
      if (result is CategoryModel) {
        ref.read(categoriesProvider.notifier).addCategory(result);
      }
    });
  }

  void _edit(BuildContext context, CategoryModel cat) {
    final topLevel = ref
        .read(topLevelCategoriesProvider(type))
        .where((c) => c.id != cat.id)
        .toList();
    Navigator.push(
      context,
      MaterialPageRouter(
        builder: (_) => AddEditCategoryScreen(
          category: cat,
          type: cat.type,
          topLevelCategories: topLevel,
        ),
      ),
    ).then((result) {
      if (result is CategoryModel) {
        ref.read(categoriesProvider.notifier).updateCategory(result);
      }
    });
  }

  Future<void> _delete(BuildContext context, CategoryModel cat) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Category',
      message: 'Delete "${cat.name}" and all its subcategories?',
      confirmLabel: 'Delete',
      confirmColor: Theme.of(context).colorScheme.error,
      icon: Icons.delete_outline,
    );
    if (confirmed == true && cat.id != null) {
      ref.read(categoriesProvider.notifier).deleteCategory(cat.id!);
    }
  }
}

class MaterialPageRouter extends MaterialPageRoute {
  MaterialPageRouter({required super.builder});
}
