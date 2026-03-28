import 'package:flutter/material.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PresetPickerDialog extends StatelessWidget {
  const PresetPickerDialog({required this.presets, super.key});

  final List<SavedPreset> presets;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a preset'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: presets.isEmpty
            ? const Center(child: Text('No saved presets'))
            : ListView.builder(
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  return ListTile(
                    title: Text(
                      preset.name.isEmpty
                          ? '(unnamed)'
                          : preset.name,
                    ),
                    subtitle: preset.category.isNotEmpty
                        ? Text(preset.category)
                        : null,
                    onTap: () =>
                        Navigator.of(context).pop(preset.id),
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
