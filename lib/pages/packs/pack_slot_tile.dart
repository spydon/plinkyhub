import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/packs/patch_picker_dialog.dart';
import 'package:plinkyhub/pages/packs/sample_picker_dialog.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';

class PackSlotTile extends ConsumerWidget {
  const PackSlotTile({
    required this.slotNumber,
    required this.patchId,
    required this.sampleId,
    required this.onPatchChanged,
    required this.onSampleChanged,
    super.key,
  });

  final int slotNumber;
  final String? patchId;
  final String? sampleId;
  final ValueChanged<String?> onPatchChanged;
  final ValueChanged<String?> onSampleChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final patches = ref.watch(
      savedPatchesProvider.select((state) => state.userPatches),
    );
    final samples = ref.watch(
      savedSamplesProvider.select((state) => state.userSamples),
    );

    final patchName = patchId != null
        ? patches
                  .where((patch) => patch.id == patchId)
                  .firstOrNull
                  ?.name ??
              '(unknown)'
        : 'Empty';
    final sampleName = sampleId != null
        ? samples
                  .where((sample) => sample.id == sampleId)
                  .firstOrNull
                  ?.name ??
              '(unknown)'
        : 'None';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPatchPicker(context, patches),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${slotNumber + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patchName,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sampleName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'patch',
                    child: Text('Pick patch'),
                  ),
                  const PopupMenuItem(
                    value: 'sample',
                    child: Text('Pick sample'),
                  ),
                  if (patchId != null || sampleId != null)
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear slot'),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'patch':
                      _showPatchPicker(context, patches);
                    case 'sample':
                      _showSamplePicker(context, samples);
                    case 'clear':
                      onPatchChanged(null);
                      onSampleChanged(null);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatchPicker(
    BuildContext context,
    List<SavedPatch> patches,
  ) {
    showDialog<String>(
      context: context,
      builder: (context) => PatchPickerDialog(patches: patches),
    ).then((selectedId) {
      if (selectedId != null) {
        onPatchChanged(selectedId);
      }
    });
  }

  void _showSamplePicker(
    BuildContext context,
    List<SavedSample> samples,
  ) {
    showDialog<String>(
      context: context,
      builder: (context) =>
          SamplePickerDialog(samples: samples),
    ).then((selectedId) {
      if (selectedId != null) {
        onSampleChanged(selectedId);
      }
    });
  }
}
