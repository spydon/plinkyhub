import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/packs/preset_picker_dialog.dart';
import 'package:plinkyhub/pages/packs/sample_picker_dialog.dart';
import 'package:plinkyhub/pages/presets/preset_card.dart';
import 'package:plinkyhub/pages/presets/providers/saved_presets_notifier.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/widgets/linked_item_icon.dart';

enum _SlotMenuAction { edit, pickPreset, pickSample, clear }

class PackSlotTile extends ConsumerWidget {
  const PackSlotTile({
    required this.slotNumber,
    required this.presetId,
    required this.sampleId,
    required this.onPresetChanged,
    required this.onSampleChanged,
    this.devicePreset,
    this.onEditPressed,
    this.isDirty = false,
    this.readOnly = false,
    super.key,
  });

  final int slotNumber;
  final String? presetId;
  final String? sampleId;
  final ValueChanged<String?> onPresetChanged;
  final ValueChanged<String?> onSampleChanged;
  final Preset? devicePreset;
  final VoidCallback? onEditPressed;
  final bool isDirty;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presetsState = ref.watch(savedPresetsProvider);
    final presets = [...presetsState.userItems, ...presetsState.publicItems];
    final samplesState = ref.watch(savedSamplesProvider);
    final samples = [...samplesState.userItems, ...samplesState.publicItems];

    final hasDevicePreset = devicePreset != null;
    final isLinked = presetId != null;

    String presetName;
    if (hasDevicePreset) {
      presetName = devicePreset!.name.isNotEmpty
          ? devicePreset!.name
          : 'Preset ${slotNumber + 1}';
    } else if (isLinked) {
      presetName =
          presets.where((preset) => preset.id == presetId).firstOrNull?.name ??
          '(unknown)';
    } else {
      presetName = 'Empty';
    }

    final sampleName = sampleId != null
        ? samples.where((sample) => sample.id == sampleId).firstOrNull?.name ??
              '(unknown)'
        : null;
    final categoryLabel = devicePreset?.category.label ?? '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: readOnly ? null : () => _showPresetPicker(context, ref, presets),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${slotNumber + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            presetName,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLinked)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: LinkedItemIcon(
                              onTap: () => _showLinkedPreset(context, ref),
                            ),
                          ),
                        if (isDirty)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Tooltip(
                              message: 'Unsaved changes',
                              child: Icon(
                                Icons.edit,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (categoryLabel.isNotEmpty)
                      Text(
                        categoryLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (sampleName != null)
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
              if (!readOnly)
                PopupMenuButton<_SlotMenuAction>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  itemBuilder: (context) => [
                    if (onEditPressed != null)
                      const PopupMenuItem(
                        value: _SlotMenuAction.edit,
                        child: Text('Edit'),
                      ),
                    const PopupMenuItem(
                      value: _SlotMenuAction.pickPreset,
                      child: Text('Pick preset'),
                    ),
                    const PopupMenuItem(
                      value: _SlotMenuAction.pickSample,
                      child: Text('Pick sample'),
                    ),
                    if (presetId != null || sampleId != null)
                      const PopupMenuItem(
                        value: _SlotMenuAction.clear,
                        child: Text('Clear slot'),
                      ),
                  ],
                  onSelected: (action) {
                    switch (action) {
                      case _SlotMenuAction.edit:
                        onEditPressed?.call();
                      case _SlotMenuAction.pickPreset:
                        _showPresetPicker(context, ref, presets);
                      case _SlotMenuAction.pickSample:
                        _showSamplePicker(context, ref, samples);
                      case _SlotMenuAction.clear:
                        onPresetChanged(null);
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

  void _showLinkedPreset(BuildContext context, WidgetRef ref) {
    final presetsState = ref.read(savedPresetsProvider);
    final preset = [
      ...presetsState.userItems,
      ...presetsState.publicItems,
    ].where((preset) => preset.id == presetId).firstOrNull;
    if (preset == null) {
      return;
    }
    final currentUserId = ref.read(authenticationProvider).user?.id;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PresetCard(
              preset: preset,
              isOwned: preset.userId == currentUserId,
            ),
          ),
        ),
      ),
    );
  }

  void _showPresetPicker(
    BuildContext context,
    WidgetRef ref,
    List<SavedPreset> presets,
  ) {
    final currentUserId = ref.read(authenticationProvider).user?.id;
    showDialog<SavedPreset>(
      context: context,
      builder: (context) => PresetPickerDialog(
        presets: presets,
        currentUserId: currentUserId,
      ),
    ).then((selected) {
      if (selected != null) {
        onPresetChanged(selected.id);
        onSampleChanged(selected.sampleId);
      }
    });
  }

  void _showSamplePicker(
    BuildContext context,
    WidgetRef ref,
    List<SavedSample> samples,
  ) {
    final currentUserId = ref.read(authenticationProvider).user?.id;
    showDialog<SavedSample>(
      context: context,
      builder: (context) => SamplePickerDialog(
        samples: samples,
        currentUserId: currentUserId,
      ),
    ).then((selected) {
      if (selected != null) {
        onSampleChanged(selected.id);
      }
    });
  }
}
