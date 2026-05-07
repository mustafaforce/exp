import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/category_model.dart';
import '../widgets/icon_picker.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  final String type;
  final List<CategoryModel> topLevelCategories;

  const AddEditCategoryScreen({
    super.key,
    this.category,
    required this.type,
    required this.topLevelCategories,
  });

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _nameController = TextEditingController();
  String _selectedIcon = 'category';
  String _selectedColor = '#94A3B8';
  int? _parentId;
  bool _isSaving = false;

  static const _colors = [
    '#FF6B6B', '#4ECDC4', '#A78BFA', '#FBBF24',
    '#60A5FA', '#34D399', '#F97316', '#EC4899',
    '#84CC16', '#8B5CF6', '#06B6D4', '#94A3B8',
    '#10B981', '#3B82F6', '#EF4444', '#F59E0B',
  ];

  Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    if (cat != null) {
      _nameController.text = cat.name;
      _selectedIcon = cat.icon;
      _selectedColor = cat.color;
      _parentId = cat.parentId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    final now = DateTime.now().toIso8601String();
    final category = CategoryModel(
      id: widget.category?.id,
      name: name,
      icon: _selectedIcon,
      color: _selectedColor,
      parentId: _parentId,
      type: widget.type,
      sortOrder: widget.category?.sortOrder ?? 0,
      createdAt: widget.category?.createdAt ?? now,
    );

    Navigator.pop(context, category);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
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
                labelText: 'Category Name',
                hintText: 'e.g. Groceries',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: !isEditing,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            const SizedBox(height: 24),
            Text('Icon', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            IconPicker(
              selectedIcon: _selectedIcon,
              onSelected: (icon) => setState(() => _selectedIcon = icon),
            ),
            const SizedBox(height: 24),
            Text('Color', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((hex) {
                final isSelected = hex == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseHex(hex),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.onSurface, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            if (!isEditing) ...[
              const SizedBox(height: 24),
              Text('Parent Category (optional)', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _parentId,
                decoration: const InputDecoration(
                  hintText: 'None (top-level)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None (top-level)'),
                  ),
                  ...widget.topLevelCategories.map(
                    (cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _parentId = v),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
