// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _DialogStep { confirm, progress, done, error }

class SaveMyPlinkyDialog extends ConsumerStatefulWidget {
  const SaveMyPlinkyDialog({
    required this.directory,
    required this.slots,
    required this.patternIds,
    required this.wavetableId,
    required this.parsedFlashImage,
    this.onSaved,
    super.key,
  });

  final FileSystemDirectoryHandle directory;
  final List<({String? presetId, String? sampleId, String? patternId})> slots;
  final Map<int, String?> patternIds;
  final String? wavetableId;
  final ParsedFlashImage parsedFlashImage;
  final VoidCallback? onSaved;

  @override
  ConsumerState<SaveMyPlinkyDialog> createState() => _SaveMyPlinkyDialogState();
}

class _SaveMyPlinkyDialogState extends ConsumerState<SaveMyPlinkyDialog> {
  _DialogStep _step = _DialogStep.confirm;
  String _statusMessage = '';
  double? _progress;
  String? _errorMessage;

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _startSave() async {
    setState(() {
      _step = _DialogStep.progress;
      _statusMessage = 'Preparing...';
    });

    try {
      await _generateAndWriteFiles();
      widget.onSaved?.call();
      setState(() => _step = _DialogStep.done);
    } on Exception catch (error) {
      setState(() {
        _step = _DialogStep.error;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _generateAndWriteFiles() async {
    final existing = widget.parsedFlashImage;

    // Start with existing device data.
    final presets = List<Uint8List?>.of(existing.rawPresets);
    final sampleInfos = List<Uint8List?>.of(existing.rawSampleInfos);
    final patternQuarters = List<Uint8List?>.of(existing.patternQuarters);

    // Collect linked preset and sample IDs.
    final linkedPresetIds = <String>{};
    final linkedSampleIds = <String>{};
    for (final slot in widget.slots) {
      if (slot.presetId != null) {
        linkedPresetIds.add(slot.presetId!);
      }
      if (slot.sampleId != null) {
        linkedSampleIds.add(slot.sampleId!);
      }
    }

    // Count unique samples for progress tracking.
    final uniqueSampleIds = <String>{};
    for (var i = 0; i < 32; i++) {
      final sampleId = widget.slots[i].sampleId;
      if (sampleId != null) {
        uniqueSampleIds.add(sampleId);
      }
    }
    // Steps: fetch presets(1) + fetch sample metadata(1)
    // + download samples(uniqueSamples) + generate presets(1)
    // + fetch patterns(1) + write presets(1) + write samples(8)
    // + write wavetable(1 if linked).
    final totalSteps =
        5 +
        uniqueSampleIds.length +
        sampleCount +
        (widget.wavetableId != null ? 1 : 0);
    var completedSteps = 0;

    void updateProgress(String message) {
      completedSteps++;
      setState(() {
        _statusMessage = message;
        _progress = completedSteps / totalSteps;
      });
    }

    // Fetch linked presets from DB.
    final presetDataMap = <String, Uint8List>{};
    if (linkedPresetIds.isNotEmpty) {
      updateProgress('Fetching presets...');
      final rows = await _supabase
          .table(Presets.table)
          .selectOnly([Presets.id, Presets.presetData])
          .where(Presets.id.inFilter(linkedPresetIds.toList()));
      for (final row in rows) {
        presetDataMap[row.read(Presets.id)] = Uint8List.fromList(
          base64Decode(row.read(Presets.presetData)),
        );
      }
    } else {
      completedSteps++;
    }

    // Fetch sample metadata.
    final sampleMetadataMap = <String, PostgrestPartialRow<SamplesRow>>{};
    if (linkedSampleIds.isNotEmpty) {
      updateProgress('Fetching sample metadata...');
      final rows = await _supabase
          .table(Samples.table)
          .selectOnly([
            Samples.id,
            Samples.pcmFilePath,
            Samples.slicePoints,
            Samples.sliceNotes,
            Samples.pitched,
            Samples.baseNote,
            Samples.fineTune,
            Samples.loopMode,
          ])
          .where(Samples.id.inFilter(linkedSampleIds.toList()));
      for (final row in rows) {
        sampleMetadataMap[row.read(Samples.id)] = row;
      }
    } else {
      completedSteps++;
    }

    // Build sample slot mapping from linked samples in preset slots.
    final sampleSlotMapping = <String, int>{};
    final seenSampleIds = <String>{};
    var nextSampleSlot = 0;
    for (var i = 0; i < 32; i++) {
      final sampleId = widget.slots[i].sampleId;
      if (sampleId != null && seenSampleIds.add(sampleId)) {
        sampleSlotMapping[sampleId] = nextSampleSlot;
        nextSampleSlot++;
      }
    }

    // Download sample PCM and build SampleInfo structs.
    final samplePcmData = <int, Uint8List>{};
    var sampleDownloadNumber = 0;
    for (final entry in sampleSlotMapping.entries) {
      final sampleId = entry.key;
      final slotIndex = entry.value;
      final metadata = sampleMetadataMap[sampleId];
      if (metadata == null) {
        completedSteps++;
        continue;
      }

      sampleDownloadNumber++;
      updateProgress(
        'Downloading sample $sampleDownloadNumber/${sampleSlotMapping.length}...',
      );

      final pcmBytes = await _supabase.storage
          .from('samples')
          .download(metadata.read(Samples.pcmFilePath));

      samplePcmData[slotIndex] = pcmBytes;

      sampleInfos[slotIndex] = buildSampleInfo(
        pcmData: pcmBytes,
        slicePoints: metadata.read(Samples.slicePoints),
        sliceNotes: metadata.read(Samples.sliceNotes),
        pitched: metadata.read(Samples.pitched),
        loopMode: metadata.read(Samples.loopMode),
      );
    }

    // Overwrite linked preset slots with saved preset data.
    updateProgress('Generating PRESETS.UF2...');
    for (var i = 0; i < 32; i++) {
      final presetId = widget.slots[i].presetId;
      if (presetId == null) {
        continue;
      }
      final originalPresetBytes = presetDataMap[presetId];
      if (originalPresetBytes == null) {
        continue;
      }

      final presetBytes = Uint8List.fromList(originalPresetBytes);
      final preset = Preset(presetBytes.buffer);
      if (preset.usesSample) {
        final sampleId = widget.slots[i].sampleId;
        if (sampleId != null) {
          final firmwareSlot = sampleSlotMapping[sampleId];
          if (firmwareSlot != null) {
            setPresetSampleSlot(presetBytes, firmwareSlot);
          }
        }
      }

      presets[i] = presetBytes;
    }

    // Overwrite linked pattern quarters.
    final linkedPatternIds = widget.patternIds.entries
        .where((entry) => entry.value != null)
        .toList();
    if (linkedPatternIds.isNotEmpty) {
      updateProgress('Fetching patterns...');
      for (final entry in linkedPatternIds) {
        final patternIndex = entry.key;
        final patternId = entry.value!;
        final patternFilePath = await _fetchPatternFilePath(patternId);
        final patternBlob = await _supabase.storage
            .from('patterns')
            .download(patternFilePath);
        final quarters = deserializePatternQuarters(patternBlob);
        final baseIndex = patternIndex * 4;
        for (var q = 0; q < 4; q++) {
          if (baseIndex + q < patternQuarters.length &&
              baseIndex + q < quarters.length) {
            patternQuarters[baseIndex + q] = quarters[baseIndex + q];
          }
        }
      }
    } else {
      completedSteps++;
    }

    // Generate and write PRESETS.UF2.
    final presetsUf2 = generatePresetsUf2(
      presets: presets,
      sampleInfos: sampleInfos,
      patternQuarters: patternQuarters,
      userStatePages: existing.userStatePages,
    );

    updateProgress('Writing PRESETS.UF2...');
    await writeFileToDirectory(
      widget.directory,
      'PRESETS.UF2',
      presetsUf2,
    );

    // Write SAMPLE*.UF2 files for all 8 slots.
    for (var slotIndex = 0; slotIndex < sampleCount; slotIndex++) {
      updateProgress('Writing SAMPLE$slotIndex.UF2...');

      final pcmBytes = samplePcmData[slotIndex] ?? Uint8List(0);
      final sampleUf2Bytes = sampleToUf2(
        pcmBytes,
        slotIndex: slotIndex,
      );
      await writeFileToDirectory(
        widget.directory,
        'SAMPLE$slotIndex.UF2',
        sampleUf2Bytes,
      );
    }

    // Write WAVETAB.UF2 if linked.
    if (widget.wavetableId != null) {
      updateProgress('Writing WAVETAB.UF2...');
      final wavetableFilePath = await _fetchWavetableFilePath(
        widget.wavetableId!,
      );
      final wavetableBytes = await _supabase.storage
          .from('wavetables')
          .download(wavetableFilePath);
      await writeFileToDirectory(
        widget.directory,
        'WAVETAB.UF2',
        wavetableBytes,
      );
    }
  }

  Future<String> _fetchPatternFilePath(String id) async {
    final row = await _supabase
        .table(Patterns.table)
        .selectOnly([Patterns.filePath])
        .where(Patterns.id.eq(id))
        .single();
    return row.read(Patterns.filePath);
  }

  Future<String> _fetchWavetableFilePath(String id) async {
    final row = await _supabase
        .table(Wavetables.table)
        .selectOnly([Wavetables.filePath])
        .where(Wavetables.id.eq(id))
        .single();
    return row.read(Wavetables.filePath);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: switch (_step) {
        _DialogStep.confirm => const Text('Save to Plinky'),
        _DialogStep.progress => const Text('Uploading to Plinky...'),
        _DialogStep.done => Row(
          children: [
            const Text('Done'),
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        _DialogStep.error => const Text('Error'),
      },
      content: SizedBox(
        width: 400,
        child: switch (_step) {
          _DialogStep.confirm => const Text(
            'This will write your linked presets, samples, patterns, '
            'and wavetable to the connected Plinky. '
            'Unlinked slots will be preserved as-is.',
          ),
          _DialogStep.progress => SaveProgressView(
            statusMessage: _statusMessage,
            progress: _progress,
          ),
          _DialogStep.done => const SaveDoneView(itemType: 'changes'),
          _DialogStep.error => SaveErrorView(errorMessage: _errorMessage),
        },
      ),
      actions: switch (_step) {
        _DialogStep.confirm => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancel',
          ),
          PlinkyButton(
            onPressed: _startSave,
            icon: Icons.save,
            label: 'Save',
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
