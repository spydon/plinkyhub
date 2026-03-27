import 'package:flutter/material.dart';
import 'package:plinkyhub/models/sort_order.dart';
import 'package:plinkyhub/utils/format.dart';

class SortOrderButton extends StatelessWidget {
  const SortOrderButton({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final SortOrder value;
  final ValueChanged<SortOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOrder>(
      icon: const Icon(Icons.sort, size: 20),
      tooltip: 'Sort by',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final order in SortOrder.values)
          PopupMenuItem(
            value: order,
            child: Text(order.name.capitalize),
          ),
      ],
    );
  }
}
