import 'package:flutter/material.dart';
import '../../data/models/tag_model.dart';

class TagChips extends StatelessWidget {
  final List<TagModel> allTags;
  final List<int> selectedTagIds;
  final ValueChanged<int> onToggle;
  final ValueChanged<String> onCreate;

  const TagChips({
    super.key,
    required this.allTags,
    required this.selectedTagIds,
    required this.onToggle,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...allTags.map((tag) {
          final selected = selectedTagIds.contains(tag.id);
          return FilterChip(
            label: Text(tag.name),
            selected: selected,
            selectedColor: theme.colorScheme.primaryContainer,
            onSelected: (v) {
              if (tag.id != null) onToggle(tag.id!);
            },
          );
        }),
        _CreateTagChip(onCreate: onCreate),
      ],
    );
  }
}

class _CreateTagChip extends StatefulWidget {
  final ValueChanged<String> onCreate;
  const _CreateTagChip({required this.onCreate});

  @override
  State<_CreateTagChip> createState() => _CreateTagChipState();
}

class _CreateTagChipState extends State<_CreateTagChip> {
  bool _isCreating = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCreating) {
      return ActionChip(
        avatar: const Icon(Icons.add, size: 16),
        label: const Text('Create tag'),
        onPressed: () => setState(() => _isCreating = true),
      );
    }

    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Tag name',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              autofocus: true,
              onSubmitted: (value) {
                final name = value.trim();
                if (name.isNotEmpty) {
                  widget.onCreate(name);
                  _controller.clear();
                  setState(() => _isCreating = false);
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              final name = _controller.text.trim();
              if (name.isNotEmpty) {
                widget.onCreate(name);
                _controller.clear();
              }
              setState(() => _isCreating = false);
            },
            child: const Icon(Icons.check, size: 18),
          ),
        ],
      ),
    );
  }
}
