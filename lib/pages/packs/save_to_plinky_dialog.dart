import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_transfer_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveToPlinkyDialog extends ConsumerWidget {
  const SaveToPlinkyDialog({
    required this.pack,
    this.clearEmpty = true,
    super.key,
  });

  final SavedPack pack;

  /// When true (default), unselected slots are cleared on the device. When
  /// false, only the explicitly selected slots are written and the rest are
  /// preserved.
  final bool clearEmpty;

  bool get _hasPatterns => pack.slots.any((slot) => slot.patternId != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlinkyTransferDialog(
      configuration: PlinkyTransferDialogConfiguration(
        itemType: 'pack',
        title: 'Save to Plinky',
        webUsbNote: _hasPatterns
            ? 'Note: Patterns cannot be transferred over WebUSB '
                  'and will be skipped.'
            : null,
        onWebUsbSave: (ref, controller) => _sendPackOverWebUsb(
          pack: pack,
          ref: ref,
          controller: controller,
          clearEmpty: clearEmpty,
        ),
        onTunnelOfLightsSave: (directory, ref, controller) =>
            _generateAndWriteFiles(
              pack: pack,
              directory: directory,
              controller: controller,
              clearEmpty: clearEmpty,
            ),
      ),
    );
  }
}

Future<void> _sendPackOverWebUsb({
  required SavedPack pack,
  required WidgetRef ref,
  required PlinkyTransferController controller,
  required bool clearEmpty,
}) async {
  final supabase = Supabase.instance.client;
  final notifier = ref.read(plinkyProvider.notifier);
  final slots = pack.slots;

  // Collect unique IDs.
  final presetIds = <String>{};
  final sampleIds = <String>{};
  for (final slot in slots) {
    if (slot.presetId != null) {
      presetIds.add(slot.presetId!);
    }
    if (slot.sampleId != null) {
      sampleIds.add(slot.sampleId!);
    }
  }

  // Fetch preset binary data.
  controller.updateStatus('Fetching presets...');
  final presetDataMap = <String, Uint8List>{};
  if (presetIds.isNotEmpty) {
    final response = await supabase
        .from('presets')
        .select('id, preset_data')
        .inFilter('id', presetIds.toList());
    for (final row in response as List) {
      final map = row as Map<String, dynamic>;
      presetDataMap[map['id'] as String] = Uint8List.fromList(
        base64Decode(map['preset_data'] as String),
      );
    }
  }

  // Fetch sample metadata.
  controller.updateStatus('Fetching sample metadata...');
  final sampleMetadataMap = <String, Map<String, dynamic>>{};
  if (sampleIds.isNotEmpty) {
    final response = await supabase
        .from('samples')
        .select('id, pcm_file_path, slice_points, slice_notes, pitched')
        .inFilter('id', sampleIds.toList());
    for (final row in response as List) {
      final map = row as Map<String, dynamic>;
      sampleMetadataMap[map['id'] as String] = map;
    }
  }

  // Build sample slot mapping (pack slots 56-63 → Plinky 0-7).
  final sampleSlotMapping = <String, int>{};
  for (final slot in slots) {
    if (slot.sampleId != null && slot.slotNumber >= sampleSlotStart) {
      sampleSlotMapping[slot.sampleId!] = slot.slotNumber - sampleSlotStart;
    }
  }
  final filledSampleSlots = sampleSlotMapping.values.toSet();
  final emptySampleSlots = clearEmpty
      ? [
          for (var i = 0; i < sampleCount; i++) i,
        ].where((slot) => !filledSampleSlots.contains(slot)).toList()
      : const <int>[];

  // Build the set of preset slot indices that have a selection.
  final filledPresetSlots = <int, String>{};
  for (final slot in slots) {
    if (slot.slotNumber >= presetSlotStart &&
        slot.slotNumber < patternSlotStart &&
        slot.presetId != null) {
      filledPresetSlots[slot.slotNumber - presetSlotStart] = slot.presetId!;
    }
  }
  final emptyPresetIndices = clearEmpty
      ? [
          for (var i = 0; i < presetCount; i++) i,
        ].where((index) => !filledPresetSlots.containsKey(index)).toList()
      : const <int>[];

  // Count total work items for progress.
  final totalSamples = sampleSlotMapping.length + emptySampleSlots.length;
  final totalPresets = filledPresetSlots.length + emptyPresetIndices.length;
  final wavetableSteps = pack.wavetableId != null ? 1 : 0;
  final totalSteps = totalSamples + totalPresets + wavetableSteps;
  var completedSteps = 0;

  // Upload samples via WebUSB (cmd=3 for PCM, cmd=1 for SampleInfo).
  var sampleNumber = 0;
  for (final entry in sampleSlotMapping.entries) {
    final metadata = sampleMetadataMap[entry.key];
    if (metadata == null) {
      continue;
    }

    sampleNumber++;
    final slotIndex = entry.value;
    controller.updateStatus(
      'Downloading sample $sampleNumber/$totalSamples...',
    );

    final pcmBytes = await supabase.storage
        .from('samples')
        .download(metadata['pcm_file_path'] as String);

    final slicePoints =
        (metadata['slice_points'] as List?)
            ?.map((value) => (value as num).toDouble())
            .toList() ??
        List.of(defaultSlicePoints);
    final sliceNotes =
        (metadata['slice_notes'] as List?)
            ?.map((value) => (value as num).toInt())
            .toList() ??
        List.of(defaultSliceNotes);
    final pitched = metadata['pitched'] as bool? ?? false;

    final sampleInfo = buildSampleInfo(
      pcmData: pcmBytes,
      slicePoints: slicePoints,
      sliceNotes: sliceNotes,
      pitched: pitched,
    );

    controller.updateStatus(
      'Sending sample $sampleNumber/$totalSamples...',
    );

    await notifier.sendSample(
      slotIndex: slotIndex,
      pcmData: pcmBytes,
      sampleInfo: sampleInfo,
      onProgress: (value) {
        if (controller.isMounted) {
          controller.updateProgress((completedSteps + value) / totalSteps);
          final percent = (value * 100).toInt();
          controller.updateStatus(
            'Sending sample $sampleNumber/$totalSamples... $percent%',
          );
        }
      },
    );

    completedSteps++;
  }

  // Clear unselected sample slots when requested.
  for (final slotIndex in emptySampleSlots) {
    sampleNumber++;
    controller.updateStatus(
      'Clearing sample $sampleNumber/$totalSamples...',
    );
    await notifier.sendSample(
      slotIndex: slotIndex,
      pcmData: Uint8List(0),
      sampleInfo: Uint8List(sampleInfoSize),
      onProgress: (value) {
        if (controller.isMounted) {
          controller.updateProgress((completedSteps + value) / totalSteps);
        }
      },
    );
    completedSteps++;
  }

  // Upload wavetable via WebUSB (cmd=5). Wavetable is global state, not a
  // numbered slot, so the clearEmpty toggle doesn't apply to it: we only
  // overwrite when one is explicitly selected.
  if (pack.wavetableId != null) {
    controller.updateStatus('Sending wavetable...');

    final wavetableFilePath = await _fetchFilePath(
      supabase,
      'wavetables',
      pack.wavetableId!,
    );
    final uf2Bytes = await supabase.storage
        .from('wavetables')
        .download(wavetableFilePath);
    final wavetableData = uf2ToData(uf2Bytes);

    await notifier.sendWavetable(wavetableData: wavetableData);
    completedSteps++;
  }

  // Upload presets via WebUSB (cmd=1 for each preset slot).
  var presetCounter = 0;
  for (final entry in filledPresetSlots.entries) {
    final presetIndex = entry.key;
    final presetId = entry.value;
    final originalBytes = presetDataMap[presetId];
    if (originalBytes == null) {
      continue;
    }

    final presetBytes = Uint8List.fromList(originalBytes);

    // Remap P_SAMPLE to the device slot.
    final preset = Preset(presetBytes.buffer);
    if (preset.usesSample) {
      final presetRaw = preset.parameterById('P_SAMPLE')?.value;
      if (presetRaw != null && presetRaw != 0) {
        final originalSlot = rawToSampleSlot(presetRaw);
        for (final mappingEntry in sampleSlotMapping.entries) {
          if (mappingEntry.value == originalSlot) {
            setPresetSampleSlot(presetBytes, mappingEntry.value);
            break;
          }
        }
      }
    }

    presetCounter++;
    controller.updateStatus(
      'Sending preset $presetCounter/$totalPresets '
      '(slot ${presetIndex + 1})...',
    );

    notifier.presetNumber = presetIndex;
    notifier.loadPresetFromBytes(presetBytes);
    await notifier.savePreset();

    completedSteps++;
    controller.updateProgress(completedSteps / totalSteps);
  }

  // Clear unselected preset slots when requested.
  for (final presetIndex in emptyPresetIndices) {
    presetCounter++;
    controller.updateStatus(
      'Clearing preset $presetCounter/$totalPresets '
      '(slot ${presetIndex + 1})...',
    );
    notifier.presetNumber = presetIndex;
    notifier.loadPresetFromBytes(Uint8List(presetSize));
    await notifier.savePreset();
    completedSteps++;
    controller.updateProgress(completedSteps / totalSteps);
  }
}

