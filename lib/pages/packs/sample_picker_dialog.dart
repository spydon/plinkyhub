import 'package:flutter/material.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/widgets/searchable_picker_dialog.dart';

class SamplePickerDialog extends StatelessWidget {
  const SamplePickerDialog({
    required this.samples,
    this.currentUserId,
    super.key,
  });

  final List<SavedSample> samples;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return SearchablePickerDialog<SavedSample>(
      title: 'Pick a sample',
      items: samples,
      currentUserId: currentUserId,
      emptyMessage: 'No saved samples',
    );
  }
}
