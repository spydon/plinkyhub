import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';
import 'package:plinkyhub/widgets/plinky_transfer_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavePresetToPlinkyDialog extends ConsumerStatefulWidget {
  const SavePresetToPlinkyDialog({required this.preset, super.key});

  final SavedPreset preset;

  @override
  ConsumerState<SavePresetToPlinkyDialog> createState() =>
      _SavePresetToPlinkyDialogState();
}

class _SavePresetToPlinkyDialogState
    extends ConsumerState<SavePresetToPlinkyDialog> {
  int _selectedSlot = 0;
  int _selectedSampleSlot = 0;

  bool get _hasSample => widget.preset.sampleId != null;

  SavedSample? _findSample(WidgetRef ref) {
    if (widget.preset.sampleId == null) {
      return null;
    }
    final samplesState = ref.read(savedSamplesProvider);
    return samplesState.userItems
            .where((sample) => sample.id == widget.preset.sampleId)
            .firstOrNull ??
        samplesState.publicItems
            .where((sample) => sample.id == widget.preset.sampleId)
            .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return PlinkyTransferDialog(
      configuration: PlinkyTransferDialogConfiguration(
        itemType: 'preset',
        setupSteps: [
          PlinkyTransferStep(
            content: (_) => SlotSelectionGrid(
              itemType: 'preset',
              slotCount: presetCount,
              selectedSlot: _selectedSlot,
              onSlotChanged: (slot) => setState(() => _selectedSlot = slot),
            ),
          ),
          if (_hasSample)
            PlinkyTransferStep(
              content: (_) => _SampleSlotSelectionView(
                selectedSlot: _selectedSampleSlot,
                onSlotChanged: (slot) =>
                    setState(() => _selectedSampleSlot = slot),
              ),
            ),
        ],
        onWebUsbSave: (ref, controller) async {
          final supabase = Supabase.instance.client;
          final notifier = ref.read(plinkyProvider.notifier);

          // Upload sample first if linked.
          final sample = _findSample(ref);
          if (sample != null) {
            controller.updateStatus('Downloading sample data...');
            final pcmBytes = await supabase.storage
                .from('samples')
                .download(sample.pcmFilePath);

            controller.updateStatus('Building sample metadata...');
            final sampleInfo = buildSampleInfo(
              pcmData: pcmBytes,
              slicePoints: sample.slicePoints,
              sliceNotes: sample.sliceNotes,
              pitched: sample.pitched,
            );

            controller.updateStatus('Sending sample to Plinky...');
            await notifier.sendSample(
              slotIndex: _selectedSampleSlot,
              pcmData: pcmBytes,
              sampleInfo: sampleInfo,
              onProgress: (value) {
                if (controller.isMounted) {
                  controller.updateProgress(value * 0.9);
                  final percent = (value * 90).toInt();
                  controller.updateStatus(
                    'Sending sample data... $percent%',
                  );
                }
              },
            );
          }

          controller.updateStatus('Sending preset to Plinky...');
          controller.updateProgress(sample != null ? 0.9 : null);

          final presetData = Uint8List.fromList(
            base64Decode(widget.preset.presetData),
          );

          if (sample != null) {
            setPresetSampleSlot(presetData, _selectedSampleSlot);
          }

          notifier.presetNumber = _selectedSlot;
          notifier.loadPresetFromBytes(presetData);
          await notifier.savePreset();
        },
        onTunnelOfLightsSave: (directory, ref, controller) async {
          final supabase = Supabase.instance.client;

          controller.updateStatus('Reading existing PRESETS.UF2...');
          final existingUf2 = await readFileFromDirectory(
            directory,
            'PRESETS.UF2',
          );

          List<Uint8List?> presets;
          List<Uint8List?> sampleInfos;
          List<Uint8List?>? patternQuarters;
          Uint8List? deviceSysParams;
          Map<int, Uint8List>? userStatePages;

          if (existingUf2 != null) {
            final flashImage = uf2ToData(existingUf2);
            final parsed = parseFlashImage(flashImage);
            presets = parsed.rawPresets;
            sampleInfos = parsed.rawSampleInfos;
            patternQuarters = parsed.patternQuarters;
            deviceSysParams = extractDeviceSysParams(flashImage);
            userStatePages = parsed.userStatePages;
          } else {
            presets = List<Uint8List?>.filled(presetCount, null);
            sampleInfos = List<Uint8List?>.filled(sampleCount, null);
          }

          final presetData = Uint8List.fromList(
            base64Decode(widget.preset.presetData),
          );

          // Upload sample if linked.
          final sample = _findSample(ref);
          if (sample != null) {
            controller.updateStatus('Downloading sample data...');
            final pcmBytes = await supabase.storage
                .from('samples')
                .download(sample.pcmFilePath);

            controller.updateStatus(
              'Generating SAMPLE$_selectedSampleSlot.UF2...',
            );
            final sampleUf2Bytes = sampleToUf2(
              pcmBytes,
              slotIndex: _selectedSampleSlot,
            );

            controller.updateStatus(
              'Writing SAMPLE$_selectedSampleSlot.UF2...',
            );
            await writeFileToDirectory(
              directory,
              'SAMPLE$_selectedSampleSlot.UF2',
              sampleUf2Bytes,
            );

            sampleInfos[_selectedSampleSlot] = buildSampleInfo(
              pcmData: pcmBytes,
              slicePoints: sample.slicePoints,
              sliceNotes: sample.sliceNotes,
              pitched: sample.pitched,
            );

            setPresetSampleSlot(presetData, _selectedSampleSlot);
          }

          presets[_selectedSlot] = presetData;

          controller.updateStatus('Generating PRESETS.UF2...');
          final presetsUf2 = generatePresetsUf2(
            presets: presets,
            sampleInfos: sampleInfos,
            patternQuarters: patternQuarters,
            deviceSysParams: deviceSysParams,
            userStatePages: userStatePages,
          );

          controller.updateStatus('Writing PRESETS.UF2...');
          await writeFileToDirectory(directory, 'PRESETS.UF2', presetsUf2);
        },
      ),
    );
  }
}

class _SampleSlotSelectionView extends StatelessWidget {
  const _SampleSlotSelectionView({
    required this.selectedSlot,
    required this.onSlotChanged,
  });

  final int selectedSlot;
  final ValueChanged<int> onSlotChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This preset uses a sample. Select the sample slot on your Plinky:',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < sampleCount; index++)
              ChoiceChip(
                label: Text('Slot ${index + 1}'),
                selected: selectedSlot == index,
                showCheckmark: false,
                onSelected: (_) => onSlotChanged(index),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'The existing sample in slot ${selectedSlot + 1} will be '
          'overwritten.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
