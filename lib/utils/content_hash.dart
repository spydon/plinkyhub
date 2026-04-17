import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';

/// Computes a SHA-256 hex digest of the given binary data.
String computeContentHash(Uint8List data) {
  return sha256.convert(data).toString();
}

/// Computes a SHA-256 hex digest of a preset binary with the P_SAMPLE
/// parameter zeroed out, so the hash is independent of which sample slot
/// the preset references. The save-to-device flow remaps P_SAMPLE to
/// match the target slot layout, which would otherwise change the hash.
String computePresetContentHash(Uint8List presetBytes) {
  final normalized = Uint8List.fromList(presetBytes);
  if (normalized.length > sampleParameterOffset + 1) {
    normalized[sampleParameterOffset] = 0;
    normalized[sampleParameterOffset + 1] = 0;
  }
  return sha256.convert(normalized).toString();
}

/// Computes a deterministic SHA-256 hash for a pack based on all its
/// content hashes. The hash is stable regardless of the order items
/// were parsed: preset and pattern hashes are sorted by slot/index
/// and sample hashes by slot index.
///
/// The wavetable hash is intentionally excluded because the wavetable
/// only appears on the emulated drive when transferred in the same session.
String computePackContentHash({
  required Map<int, String> presetHashes,
  required Map<int, String> sampleHashes,
  required Map<int, String> patternHashes,
}) {
  final parts = <String>[];

  // Presets sorted by slot index.
  final presetKeys = presetHashes.keys.toList()..sort();
  for (final key in presetKeys) {
    parts.add('p$key:${presetHashes[key]}');
  }

  // Samples sorted by slot index.
  final sampleKeys = sampleHashes.keys.toList()..sort();
  for (final key in sampleKeys) {
    parts.add('s$key:${sampleHashes[key]}');
  }

  // Patterns sorted by pattern index.
  final patternKeys = patternHashes.keys.toList()..sort();
  for (final key in patternKeys) {
    parts.add('t$key:${patternHashes[key]}');
  }

  final combined = utf8.encode(parts.join('|'));
  return sha256.convert(combined).toString();
}
