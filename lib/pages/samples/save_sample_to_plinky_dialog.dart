import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';
import 'package:plinkyhub/widgets/plinky_transfer_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveSampleToPlinkyDialog extends ConsumerStatefulWidget {
  const SaveSampleToPlinkyDialog({required this.sample, super.key});

  final SavedSample sample;

  @override
  ConsumerState<SaveSampleToPlinkyDialog> createState() =>
      _SaveSampleToPlinkyDialogState();
}

class _SaveSampleToPlinkyDialogState
    extends ConsumerState<SaveSampleToPlinkyDialog> {
  int _selectedSlot = 0;

  @override
  Widget build(BuildContext context) {
    return PlinkyTransferDialog(
      configuration: PlinkyTransferDialogConfiguration(
        itemType: 'sample',
        setupSteps: [
          PlinkyTransferStep(
            content: (_) => SlotSelectionGrid(
              itemType: 'sample',
              slotCount: sampleCount,
              rows: 2,
              selectedSlot: _selectedSlot,
              onSlotChanged: (slot) => setState(() => _selectedSlot = slot),
            ),
          ),
        ],
        onWebUsbSave: (ref, controller) async {
          final sample = widget.sample;
          final supabase = Supabase.instance.client;

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
          await ref
              .read(plinkyProvider.notifier)
              .sendSample(
                slotIndex: _selectedSlot,
                pcmData: pcmBytes,
                sampleInfo: sampleInfo,
                onProgress: (value) {
                  if (controller.isMounted) {
                    controller.updateProgress(value);
                    final percent = (value * 100).toInt();
                    controller.updateStatus('Sending sample data... $percent%');
                  }
                },
              );
        },
        onTunnelOfLightsSave: (directory, ref, controller) async {
          final sample = widget.sample;
          final supabase = Supabase.instance.client;

          // Read existing PRESETS.UF2 first to preserve other slots. This
          // must happen before any SAMPLE.UF2 write, because writing leaves
          // the Plinky's FAT/USB view of PRESETS.UF2 temporarily corrupted
          // until the device is restarted, causing a "bad magic" parse
          // error on subsequent uploads.
          controller.updateStatus('Reading existing PRESETS.UF2...');
          final existingUf2 = await readFileFromDirectory(
            directory,
            'PRESETS.UF2',
          );

          List<Uint8List?> presets;
          List<Uint8List?> sampleInfos;
          List<Uint8List?>? patternQuarters;
          Uint8List? deviceSysParams;

          if (existingUf2 != null) {
            final flashImage = uf2ToData(existingUf2);
            final parsed = parseFlashImage(flashImage);
            presets = parsed.presets;
            sampleInfos = parsed.rawSampleInfos;
            patternQuarters = parsed.patternQuarters;
            deviceSysParams = extractDeviceSysParams(flashImage);
          } else {
            presets = List<Uint8List?>.filled(presetCount, null);
            sampleInfos = List<Uint8List?>.filled(sampleCount, null);
          }

          controller.updateStatus('Downloading sample PCM data...');
          final pcmBytes = await supabase.storage
              .from('samples')
              .download(sample.pcmFilePath);

          controller.updateStatus(
            'Generating SAMPLE$_selectedSlot.UF2...',
          );
          final sampleUf2Bytes = sampleToUf2(
            pcmBytes,
            slotIndex: _selectedSlot,
          );

          controller.updateStatus(
            'Writing SAMPLE$_selectedSlot.UF2...',
          );
          await writeFileToDirectory(
            directory,
            'SAMPLE$_selectedSlot.UF2',
            sampleUf2Bytes,
          );

          sampleInfos[_selectedSlot] = buildSampleInfo(
            pcmData: pcmBytes,
            slicePoints: sample.slicePoints,
            sliceNotes: sample.sliceNotes,
            pitched: sample.pitched,
          );

          controller.updateStatus('Generating PRESETS.UF2...');
          final presetsUf2 = generatePresetsUf2(
            presets: presets,
            sampleInfos: sampleInfos,
            patternQuarters: patternQuarters,
            deviceSysParams: deviceSysParams,
          );

          controller.updateStatus('Writing PRESETS.UF2...');
          await writeFileToDirectory(directory, 'PRESETS.UF2', presetsUf2);
        },
      ),
    );
  }
}
