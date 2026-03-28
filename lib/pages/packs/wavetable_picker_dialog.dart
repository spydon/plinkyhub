import 'package:flutter/material.dart';
import 'package:plinkyhub/models/saved_wavetable.dart';
import 'package:plinkyhub/widgets/searchable_picker_dialog.dart';

class WavetablePickerDialog extends StatelessWidget {
  const WavetablePickerDialog({
    required this.wavetables,
    this.currentUserId,
    super.key,
  });

  final List<SavedWavetable> wavetables;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return SearchablePickerDialog<SavedWavetable>(
      title: 'Pick a wavetable',
      items: wavetables,
      currentUserId: currentUserId,
      emptyMessage: 'No saved wavetables',
    );
  }
}
