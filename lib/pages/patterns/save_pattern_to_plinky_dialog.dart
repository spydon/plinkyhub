import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/pages/patterns/providers/saved_patterns_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';
import 'package:plinkyhub/widgets/plinky_transfer_dialog.dart';

class SavePatternToPlinkyDialog extends ConsumerStatefulWidget {
  const SavePatternToPlinkyDialog({required this.pattern, super.key});

  final SavedPattern pattern;

  @override
  ConsumerState<SavePatternToPlinkyDialog> createState() =>
      _SavePatternToPlinkyDialogState();
}

class _SavePatternToPlinkyDialogState
    extends ConsumerState<SavePatternToPlinkyDialog> {
  int _selectedSlot = 0;

  @override
  Widget build(BuildContext context) {
    return PlinkyTransferDialog(
      configuration: PlinkyTransferDialogConfiguration(
        itemType: 'pattern',
        title: 'Save to Plinky',
        setupSteps: [
          PlinkyTransferStep(
            content: (_) => SlotSelectionGrid(
              itemType: 'pattern',
              slotCount: patternCount,
              columns: 3,
              selectedSlot: _selectedSlot,
              onSlotChanged: (slot) => setState(() => _selectedSlot = slot),
              displayOffset: 33,
            ),
          ),
        ],
        onTunnelOfLightsSave: (directory, ref, controller) async {
          controller.updateStatus('Reading existing PRESETS.UF2...');
          final existingUf2 = await readFileFromDirectory(
            directory,
            'PRESETS.UF2',
          );

          List<Uint8List?> presets;
          List<Uint8List?> sampleInfos;
          Uint8List? deviceSysParams;
          Map<int, Uint8List>? userStatePages;

          if (existingUf2 != null) {
            final flashImage = uf2ToData(existingUf2);
            final parsed = parseFlashImage(flashImage);
            presets = parsed.rawPresets;
            sampleInfos = parsed.rawSampleInfos;
            deviceSysParams = extractDeviceSysParams(flashImage);
            userStatePages = parsed.userStatePages;
          } else {
            presets = List<Uint8List?>.filled(presetCount, null);
            sampleInfos = List<Uint8List?>.filled(sampleCount, null);
          }

          controller.updateStatus('Downloading pattern...');
          final patternBlob = await ref
              .read(savedPatternsProvider.notifier)
              .downloadFile(widget.pattern.filePath);

          controller.updateStatus('Preparing pattern data...');
          final quarters = deserializePatternQuarters(patternBlob);

          final patternQuarters = List<Uint8List?>.filled(
            patternCount * 4,
            null,
          );
          final baseIndex = _selectedSlot * 4;
          for (var quarter = 0; quarter < 4; quarter++) {
            if (baseIndex + quarter < patternQuarters.length &&
                baseIndex + quarter < quarters.length) {
              patternQuarters[baseIndex + quarter] =
                  quarters[baseIndex + quarter];
            }
          }

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
