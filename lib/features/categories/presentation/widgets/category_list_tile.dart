import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../../../core/widgets/category_icon.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int? subcategoryCount;

  const CategoryListTile({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
    this.subcategoryCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryDefaultsX.hexToColor(category.color);

    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete?.call();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: ListTile(
        leading: CategoryIcon(
          iconName: category.icon,
          color: color,
        ),
        title: Text(category.name),
        subtitle: subcategoryCount != null
            ? Text('$subcategoryCount subcategories')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subcategoryCount != null && subcategoryCount! > 0)
              Icon(
                Icons.expand_more,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            if (onTap != null) const SizedBox(width: 4),
            if (onTap != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onTap,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class CategoryDefaultsX {
  static Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
