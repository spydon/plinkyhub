import 'package:flutter/material.dart';

class CategoryFilterButton extends StatelessWidget {
  const CategoryFilterButton({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<String> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      icon: Icon(
        Icons.filter_list,
        size: 20,
        color: value != null ? Theme.of(context).colorScheme.primary : null,
      ),
      tooltip: value == null ? 'Filter by category' : 'Category: $value',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem<String?>(
          child: Text('All categories'),
        ),
        const PopupMenuDivider(),
        for (final category in categories)
          PopupMenuItem<String?>(
            value: category,
            child: Text(category),
          ),
      ],
    );
  }
}
