import 'package:flutter/material.dart';
import 'package:plinkyhub/models/labeled_enum.dart';

class CategoryFilterButton extends StatelessWidget {
  const CategoryFilterButton({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<LabeledEnum> categories;
  final LabeledEnum? value;
  final ValueChanged<LabeledEnum?> onChanged;

  Future<void> _showMenu(BuildContext context) async {
    final button = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    final selected = await showMenu<LabeledEnum?>(
      context: context,
      position: position,
      initialValue: value,
      items: [
        const PopupMenuItem<LabeledEnum?>(
          child: Text('All categories'),
        ),
        const PopupMenuDivider(),
        for (final category in categories)
          PopupMenuItem<LabeledEnum?>(
            value: category,
            child: Text(category.label),
          ),
      ],
    );
    if (selected != value) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = value != null;
    return Tooltip(
      message: isActive ? 'Category: ${value!.label}' : 'Filter by category',
      child: TextButton(
        onPressed: () => _showMenu(context),
        style: TextButton.styleFrom(
          foregroundColor: isActive
              ? colorScheme.primary
              : colorScheme.onSurface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value?.label ?? 'Category'),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
