import 'package:flutter/material.dart';
import 'package:plinkyhub/models/saved_pattern.dart';
import 'package:plinkyhub/widgets/searchable_picker_dialog.dart';

class PatternPickerDialog extends StatelessWidget {
  const PatternPickerDialog({
    required this.patterns,
    this.currentUserId,
    super.key,
  });

  final List<SavedPattern> patterns;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return SearchablePickerDialog<SavedPattern>(
      title: 'Pick a pattern',
      items: patterns,
      currentUserId: currentUserId,
      emptyMessage: 'No saved patterns',
    );
  }
}
