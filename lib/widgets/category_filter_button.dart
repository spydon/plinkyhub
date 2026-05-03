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
    return PopupMenuButton<LabeledEnum?>(
      icon: Icon(
        Icons.category,
        size: 20,
        color: value != null ? Theme.of(context).colorScheme.primary : null,
      ),
      tooltip: value == null
          ? 'Filter by category'
          : 'Category: ${value!.label}',
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
    );
  }
}
