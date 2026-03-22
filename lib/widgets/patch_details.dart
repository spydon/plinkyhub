import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/patch.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/widgets/parameter_tile.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/randomize_controls.dart';

class PatchDetails extends ConsumerWidget {
  const PatchDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plinkyProvider);
    final patch = state.patch;

    final isLoading =
        state.connectionState == PlinkyConnectionState.loadingPatch;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (patch == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No patch in browser memory'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This is the patch that has been loaded into '
          'browser memory.',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            PlinkyButton(
              onPressed: () =>
                  ref.read(plinkyProvider.notifier).clearPatch(),
              icon: Icons.delete_outline,
              label: 'Clear patch in browser memory',
            ),
            const SizedBox(width: 8),
            _SaveToCloudButton(patch: patch),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: TextField(
                controller: TextEditingController(
                  text: patch.name,
                ),
                maxLength: 8,
                decoration: const InputDecoration(
                  isDense: true,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(plinkyProvider.notifier).patchName =
                      value;
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<PatchCategory>(
                value: patch.category,
                isDense: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                items: PatchCategory.values.map((category) {
                  return DropdownMenuItem<PatchCategory>(
                    value: category,
                    child: Text(
                      category.label.isEmpty
                          ? '(none)'
                          : category.label,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(plinkyProvider.notifier)
                        .patchCategory = value;
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const RandomizeControls(),
        const SizedBox(height: 16),
        Text(
          'Parameters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Arp: ${patch.arp} | '
          'Latch: ${patch.latch} | '
          'Loop start: ${patch.loopStart} | '
          'Loop length: ${patch.loopLength}',
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const minimumTileWidth = 320.0;
            final columnCount = (constraints.maxWidth /
                    minimumTileWidth)
                .floor()
                .clamp(1, 6);
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: patch.parameters
                  .where(
                    (parameter) =>
                        parameter.name != null &&
                        !parameter.name!.endsWith('_UNUSED'),
                  )
                  .map((parameter) {
                return SizedBox(
                  width:
                      (constraints.maxWidth -
                          (columnCount - 1) * 8) /
                      columnCount,
                  child: ParameterTile(
                    parameter: parameter,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SaveToCloudButton extends ConsumerWidget {
  const _SaveToCloudButton({required this.patch});

  final Patch patch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(authenticationProvider).user != null;

    return PlinkyButton(
      onPressed: isSignedIn
          ? () => _showSaveDialog(context, ref)
          : null,
      icon: Icons.cloud_upload,
      label: isSignedIn ? 'Save to cloud' : 'Sign in to save',
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final descriptionController = TextEditingController();
    var isPublic = false;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Save "${patch.name.isEmpty ? '(unnamed)' : patch.name}" to cloud',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Share publicly'),
                subtitle: const Text(
                  'Allow others to find and load this patch',
                ),
                value: isPublic,
                onChanged: (value) {
                  setDialogState(() => isPublic = value);
                },
              ),
            ],
          ),
          actions: [
            PlinkyButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.close,
              label: 'Cancel',
            ),
            PlinkyButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(savedPatchesProvider.notifier).savePatch(
                      patch,
                      description: descriptionController.text,
                      isPublic: isPublic,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patch saved to cloud')),
                );
              },
              icon: Icons.save,
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }
}
