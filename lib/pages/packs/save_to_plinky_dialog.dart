import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _DialogStep {
  instructions,
  progress,
  done,
  error,
}

class SaveToPlinkyDialog extends ConsumerStatefulWidget {
  const SaveToPlinkyDialog({required this.pack, super.key});

  final SavedPack pack;

  @override
  ConsumerState<SaveToPlinkyDialog> createState() => _SaveToPlinkyDialogState();
}

class _SaveToPlinkyDialogState extends ConsumerState<SaveToPlinkyDialog> {
  _DialogStep _step = _DialogStep.instructions;
  String _statusMessage = '';
  String? _errorMessage;

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _startSave() async {
    final directory = await showDirectoryPicker(readwrite: true);
    if (directory == null) {
      return;
    }

    setState(() {
      _step = _DialogStep.progress;
      _statusMessage = 'Fetching preset data...';
    });

    try {
      await _generateAndWriteFiles(directory);
      setState(() => _step = _DialogStep.done);
    } on Exception catch (error) {
      setState(() {
        _step = _DialogStep.error;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _generateAndWriteFiles(
    FileSystemDirectoryHandle directory,
  ) async {
    final slots = widget.pack.slots;

    // Collect unique patch IDs and sample IDs from the pack.
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

    // Fetch presets from the database.
    setState(() => _statusMessage = 'Fetching presets...');
    final presetDataMap = <String, Uint8List>{};
    if (presetIds.isNotEmpty) {
      final response = await _supabase
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

    // Fetch sample metadata from the database.
    setState(() => _statusMessage = 'Fetching sample metadata...');
    final sampleMetadataMap = <String, Map<String, dynamic>>{};
    if (sampleIds.isNotEmpty) {
      final response = await _supabase
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

    // Assign unique samples to Plinky sample slots (0-7).
    final uniqueSampleIds = sampleIds.toList();
    if (uniqueSampleIds.length > sampleCount) {
      throw Exception(
        'Pack has ${uniqueSampleIds.length} samples, '
        'but Plinky only supports $sampleCount.',
      );
    }
    // Map from database sample ID → Plinky slot index (0-7).
    final sampleSlotMapping = <String, int>{};
    for (var i = 0; i < uniqueSampleIds.length; i++) {
      sampleSlotMapping[uniqueSampleIds[i]] = i;
    }

    // Download sample PCM files and build SampleInfo structs.
    final sampleInfos = List<Uint8List?>.filled(sampleCount, null);
    final samplePcmData = <int, Uint8List>{};
    for (final entry in sampleSlotMapping.entries) {
      final sampleId = entry.key;
      final slotIndex = entry.value;
      final metadata = sampleMetadataMap[sampleId];
      if (metadata == null) {
        continue;
      }

      setState(() {
        _statusMessage =
            'Downloading sample ${slotIndex + 1}/${uniqueSampleIds.length}...';
      });

      final pcmFilePath = metadata['pcm_file_path'] as String;
      final pcmBytes = await _supabase.storage
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
    }

    // Build the 32 preset entries, remapping P_SAMPLE for each.
    setState(() => _statusMessage = 'Generating PRESETS.UF2...');
    final presets = List<Uint8List?>.filled(presetCount, null);
    for (final slot in slots) {
      if (slot.slotNumber < 0 || slot.slotNumber >= presetCount) {
        continue;
      }
      if (slot.presetId == null) {
        continue;
      }
      final originalPresetBytes = presetDataMap[slot.presetId];
      if (originalPresetBytes == null) {
        continue;
      }

      // Clone the preset bytes so we can modify P_SAMPLE.
      final presetBytes = Uint8List.fromList(originalPresetBytes);

      if (slot.sampleId != null &&
          sampleSlotMapping.containsKey(slot.sampleId)) {
        final firmwareSlot = sampleSlotMapping[slot.sampleId]!;
        setPresetSampleSlot(presetBytes, firmwareSlot);
      }

      presets[slot.slotNumber] = presetBytes;
    }

    // Fetch pattern quarter data if the pack has patterns.
    List<Uint8List?>? patternQuarters;
    if (widget.pack.patternId != null) {
      setState(() => _statusMessage = 'Fetching patterns...');
      final patternFilePath = await _fetchFilePath(
        'patterns',
        widget.pack.patternId!,
      );
      final patternBlob = await _supabase.storage
          .from('patterns')
          .download(patternFilePath);
      patternQuarters = deserializePatternQuarters(patternBlob);
    }

    // Generate PRESETS.UF2 (includes presets, samples, and patterns).
    final presetsUf2 = generatePresetsUf2(
      presets: presets,
      sampleInfos: sampleInfos,
      patternQuarters: patternQuarters,
    );

    // Write PRESETS.UF2 to the selected directory.
    setState(() => _statusMessage = 'Writing PRESETS.UF2...');
    await writeFileToDirectory(directory, 'PRESETS.UF2', presetsUf2);

    // Generate and write SAMPLE*.UF2 files for all 8 slots.
    // Slots with samples get their PCM data; unused slots are cleared
    // with an empty file so previous data doesn't persist.
    for (var slotIndex = 0; slotIndex < sampleCount; slotIndex++) {
      setState(() {
        _statusMessage = 'Writing SAMPLE$slotIndex.UF2...';
      });

      final pcmBytes = samplePcmData[slotIndex] ?? Uint8List(0);
      final sampleUf2Bytes = sampleToUf2(
        pcmBytes,
        slotIndex: slotIndex,
      );
      await writeFileToDirectory(
        directory,
        'SAMPLE$slotIndex.UF2',
        sampleUf2Bytes,
      );
    }

    // Write WAVETABLE.UF2 if the pack has one.
    if (widget.pack.wavetableId != null) {
      setState(() {
        _statusMessage = 'Writing WAVETABLE.UF2...';
      });

      final wavetableFilePath = await _fetchFilePath(
        'wavetables',
        widget.pack.wavetableId!,
      );
      final wavetableBytes = await _supabase.storage
          .from('wavetables')
          .download(wavetableFilePath);
      await writeFileToDirectory(
        directory,
        'WAVETABLE.UF2',
        wavetableBytes,
      );
    }

  }

  Future<String> _fetchFilePath(
    String table,
    String id,
  ) async {
    final response = await _supabase
        .from(table)
        .select('file_path')
        .eq('id', id)
        .single();
    return response['file_path'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        switch (_step) {
          _DialogStep.instructions => 'Save to Plinky',
          _DialogStep.progress => 'Saving...',
          _DialogStep.done => 'Done',
          _DialogStep.error => 'Error',
        },
      ),
      content: SizedBox(
        width: 400,
        child: switch (_step) {
          _DialogStep.instructions => const TunnelOfLightsInstructions(
            itemType: 'pack',
          ),
          _DialogStep.progress => SaveProgressView(
            statusMessage: _statusMessage,
          ),
          _DialogStep.done => const SaveDoneView(itemType: 'pack'),
          _DialogStep.error => SaveErrorView(errorMessage: _errorMessage),
        },
      ),
      actions: switch (_step) {
        _DialogStep.instructions => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancel',
          ),
          PlinkyButton(
            onPressed: _startSave,
            icon: Icons.folder_open,
            label: 'Select Plinky drive',
          ),
        ],
        _DialogStep.progress => [],
        _DialogStep.done || _DialogStep.error => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Close',
          ),
        ],
      },
    );
  }
}