Future<void> _generateAndWriteFiles({
  required SavedPack pack,
  required FileSystemDirectoryHandle directory,
  required PlinkyTransferController controller,
  required bool clearEmpty,
}) async {
  final supabase = Supabase.instance.client;
  final slots = pack.slots;

  // Collect unique IDs from the pack slots by range.
  final presetIds = <String>{};
  final sampleIds = <String>{};
  for (final slot in slots) {
    if (slot.presetId != null) {
      presetIds.add(slot.presetId!);
    }
    if (slot.sampleId != null) {
      sampleIds.add(slot.sampleId!);
    }
  }

  // Build sample slot mapping early so we can count total steps.
  final sampleSlotMapping = <String, int>{};
  for (final slot in slots) {
    if (slot.sampleId != null && slot.slotNumber >= sampleSlotStart) {
      sampleSlotMapping[slot.sampleId!] = slot.slotNumber - sampleSlotStart;
    }
  }
  if (sampleSlotMapping.length > sampleCount) {
    throw Exception(
      'Pack has ${sampleSlotMapping.length} samples, '
      'but Plinky only supports $sampleCount.',
    );
  }

  final patternSlots = slots
      .where(
        (slot) =>
            slot.patternId != null &&
            slot.slotNumber >= patternSlotStart &&
            slot.slotNumber < sampleSlotStart,
      )
      .toList();
  final hasWavetable = pack.wavetableId != null;
  final sampleFilesToWrite = clearEmpty
      ? sampleCount
      : sampleSlotMapping.length;
  final wavetableFilesToWrite = hasWavetable ? 1 : 0;

  final totalSteps =
      1 +
      2 +
      sampleSlotMapping.length +
      (patternSlots.isNotEmpty ? 1 : 0) +
      1 +
      sampleFilesToWrite +
      wavetableFilesToWrite;
  var completedSteps = 0;

  void reportProgress(String message) {
    controller.updateStatus(message);
    controller.updateProgress(completedSteps / totalSteps);
  }

  // Read existing PRESETS.UF2 to preserve the user's device state.
  reportProgress('Reading existing PRESETS.UF2...');
  final existingUf2 = await readFileFromDirectory(directory, 'PRESETS.UF2');
  Uint8List? deviceSysParams;
  Map<int, Uint8List>? userStatePages;
  if (existingUf2 != null) {
    final flashImage = uf2ToData(existingUf2);
    final parsed = parseFlashImage(flashImage);
    deviceSysParams = extractDeviceSysParams(flashImage);
    userStatePages = parsed.userStatePages;
  }
  completedSteps++;

  // Fetch presets from the database.
  reportProgress('Fetching presets...');
  final presetDataMap = <String, Uint8List>{};
  if (presetIds.isNotEmpty) {
    final response = await supabase
        .from('presets')
        .select('id, preset_data')
        .inFilter('id', presetIds.toList());
    for (final row in response as List) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String;
      final presetData = map['preset_data'] as String;
      presetDataMap[id] = Uint8List.fromList(base64Decode(presetData));
    }
  }
  completedSteps++;

  // Fetch sample metadata from the database.
  reportProgress('Fetching sample metadata...');
  final sampleMetadataMap = <String, Map<String, dynamic>>{};
  if (sampleIds.isNotEmpty) {
    final response = await supabase
        .from('samples')
        .select(
          'id, pcm_file_path, slice_points, slice_notes, '
          'pitched, base_note, fine_tune',
        )
        .inFilter('id', sampleIds.toList());
    for (final row in response as List) {
      final map = row as Map<String, dynamic>;
      sampleMetadataMap[map['id'] as String] = map;
    }
  }
  completedSteps++;

  // Download sample PCM files and build SampleInfo structs.
  final sampleInfos = List<Uint8List?>.filled(sampleCount, null);
  final samplePcmData = <int, Uint8List>{};
  var tunnelSampleNumber = 0;
  for (final entry in sampleSlotMapping.entries) {
    final sampleId = entry.key;
    final slotIndex = entry.value;
    final metadata = sampleMetadataMap[sampleId];
    if (metadata == null) {
      completedSteps++;
      continue;
    }

    tunnelSampleNumber++;
    reportProgress(
      'Downloading sample $tunnelSampleNumber/${sampleSlotMapping.length}...',
    );

    final pcmFilePath = metadata['pcm_file_path'] as String;
    final pcmBytes = await supabase.storage
        .from('samples')
        .download(pcmFilePath);

    samplePcmData[slotIndex] = pcmBytes;

    final slicePoints =
        (metadata['slice_points'] as List?)
            ?.map((value) => (value as num).toDouble())
            .toList() ??
        List.of(defaultSlicePoints);
    final sliceNotes =
        (metadata['slice_notes'] as List?)
            ?.map((value) => (value as num).toInt())
            .toList() ??
        List.of(defaultSliceNotes);
    final pitched = metadata['pitched'] as bool? ?? false;

    sampleInfos[slotIndex] = buildSampleInfo(
      pcmData: pcmBytes,
      slicePoints: slicePoints,
      sliceNotes: sliceNotes,
      pitched: pitched,
    );
    completedSteps++;
  }

  // Build the 32 preset entries, remapping P_SAMPLE for each.
  final presets = List<Uint8List?>.filled(presetCount, null);
  for (final slot in slots) {
    if (slot.slotNumber < presetSlotStart ||
        slot.slotNumber >= patternSlotStart) {
      continue;
    }
    if (slot.presetId == null) {
      continue;
    }
    final originalPresetBytes = presetDataMap[slot.presetId];
    if (originalPresetBytes == null) {
      continue;
    }

    final presetBytes = Uint8List.fromList(originalPresetBytes);

    final preset = Preset(presetBytes.buffer);
    if (preset.usesSample) {
      final presetRaw = preset.parameterById('P_SAMPLE')?.value;
      if (presetRaw != null && presetRaw != 0) {
        final originalSlot = rawToSampleSlot(presetRaw);
        for (final entry in sampleSlotMapping.entries) {
          if (entry.value == originalSlot) {
            setPresetSampleSlot(presetBytes, entry.value);
            break;
          }
        }
      }
    }

    presets[slot.slotNumber - presetSlotStart] = presetBytes;
  }

  // Fetch pattern quarter data from slots (32-55).
  List<Uint8List?>? patternQuarters;
  if (patternSlots.isNotEmpty) {
    reportProgress('Fetching patterns...');
    patternQuarters = List<Uint8List?>.filled(patternCount * 4, null);
    for (final slot in patternSlots) {
      final patternFilePath = await _fetchFilePath(
        supabase,
        'patterns',
        slot.patternId!,
      );
      final patternBlob = await supabase.storage
          .from('patterns')
          .download(patternFilePath);
      final quarters = deserializePatternQuarters(patternBlob);
      final patternIndex = slot.slotNumber - patternSlotStart;
      final baseIndex = patternIndex * 4;
      for (var quarter = 0; quarter < 4; quarter++) {
        if (baseIndex + quarter < patternQuarters.length &&
            baseIndex + quarter < quarters.length) {
          patternQuarters[baseIndex + quarter] = quarters[baseIndex + quarter];
        }
      }
    }
    completedSteps++;
  }

  // Generate PRESETS.UF2. With clearEmpty=false and nothing in the preset
  // region selected (e.g. wavetable-only upload), the UF2 has zero blocks
  // and we skip writing it so the bootloader doesn't see an empty file.
  reportProgress('Generating PRESETS.UF2...');
  final presetsUf2 = generatePresetsUf2(
    presets: presets,
    sampleInfos: sampleInfos,
    patternQuarters: patternQuarters,
    clearEmpty: clearEmpty,
    deviceSysParams: deviceSysParams,
    userStatePages: userStatePages,
  );

  if (presetsUf2.isNotEmpty) {
    reportProgress('Writing PRESETS.UF2...');
    await writeFileToDirectory(directory, 'PRESETS.UF2', presetsUf2);
  }
  completedSteps++;

  // Generate and write SAMPLE*.UF2 files. When clearEmpty is true, write all
  // 8 (with empty PCM for unfilled slots so they are erased on the device).
  // Otherwise, only write files for slots that have data so unselected slots
  // are preserved on the device.
  for (var slotIndex = 0; slotIndex < sampleCount; slotIndex++) {
    final hasSample = samplePcmData.containsKey(slotIndex);
    if (!hasSample && !clearEmpty) {
      continue;
    }
    final pcmBytes = samplePcmData[slotIndex] ?? Uint8List(0);
    final sampleUf2Bytes = sampleToUf2(pcmBytes, slotIndex: slotIndex);
    controller.updateStatus('Writing SAMPLE$slotIndex.UF2...');
    controller.updateProgress(completedSteps / totalSteps);
    await writeFileToDirectory(
      directory,
      'SAMPLE$slotIndex.UF2',
      sampleUf2Bytes,
      onProgress: (writeProgress) {
        controller.updateProgress(
          (completedSteps + writeProgress) / totalSteps,
        );
        final percent = (writeProgress * 100).toInt();
        controller.updateStatus('Writing SAMPLE$slotIndex.UF2... $percent%');
      },
      onFinalize: () =>
          controller.updateStatus('Finalizing SAMPLE$slotIndex.UF2...'),
    );
    completedSteps++;
  }

  // Write WAVETAB.UF2 if the pack has one. Wavetable is global state, not a
  // numbered slot, so the clearEmpty toggle doesn't apply to it.
  if (hasWavetable) {
    reportProgress('Writing WAVETAB.UF2...');

    final wavetableFilePath = await _fetchFilePath(
      supabase,
      'wavetables',
      pack.wavetableId!,
    );
    final wavetableBytes = await supabase.storage
        .from('wavetables')
        .download(wavetableFilePath);
    await writeFileToDirectory(directory, 'WAVETAB.UF2', wavetableBytes);
    completedSteps++;
  }
}

Future<String> _fetchFilePath(
  SupabaseClient supabase,
  String table,
  String id,
) async {
  final response = await supabase
      .from(table)
      .select('file_path')
      .eq('id', id)
      .single();
  return response['file_path'] as String;
}
