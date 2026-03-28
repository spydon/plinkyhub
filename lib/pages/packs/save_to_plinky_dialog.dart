import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
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
  ConsumerState<SaveToPlinkyDialog> createState() =>
      _SaveToPlinkyDialogState();
}

class _SaveToPlinkyDialogState
    extends ConsumerState<SaveToPlinkyDialog> {
  _DialogStep _step = _DialogStep.instructions;
  String _statusMessage = '';
  String? _errorMessage;

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _startSave() async {
    FileSystemDirectoryHandle directory;
    try {
      directory = await html.window.showDirectoryPicker(
        mode: PermissionMode.readwrite,
      );
    } on AbortError {
      return;
    } on Exception {
      return;
    }

    setState(() {
      _step = _DialogStep.progress;
      _statusMessage = 'Fetching patch data...';
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
    final patchIds = <String>{};
    final sampleIds = <String>{};
    for (final slot in slots) {
      if (slot.patchId != null) {
        patchIds.add(slot.patchId!);
      }
      if (slot.sampleId != null) {
        sampleIds.add(slot.sampleId!);
      }
    }

    // Fetch patches from the database.
    setState(() => _statusMessage = 'Fetching patches...');
    final patchDataMap = <String, Uint8List>{};
    if (patchIds.isNotEmpty) {
      final response = await _supabase
          .from('patches')
          .select('id, patch_data')
          .inFilter('id', patchIds.toList());
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        final id = map['id'] as String;
        final patchData = map['patch_data'] as String;
        patchDataMap[id] = Uint8List.fromList(base64Decode(patchData));
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

      final slicePoints = (metadata['slice_points'] as List?)
              ?.map((value) => (value as num).toDouble())
              .toList() ??
          List.of(defaultSlicePoints);
      final sliceNotes = (metadata['slice_notes'] as List?)
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

    // Build the 32 patch entries, remapping P_SAMPLE for each.
    setState(() => _statusMessage = 'Generating PRESETS.UF2...');
    final patches = List<Uint8List?>.filled(presetCount, null);
    for (final slot in slots) {
      if (slot.slotNumber < 0 || slot.slotNumber >= presetCount) {
        continue;
      }
      if (slot.patchId == null) {
        continue;
      }
      final originalPatchBytes = patchDataMap[slot.patchId];
      if (originalPatchBytes == null) {
        continue;
      }

      // Clone the patch bytes so we can modify P_SAMPLE.
      final patchBytes = Uint8List.fromList(originalPatchBytes);

      if (slot.sampleId != null &&
          sampleSlotMapping.containsKey(slot.sampleId)) {
        final firmwareSlot = sampleSlotMapping[slot.sampleId]!;
        setPatchSampleSlot(patchBytes, firmwareSlot);
      }

      patches[slot.slotNumber] = patchBytes;
    }

    // Generate PRESETS.UF2.
    final presetsUf2 = generatePresetsUf2(
      patches: patches,
      sampleInfos: sampleInfos,
    );

    // Write PRESETS.UF2 to the selected directory.
    setState(() => _statusMessage = 'Writing PRESETS.UF2...');
    await _writeFile(directory, 'PRESETS.UF2', presetsUf2);

    // Generate and write SAMPLE*.UF2 files for all 8 slots.
    // Slots with samples get their PCM data; unused slots are cleared
    // with an empty file so previous data doesn't persist.
    for (var slotIndex = 0; slotIndex < sampleCount; slotIndex++) {
      setState(() {
        _statusMessage = 'Writing SAMPLE$slotIndex.UF2...';
      });

      final pcmBytes =
          samplePcmData[slotIndex] ?? Uint8List(0);
      final sampleUf2Bytes = sampleToUf2(
        pcmBytes,
        slotIndex: slotIndex,
      );
      await _writeFile(
        directory,
        'SAMPLE$slotIndex.UF2',
        sampleUf2Bytes,
      );
    }
  }

  Future<void> _writeFile(
    FileSystemDirectoryHandle directory,
    String fileName,
    Uint8List data,
  ) async {
    final fileHandle = await directory.getFileHandle(
      fileName,
      create: true,
    );
    final writable = await fileHandle.createWritable();
    await writable.writeAsArrayBuffer(data);
    await writable.close();
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
          _DialogStep.instructions => _buildInstructions(),
          _DialogStep.progress => _buildProgress(),
          _DialogStep.done => _buildDone(),
          _DialogStep.error => _buildError(),
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

  Widget _buildInstructions() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To save this pack to your Plinky, put it into '
          'Tunnel of Lights mode:',
        ),
        SizedBox(height: 12),
        Text('1. Turn off your Plinky'),
        SizedBox(height: 4),
        Text(
          '2. Hold the rotary encoder while turning the Plinky on',
        ),
        SizedBox(height: 4),
        Text(
          '3. The Plinky will appear as a USB drive '
          'on your computer',
        ),
        SizedBox(height: 12),
        Text(
          'Then click the button below to select the '
          'Plinky drive.',
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(_statusMessage),
      ],
    );
  }

  Widget _buildDone() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 48, color: Colors.green),
        SizedBox(height: 16),
        Text(
          'Pack saved to Plinky successfully! '
          'Eject the drive and restart your Plinky.',
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(_errorMessage ?? 'An unknown error occurred.'),
      ],
    );
  }
}
