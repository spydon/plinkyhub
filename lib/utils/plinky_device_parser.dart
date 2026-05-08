import 'dart:typed_data';

import 'package:plinkyhub/utils/content_hash.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';

/// Parsed result from a Plinky device, containing all device data
/// and precomputed content hashes.
class ParsedPlinkyDevice {
  ParsedPlinkyDevice({
    required this.presets,
    required this.sampleInfos,
    required this.patternQuarters,
    required this.nonEmptyPatternIndices,
    required this.samplePcmData,
    required this.emptySampleSlots,
    required this.presetHashes,
    required this.sampleHashes,
    required this.wavetableHash,
    required this.patternHashes,
    required this.deviceHasWavetable,
  });

  /// 32 preset byte arrays (null for empty slots).
  final List<Uint8List?> presets;

  /// 8 parsed sample info entries (null for empty slots).
  final List<ParsedSampleInfo?> sampleInfos;

  /// 96 pattern quarter entries.
  final List<Uint8List?> patternQuarters;

  /// Indices of patterns that have data.
  final List<int> nonEmptyPatternIndices;

  /// Trimmed, non-silent PCM data per sample slot index.
  final Map<int, Uint8List> samplePcmData;

  /// Sample slots that are empty or silent.
  final Set<int> emptySampleSlots;

  /// Content hashes for non-empty presets (slot index -> hash).
  final Map<int, String> presetHashes;

  /// Content hashes for non-silent samples (slot index -> hash).
  final Map<int, String> sampleHashes;

  /// Content hash for the wavetable (null if no wavetable).
  final String? wavetableHash;

  /// Content hashes for non-empty patterns (pattern index -> hash).
  final Map<int, String> patternHashes;

  /// Whether the device has a non-empty wavetable.
  final bool deviceHasWavetable;
}

/// Result of parsing PRESETS.UF2 (phase 1).
class ParsedPresetsPhase {
  ParsedPresetsPhase({
    required this.presets,
    required this.rawPresets,
    required this.sampleInfos,
    required this.rawSampleInfos,
    required this.patternQuarters,
    required this.presetHashes,
    required this.nonEmptyPatternIndices,
    required this.patternHashes,
  });

  final List<Uint8List?> presets;
  final List<Uint8List?> rawPresets;
  final List<ParsedSampleInfo?> sampleInfos;
  final List<Uint8List?> rawSampleInfos;
  final List<Uint8List?> patternQuarters;
  final Map<int, String> presetHashes;
  final List<int> nonEmptyPatternIndices;
  final Map<int, String> patternHashes;
}

/// Input for [parseSamplesPhase].
class SamplesPhaseInput {
  SamplesPhaseInput({
    required this.sampleUf2s,
    required this.sampleInfos,
  });

  final List<Uint8List?> sampleUf2s;
  final List<ParsedSampleInfo?> sampleInfos;
}

/// Result of parsing samples (phase 2).
class ParsedSamplesPhase {
  ParsedSamplesPhase({
    required this.samplePcmData,
    required this.emptySampleSlots,
    required this.sampleHashes,
  });

  final Map<int, Uint8List> samplePcmData;
  final Set<int> emptySampleSlots;
  final Map<int, String> sampleHashes;
}

/// Result of checking the wavetable (phase 3).
class ParsedWavetablePhase {
  ParsedWavetablePhase({
    required this.deviceHasWavetable,
    required this.wavetableHash,
  });

  final bool deviceHasWavetable;
  final String? wavetableHash;
}

