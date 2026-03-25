import 'package:flutter/material.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class SamplePickerDialog extends StatelessWidget {
  const SamplePickerDialog({required this.samples, super.key});

  final List<SavedSample> samples;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a sample'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: samples.isEmpty
            ? const Center(child: Text('No saved samples'))
            : ListView.builder(
                itemCount: samples.length,
                itemBuilder: (context, index) {
                  final sample = samples[index];
                  return ListTile(
                    title: Text(
                      sample.name.isEmpty
                          ? '(unnamed)'
                          : sample.name,
                    ),
                    subtitle: sample.description.isNotEmpty
                        ? Text(sample.description)
                        : null,
                    onTap: () =>
                        Navigator.of(context).pop(sample.id),
                  );
                },
              ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.close,
          label: 'Cancel',
        ),
      ],
    );
  }
}
