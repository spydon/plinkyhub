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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = value != null;
    final color = isActive ? theme.colorScheme.primary : null;
    return PopupMenuButton<LabeledEnum?>(
      tooltip: isActive ? 'Category: ${value!.label}' : 'Filter by category',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => [
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value?.label ?? 'Category',
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
            Icon(Icons.arrow_drop_down, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