/// Phase 1: Parse PRESETS.UF2. Decodes flash image, extracts presets,
/// patterns, sample metadata, and computes preset/pattern hashes.
ParsedPresetsPhase parsePresetsPhase(Uint8List presetsUf2) {
  final flashImage = uf2ToData(presetsUf2);
  final parsed = parseFlashImage(flashImage);

  final presetHashes = <int, String>{};
  for (var i = 0; i < presetCount; i++) {
    final presetBytes = parsed.presets[i];
    if (presetBytes != null && !presetBytes.every((b) => b == 0)) {
      presetHashes[i] = computePresetContentHash(presetBytes);
    }
  }

  final patternHashes = <int, String>{};
  final nonEmptyPatternIndices = parsed.nonEmptyPatternIndices;
  for (final patternIndex in nonEmptyPatternIndices) {
    final quarterStart = patternIndex * 4;
    final quarters = List<Uint8List?>.filled(
      parsed.patternQuarters.length,
      null,
    );
    for (var q = 0; q < 4; q++) {
      final index = quarterStart + q;
      if (index < parsed.patternQuarters.length) {
        quarters[index] = parsed.patternQuarters[index];
      }
    }
    final patternBlob = serializePatternQuarters(quarters);
    patternHashes[patternIndex] = computeContentHash(patternBlob);
  }

  return ParsedPresetsPhase(
    presets: parsed.presets,
    rawPresets: parsed.rawPresets,
    sampleInfos: parsed.sampleInfos,
    rawSampleInfos: parsed.rawSampleInfos,
    patternQuarters: parsed.patternQuarters,
    presetHashes: presetHashes,
    nonEmptyPatternIndices: nonEmptyPatternIndices,
    patternHashes: patternHashes,
  );
}

/// Phase 2: Parse samples. Decodes UF2, trims PCM, detects silence,
/// and computes content hashes.
///
/// If [onSampleParsing] is provided, it is called before each sample
/// is parsed with the sample index, allowing callers to update UI.
Future<ParsedSamplesPhase> parseSamplesPhase(
  SamplesPhaseInput input, {
  void Function(int sampleIndex)? onSampleParsing,
}) async {
  final samplePcmData = <int, Uint8List>{};
  final emptySampleSlots = <int>{};
  final sampleHashes = <int, String>{};

  for (var i = 0; i < sampleCount; i++) {
    if (onSampleParsing != null) {
      onSampleParsing(i);
      await Future<void>.delayed(Duration.zero);
    }
    final sampleUf2 = input.sampleUf2s[i];
    if (sampleUf2 == null || sampleUf2.isEmpty) {
      emptySampleSlots.add(i);
      continue;
    }
    try {
      var pcmData = uf2ToData(sampleUf2);
      final sampleInfo = i < input.sampleInfos.length
          ? input.sampleInfos[i]
          : null;
      if (sampleInfo != null && sampleInfo.sampleLength * 2 < pcmData.length) {
        pcmData = Uint8List.sublistView(
          pcmData,
          0,
          sampleInfo.sampleLength * 2,
        );
      }
      if (pcmData.isNotEmpty && !_isSilentPcm(pcmData)) {
        samplePcmData[i] = pcmData;
        sampleHashes[i] = computeContentHash(pcmData);
      } else {
        emptySampleSlots.add(i);
      }
    } on FormatException {
      emptySampleSlots.add(i);
    }
  }

  return ParsedSamplesPhase(
    samplePcmData: samplePcmData,
    emptySampleSlots: emptySampleSlots,
    sampleHashes: sampleHashes,
  );
}

/// Phase 3: Check wavetable. Detects presence and computes hash.
ParsedWavetablePhase parseWavetablePhase(Uint8List? wavetableBytes) {
  final deviceHasWavetable =
      wavetableBytes != null &&
      wavetableBytes.isNotEmpty &&
      !wavetableBytes.every((b) => b == 0) &&
      !wavetableBytes.every((b) => b == 0xFF);
  final wavetableHash = deviceHasWavetable
      ? computeContentHash(wavetableBytes)
      : null;

  return ParsedWavetablePhase(
    deviceHasWavetable: deviceHasWavetable,
    wavetableHash: wavetableHash,
  );
}

/// Returns true if the PCM data is silent (all zeros, all 0xFF,
/// or every 16-bit sample is the same value).
bool _isSilentPcm(Uint8List pcmData) {
  if (pcmData.isEmpty) {
    return true;
  }
  // Single pass: check if all bytes are the same value.
  final first = pcmData[0];
  for (var i = 1; i < pcmData.length; i++) {
    if (pcmData[i] != first) {
      // Bytes differ, but could still be uniform 16-bit samples.
      // Fall through to the 16-bit check.
      if (pcmData.length >= 4) {
        final view = Int16List.view(pcmData.buffer);
        final firstSample = view[0];
        for (var j = 1; j < view.length; j++) {
          if (view[j] != firstSample) {
            return false;
          }
        }
        return true;
      }
      return false;
    }
  }
  // All bytes identical (covers all-zero and all-0xFF).
  return true;
}
