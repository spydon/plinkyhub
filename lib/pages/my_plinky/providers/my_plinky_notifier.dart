import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/matched_entry.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/my_plinky/models/my_plinky_state.dart';
import 'package:plinkyhub/utils/constants.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/plinky_device_parser.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final myPlinkyProvider = NotifierProvider<MyPlinkyNotifier, MyPlinkyState>(
  MyPlinkyNotifier.new,
);

class MyPlinkyNotifier extends Notifier<MyPlinkyState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  MyPlinkyState build() => const MyPlinkyState();

  void reset() {
    state = const MyPlinkyState();
  }

  void setIncludeSamples({required bool value}) {
    state = state.copyWith(includeSamples: value);
  }

  void updateSlotPreset(int slotIndex, String? presetId) {
    final updatedSlots = List<LinkedSlot>.of(state.slots);
    updatedSlots[slotIndex] = (
      presetId: presetId,
      sampleId: updatedSlots[slotIndex].sampleId,
      patternId: updatedSlots[slotIndex].patternId,
    );
    state = state.copyWith(
      slots: updatedSlots,
      dirtySlots: {...state.dirtySlots, slotIndex},
    );
  }

  void updateSlotSample(int slotIndex, String? sampleId) {
    final updatedSlots = List<LinkedSlot>.of(state.slots);
    updatedSlots[slotIndex] = (
      presetId: updatedSlots[slotIndex].presetId,
      sampleId: sampleId,
      patternId: updatedSlots[slotIndex].patternId,
    );
    state = state.copyWith(
      slots: updatedSlots,
      dirtySlots: {...state.dirtySlots, slotIndex},
    );
  }

  void updatePattern(int patternIndex, String? patternId) {
    final updatedPatternIds = Map<int, String?>.of(state.patternIds);
    updatedPatternIds[patternIndex] = patternId;
    state = state.copyWith(
      patternIds: updatedPatternIds,
      dirtyPatterns: {...state.dirtyPatterns, patternIndex},
    );
  }

  void updateWavetable(String? wavetableId) {
    state = state.copyWith(
      wavetableId: () => wavetableId,
      dirtyWavetable: true,
    );
  }

  void setEditingSlotIndex(int? slotIndex) {
    state = state.copyWith(editingSlotIndex: () => slotIndex);
  }

  void updatePresetFromEditor(int slotIndex, Preset preset) {
    final updatedPresets = Map<int, Preset>.of(state.devicePresets);
    updatedPresets[slotIndex] = preset;
    state = state.copyWith(
      devicePresets: updatedPresets,
      dirtySlots: {...state.dirtySlots, slotIndex},
      editingSlotIndex: () => null,
    );
  }

  void clearDirtyState() {
    state = state.copyWith(
      dirtySlots: const {},
      dirtyWavetable: false,
      dirtyPatterns: const {},
    );
  }

  Future<void> connectToPlinky() async {
    final directory = await showDirectoryPicker(readwrite: true);
    if (directory == null) {
      return;
    }

    final includeSamples = state.includeSamples;
    final sampleSteps = includeSamples ? sampleCount : 0;
    final totalSteps = sampleSteps + 6;
    var completedSteps = 0;

    void updateProgress(String message) {
      completedSteps++;
      state = state.copyWith(
        statusMessage: message,
        progress: () => completedSteps / totalSteps,
      );
    }

    state = state.copyWith(
      pageState: MyPlinkyPageState.loading,
      statusMessage: 'Reading files from Plinky...',
      progress: () => 0,
      errorMessage: () => null,
      directory: () => directory,
    );

    try {
      final presetsUf2Bytes = await readFileFromDirectory(
        directory,
        'PRESETS.UF2',
      );
      if (presetsUf2Bytes == null) {
        throw Exception('PRESETS.UF2 not found on the selected drive.');
      }

      final sampleUf2s = <Uint8List?>[];
      if (includeSamples) {
        for (var i = 0; i < sampleCount; i++) {
          updateProgress('Reading SAMPLE$i.UF2...');
          sampleUf2s.add(
            await readFileFromDirectory(directory, 'SAMPLE$i.UF2'),
          );
        }
      }

      updateProgress('Reading CURRENT.UF2...');
      final currentUf2Bytes = await readFileFromDirectory(
        directory,
        'CURRENT.UF2',
      );
      final wavetablePayload = currentUf2Bytes != null
          ? extractWavetablePayloadFromCurrentUf2(currentUf2Bytes)
          : null;
      final wavetableBytes = wavetablePayload != null
          ? packWavetableUf2(wavetablePayload)
          : null;

      // Phase 1: Parse presets and patterns.
      updateProgress('Parsing presets...');
      await Future<void>.delayed(Duration.zero);
      final presetsResult = parsePresetsPhase(presetsUf2Bytes);

      // Phase 2: Parse samples.
      final samplesResult = includeSamples
          ? await parseSamplesPhase(
              SamplesPhaseInput(
                sampleUf2s: sampleUf2s,
                sampleInfos: presetsResult.sampleInfos,
              ),
              onSampleParsing: (index) {
                state = state.copyWith(
                  statusMessage: 'Parsing sample $index...',
                );
              },
            )
          : ParsedSamplesPhase(
              samplePcmData: {},
              emptySampleSlots: {},
              sampleHashes: {},
            );

      // Phase 3: Check wavetable.
      updateProgress('Checking wavetable...');
      await Future<void>.delayed(Duration.zero);
      final wavetableResult = parseWavetablePhase(wavetableBytes);

      final parsedFlashImage = ParsedFlashImage(
        presets: presetsResult.presets,
        sampleInfos: presetsResult.sampleInfos,
        rawSampleInfos: presetsResult.rawSampleInfos,
        patternQuarters: presetsResult.patternQuarters,
      );

      // Populate device presets.
      final devicePresets = <int, Preset>{};
      for (var i = 0; i < presetCount; i++) {
        final presetBytes = presetsResult.presets[i];
        if (presetBytes != null) {
          final preset = Preset(presetBytes.buffer);
          if (!preset.isEmpty) {
            devicePresets[i] = preset;
          }
        }
      }

      final deviceSampleSlots = Set<int>.of(samplesResult.samplePcmData.keys);

      // Match content hashes against saved entries.
      updateProgress('Matching saved content...');

      final matchedPresets = <int, MatchedEntry>{};
      final matchedSamples = <int, MatchedEntry>{};
      MatchedEntry? matchedWavetable;
      final matchedPatterns = <int, MatchedEntry>{};

      await Future.wait([
        _findMatches('presets', presetsResult.presetHashes, matchedPresets),
        _findMatches('samples', samplesResult.sampleHashes, matchedSamples),
        _findMatches('patterns', presetsResult.patternHashes, matchedPatterns),
        if (wavetableResult.wavetableHash != null)
          _findWavetableMatch(wavetableResult.wavetableHash!).then(
            (entry) => matchedWavetable = entry,
          ),
      ]);

      // Populate slots with matched IDs.
      final slots = List<LinkedSlot>.generate(
        32,
        (_) => (presetId: null, sampleId: null, patternId: null),
      );

      for (final entry in matchedPresets.entries) {
        final slotIndex = entry.key;
        String? sampleId;

        final preset = devicePresets[slotIndex];
        if (preset != null && preset.usesSample) {
          final presetRaw = preset.parameterById('P_SAMPLE')?.value;
          if (presetRaw != null && presetRaw != 0) {
            final sampleSlot = rawToSampleSlot(presetRaw);
            if (sampleSlot >= 0) {
              sampleId = matchedSamples[sampleSlot]?.id;
            }
          }
        }

        slots[slotIndex] = (
          presetId: entry.value.id,
          sampleId: sampleId,
          patternId: null,
        );
      }

      // Link samples matched by content hash but not yet linked via P_SAMPLE.
      for (final entry in matchedSamples.entries) {
        final sampleSlotIndex = entry.key;
        for (var i = 0; i < 32; i++) {
          if (slots[i].sampleId != null) {
            continue;
          }
          final preset = devicePresets[i];
          if (preset == null || !preset.usesSample) {
            continue;
          }
          final presetRaw = preset.parameterById('P_SAMPLE')?.value;
          if (presetRaw == null || presetRaw == 0) {
            continue;
          }
          if (rawToSampleSlot(presetRaw) == sampleSlotIndex) {
            slots[i] = (
              presetId: slots[i].presetId,
              sampleId: entry.value.id,
              patternId: slots[i].patternId,
            );
          }
        }
      }

      final wavetableId =
          matchedWavetable?.id ??
          (wavetableResult.deviceHasWavetable ? defaultWavetableId : null);

      final patternIds = <int, String?>{};
      final devicePatternIndices = presetsResult.nonEmptyPatternIndices;
      for (final patternIndex in devicePatternIndices) {
        patternIds[patternIndex] = matchedPatterns[patternIndex]?.id;
      }

      // Check if the device content matches an existing pack.
      final packHash = computePackContentHash(
        presetHashes: presetsResult.presetHashes,
        sampleHashes: samplesResult.sampleHashes,
        patternHashes: presetsResult.patternHashes,
      );
      final matchedPack = await _findMatchingPack(packHash);

      state = state.copyWith(
        pageState: MyPlinkyPageState.loaded,
        statusMessage: '',
        progress: () => null,
        samplesLoaded: includeSamples,
        parsedFlashImage: () => parsedFlashImage,
        devicePresets: devicePresets,
        deviceSampleSlots: deviceSampleSlots,
        deviceSamplePcmData: samplesResult.samplePcmData,
        slots: slots,
        wavetableId: () => wavetableId,
        patternIds: patternIds,
        deviceHasWavetable: wavetableResult.deviceHasWavetable,
        devicePatternIndices: devicePatternIndices,
        matchedPack: () => matchedPack,
      );
    } on Exception catch (error) {
      debugPrint('Failed to read from Plinky: $error');
      state = state.copyWith(
        pageState: MyPlinkyPageState.error,
        errorMessage: error.toString,
      );
    }
  }

  Future<SavedPack?> _findMatchingPack(String packHash) async {
    final results = await _supabase
        .from('packs')
        .select(
          '*, pack_slots(*), profiles(username), '
          'pack_stars(count)',
        )
        .eq('content_hash', packHash)
        .limit(1);

    if (results.isNotEmpty) {
      return SavedPack.fromJson(results.first);
    }
    return null;
  }

  Future<void> _findMatches(
    String table,
    Map<int, String> hashes,
    Map<int, MatchedEntry> matches,
  ) async {
    if (hashes.isEmpty) {
      return;
    }

    final uniqueHashes = hashes.values.toSet().toList();
    final results = await _supabase
        .from(table)
        .select('id, name, content_hash')
        .inFilter('content_hash', uniqueHashes);

    final hashToEntry = <String, MatchedEntry>{};
    for (final map in results) {
      final hash = map['content_hash'] as String?;
      if (hash != null) {
        hashToEntry[hash] = MatchedEntry.fromJson(map);
      }
    }

    for (final entry in hashes.entries) {
      final matched = hashToEntry[entry.value];
      if (matched != null) {
        matches[entry.key] = matched;
      }
    }
  }

  Future<MatchedEntry?> _findWavetableMatch(String hash) async {
    final results = await _supabase
        .from('wavetables')
        .select('id, name, content_hash')
        .eq('content_hash', hash)
        .limit(1);

    if (results.isNotEmpty) {
      return MatchedEntry.fromJson(results.first);
    }
    return null;
  }
}
