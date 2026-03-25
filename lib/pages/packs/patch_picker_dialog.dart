import 'package:flutter/material.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PatchPickerDialog extends StatelessWidget {
  const PatchPickerDialog({required this.patches, super.key});

  final List<SavedPatch> patches;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a patch'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: patches.isEmpty
            ? const Center(child: Text('No saved patches'))
            : ListView.builder(
                itemCount: patches.length,
                itemBuilder: (context, index) {
                  final patch = patches[index];
                  return ListTile(
                    title: Text(
                      patch.name.isEmpty
                          ? '(unnamed)'
                          : patch.name,
                    ),
                    subtitle: patch.category.isNotEmpty
                        ? Text(patch.category)
                        : null,
                    onTap: () =>
                        Navigator.of(context).pop(patch.id),
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
