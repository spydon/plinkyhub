import 'dart:convert';
import 'dart:typed_data';

import 'package:plinkyhub/pages/patterns/models/pattern_data.dart';

/// Number of strings on the Plinky (rows in a pattern).
const _stringCount = 8;

/// Number of steps in one PatternQuarter (matches firmware
/// `PatternQuarter.steps[16][8]` in `params.h`).
const _stepsPerQuarter = 16;

/// Bytes per `FingerRecord` (4 bytes pos + 8 bytes pressure).
const _fingerRecordBytes = 12;

/// Bytes per `PatternQuarter`. Must match `patternQuarterSize` in
/// `lib/utils/presets_uf2.dart`.
const _quarterBytes = 1792;

/// Decodes a pattern file fetched from Supabase storage. Pattern files
/// come in two formats:
///
/// 1. JSON [PatternData] written by the in-app pattern editor.
/// 2. Raw binary PatternQuarter blobs (multiples of 1792 bytes) extracted
///    from a Plinky `PRESETS.UF2` by the pack importer.
///
/// Returns null if the data cannot be decoded as either format.
PatternData? decodePatternFile(Uint8List bytes) {
  final jsonData = _tryDecodeJson(bytes);
  if (jsonData != null) {
    return jsonData;
  }
  return _tryDecodeBinary(bytes);
}

PatternData? _tryDecodeJson(Uint8List bytes) {
  try {
    final text = utf8.decode(bytes);
    final json = jsonDecode(text) as Map<String, dynamic>;
    return PatternData.fromJson(json);
  } on Object {
    return null;
  }
}

PatternData? _tryDecodeBinary(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length % _quarterBytes != 0) {
    return null;
  }

  // Pattern files saved by the pack importer use
  // `serializePatternQuarters`, which always emits all 96 pack-wide
  // quarter slots (172,032 bytes), with empty slots filled with 0xFF.
  // We collect only the contiguous run of non-empty quarters that
  // belong to this pattern (one pattern is always 4 contiguous
  // quarters in the firmware).
  final quarterCount = bytes.length ~/ _quarterBytes;
  final populatedQuarters = <int>[];
  for (var quarter = 0; quarter < quarterCount; quarter++) {
    if (!_isQuarterEmpty(bytes, quarter)) {
      populatedQuarters.add(quarter);
    }
  }

  if (populatedQuarters.isEmpty) {
    return const PatternData();
  }

  final grid = <List<int>>[];
  for (final quarter in populatedQuarters) {
    final quarterOffset = quarter * _quarterBytes;
    for (var step = 0; step < _stepsPerQuarter; step++) {
      final row = List<int>.filled(_stringCount, 0);
      for (var stringIndex = 0; stringIndex < _stringCount; stringIndex++) {
        final fingerOffset =
            quarterOffset +
            (step * _stringCount + stringIndex) * _fingerRecordBytes;
        // FingerRecord layout: pos[4], pressure[8]. The step is active
        // for this string when any pressure sample is non-zero. The
        // first non-zero pressure substep also tells us which position
        // sample to look at (firmware writes `pos[substep / 2]`).
        var firstActiveSubstep = -1;
        for (var pressureIndex = 0; pressureIndex < 8; pressureIndex++) {
          if (bytes[fingerOffset + 4 + pressureIndex] != 0) {
            firstActiveSubstep = pressureIndex;
            break;
          }
        }
        if (firstActiveSubstep < 0) {
          continue;
        }
        final positionByte = bytes[fingerOffset + (firstActiveSubstep ~/ 2)];
        // pos_decompress gives `8 * positionByte`, and the column index
        // is the high bits: `(8 * positionByte) >> 8` == `positionByte >> 5`.
        final column = (positionByte >> 5) & 0x07;
        // Plinky string index 0 is the lowest pitch; the pattern editor
        // uses row 0 as the highest pitch. Flip so the visual matches
        // the editor's note layout.
        row[_stringCount - 1 - stringIndex] = column + 1;
      }
      grid.add(row);
    }
  }

  return PatternData(grid: grid);
}

bool _isQuarterEmpty(Uint8List bytes, int quarter) {
  final start = quarter * _quarterBytes;
  final end = start + _quarterBytes;
  for (var index = start; index < end; index++) {
    if (bytes[index] != 0xFF) {
      return false;
    }
  }
  return true;
}
