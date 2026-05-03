import 'package:flutter/material.dart';

class CategoryFilterButton extends StatelessWidget {
  const CategoryFilterButton({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Map<String, String> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = value == null ? null : categories[value];
    return PopupMenuButton<String?>(
      icon: Icon(
        Icons.category,
        size: 20,
        color: value != null ? Theme.of(context).colorScheme.primary : null,
      ),
      tooltip: selectedLabel == null
          ? 'Filter by category'
          : 'Category: $selectedLabel',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem<String?>(
          child: Text('All categories'),
        ),
        const PopupMenuDivider(),
        for (final entry in categories.entries)
          PopupMenuItem<String?>(
            value: entry.key,
            child: Text(entry.value),
          ),
      ],
    );
  }
}
