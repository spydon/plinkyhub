import 'package:flutter/material.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/widgets/searchable_picker_dialog.dart';

class PresetPickerDialog extends StatelessWidget {
  const PresetPickerDialog({
    required this.presets,
    this.currentUserId,
    super.key,
  });

  final List<SavedPreset> presets;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return SearchablePickerDialog<SavedPreset>(
      title: 'Pick a preset',
      items: presets,
      currentUserId: currentUserId,
      emptyMessage: 'No saved presets',
      itemSubtitle: (preset) => preset.category,
    );
  }
}
