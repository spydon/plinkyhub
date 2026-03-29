import 'dart:typed_data';

import 'package:plinkyhub/utils/uf2.dart';

/// Base address for the PRESETS region in Plinky's internal flash.
const presetsBaseAddress = 0x08080000;

/// Size of one flash page (matches firmware FLASH_PAGE_SIZE).
const flashPageSize = 2048;

/// Number of flash pages in the presets region (0-254).
/// Page 255 is reserved for calibration data and must not be overwritten.
const flashPageCount = 255;

/// Usable data bytes per page (before SysParams and PageFooter).
const _flashPageUsable = flashPageSize - _sysParamsSize - _pageFooterSize;

/// Size of the SysParams struct stored in each flash page.
const _sysParamsSize = 16;

/// Size of the PageFooter struct at the end of each flash page.
const _pageFooterSize = 8;

/// Firmware footer version (FOOTER_VERSION = 2).
const _footerVersion = 2;

/// Firmware LPE_SYS_PARAMS_VERSION.
const _sysParamsVersion = 16;

/// Size of a single Preset in bytes.
const presetSize = 1552;

/// Size of the SampleInfo struct in bytes.
const sampleInfoSize = 1072;

/// Number of preset slots on Plinky.
const presetCount = 32;

/// Number of sample slots on Plinky.
const sampleCount = 8;

/// Number of patterns on Plinky.
const patternCount = 24;

/// Number of quarters per pattern.
const _quartersPerPattern = 4;

/// Total number of pattern quarter flash items.
const _patternQuarterCount = patternCount * _quartersPerPattern;

/// Size of one PatternQuarter struct in bytes.
const patternQuarterSize = 1792;

/// Flash item ID for the first pattern quarter (PATTERNS_START = 32).
const _patternQuarterItemIdStart = presetCount;

/// Flash item ID for the first SampleInfo (F_SAMPLES_START = 128).
const _sampleInfoItemIdStart =
    _patternQuarterItemIdStart + _patternQuarterCount;

/// Flash item ID for the floating preset (FLOAT_PRESET_ID = 136).
const _floatingPresetItemId = _sampleInfoItemIdStart + sampleCount;

/// Flash item ID for the first floating pattern quarter.
const _floatingPatternItemIdStart = _floatingPresetItemId + 1;

/// Total number of flash items used by the firmware.
const _numFlashItems = _floatingPatternItemIdStart + _quartersPerPattern;

/// Byte offset of P_SAMPLE base value in the preset binary.
/// eParams index 52 × 16 bytes per parameter = 832.
/// The raw Int16 value occupies bytes 832-833 (little-endian).
const _sampleParameterOffset = 832;

/// Scans all pages in a raw PRESETS flash image and returns a map from
/// item ID to the page data with the highest wear-leveling sequence number.
///
/// Each page has a footer at the last 8 bytes:
///   [0] item ID, [1] version, [2-3] CRC, [4-7] sequence number.
Map<int, Uint8List> _scanFlashPages(Uint8List flashImage) {
  final bestSeq = <int, int>{};
  final bestPage = <int, Uint8List>{};

  for (var pageIndex = 0; pageIndex < flashPageCount; pageIndex++) {
    final pageOffset = pageIndex * flashPageSize;
    if (pageOffset + flashPageSize > flashImage.length) {
      break;
    }

    final footerOffset = pageOffset + flashPageSize - _pageFooterSize;
    final itemId = flashImage[footerOffset];
    final version = flashImage[footerOffset + 1];

    // Skip erased pages (0xFF footer) or unknown versions.
    if (itemId == 0xFF || version != _footerVersion) {
      continue;
    }

    // Skip items outside the valid range.
    if (itemId >= _numFlashItems) {
      continue;
    }

    final seq = flashImage[footerOffset + 4] |
        (flashImage[footerOffset + 5] << 8) |
        (flashImage[footerOffset + 6] << 16) |
        (flashImage[footerOffset + 7] << 24);

    if (!bestSeq.containsKey(itemId) || seq > bestSeq[itemId]!) {
      bestSeq[itemId] = seq;
      bestPage[itemId] = Uint8List.fromList(
        flashImage.sublist(pageOffset, pageOffset + flashPageSize),
      );
    }
  }

  return bestPage;
}

/// Number of sample ID values (NUM_SAMPLES + 1 = 9, including NO_SAMPLE).
const _sampleRange = 9;

/// Computes the firmware flash hash (CRC) over [length] bytes of [data].
///
/// Matches the firmware's `compute_hash()` function.
int computeFlashHash(Uint8List data, int length) {
  var hash = 123;
  for (var i = 0; i < length; i++) {
    hash = (hash * 23 + data[i]) & 0xFFFF;
  }
  return hash;
}

/// Returns the raw P_SAMPLE parameter value for the given firmware
/// [slotIndex] (0-7). Returns 0 for no sample.
///
/// The firmware stores P_SAMPLE 1-based:
///   storedIndex = (slotIndex + 1) % 9
///   raw = INDEX_TO_RAW(storedIndex, 9)
int sampleSlotToRaw(int slotIndex) {
  final storedIndex = (slotIndex + 1) % _sampleRange;
  if (storedIndex == 0) {
    return 0;
  }
  return ((storedIndex << 10) + (_sampleRange - 1)) ~/ _sampleRange;
}

/// Creates a default SysParams block (16 bytes).
Uint8List _buildSysParams() {
  final data = Uint8List(_sysParamsSize);
  data[0] = 0; // preset_id
  data[1] = 0; // midi_in_chan:4, midi_out_chan:4
  data[2] = 150; // accel_sens
  data[3] = 0x80; // volume_lsb
  // volume_msb=2 (bits 0-2), cv_quant=0 (bits 3-4),
  // reverse_encoder=0 (bit 5), preset_aligned=0 (bit 6),
  // pattern_aligned=0 (bit 7)
  data[4] = 0x02;
  // data[5..14] = pad (zeros)
  data[15] = _sysParamsVersion; // version
  return data;
}

/// Writes a single flash page into [output] at [pageIndex].
///
/// [itemData] is the raw struct bytes (Preset, SampleInfo, etc.).
/// [itemId] is the flash item index.
/// [seq] is the wear-leveling sequence number.
void _writePage(
  Uint8List output,
  int pageIndex,
  Uint8List itemData,
  int itemId,
  int seq,
) {
  final pageOffset = pageIndex * flashPageSize;
  final sysParams = _buildSysParams();

  // Write item data (padded to _flashPageUsable with zeros).
  for (var i = 0; i < itemData.length && i < _flashPageUsable; i++) {
    output[pageOffset + i] = itemData[i];
  }

  // Write SysParams at end - _pageFooterSize - _sysParamsSize.
  final sysParamsOffset = pageOffset + _flashPageUsable;
  for (var i = 0; i < _sysParamsSize; i++) {
    output[sysParamsOffset + i] = sysParams[i];
  }

  // Compute CRC over first 2040 bytes (everything except footer).
  final pageSlice = Uint8List.sublistView(output, pageOffset);
  final crc = computeFlashHash(pageSlice, flashPageSize - _pageFooterSize);

  // Write PageFooter at end of page.
  final footerOffset = pageOffset + flashPageSize - _pageFooterSize;
  output[footerOffset + 0] = itemId & 0xFF; // idx
  output[footerOffset + 1] = _footerVersion; // version
  output[footerOffset + 2] = crc & 0xFF; // crc low
  output[footerOffset + 3] = (crc >> 8) & 0xFF; // crc high
  output[footerOffset + 4] = seq & 0xFF; // seq byte 0
  output[footerOffset + 5] = (seq >> 8) & 0xFF; // seq byte 1
  output[footerOffset + 6] = (seq >> 16) & 0xFF; // seq byte 2
  output[footerOffset + 7] = (seq >> 24) & 0xFF; // seq byte 3
}

/// Generates a SampleInfo struct (1072 bytes) from PCM data metadata.
///
/// [pcmData] is the raw PCM bytes (16-bit signed, mono, 31250 Hz).
/// [slicePoints] are fractional positions (0.0-1.0) for 8 slices.
/// [sliceNotes] are Plinky note values (0-96, add 12 for MIDI).
/// [pitched] whether the sample is in pitched/multisample mode.
Uint8List buildSampleInfo({
  required Uint8List pcmData,
  required List<double> slicePoints,
  required List<int> sliceNotes,
  required bool pitched,
}) {
  final sampleLength = pcmData.length ~/ 2; // 16-bit samples → frame count
  final info = ByteData(sampleInfoSize);

  // Generate waveform4_b[1024]: 4-bit peaks for 2048 display points.
  _generateWaveform(info, pcmData, sampleLength);

  // Write splitpoints[8] as absolute sample positions (int32 little-endian).
  const splitpointsOffset = 1024;
  for (var i = 0; i < 8; i++) {
    final absolutePosition = (slicePoints[i] * sampleLength).round();
    info.setInt32(
      splitpointsOffset + i * 4,
      absolutePosition,
      Endian.little,
    );
  }

  // Write samplelen (int32) right after splitpoints.
  const sampleLengthOffset = splitpointsOffset + 32; // 1056
  info.setInt32(sampleLengthOffset, sampleLength, Endian.little);

  // Write notes[8] (s8).
  const notesOffset = sampleLengthOffset + 4; // 1060
  for (var i = 0; i < 8; i++) {
    // Convert from MIDI-based (where 60 = C4) to Plinky scheme
    // (value + 12 = MIDI).
    final plinkyNote = (sliceNotes[i] - 12).clamp(0, 96);
    info.setInt8(notesOffset + i, plinkyNote);
  }

  // pitched flag.
  const pitchedOffset = notesOffset + 8; // 1068
  info.setUint8(pitchedOffset, pitched ? 1 : 0);

  // loop mode: default to one-shot slice (0).
  info.setUint8(pitchedOffset + 1, 0);

  // paddy[2] already zero.

  return info.buffer.asUint8List();
}

/// Generates the 4-bit waveform display data into [info] bytes 0-1023.
///
/// Divides the sample into 2048 windows, finds the peak in each,
/// and packs pairs of 4-bit values into bytes.
void _generateWaveform(ByteData info, Uint8List pcmData, int sampleLength) {
  const displayPoints = 2048;
  final samplesPerWindow = sampleLength > 0
      ? sampleLength / displayPoints
      : 1.0;
  final pcmView = Int16List.view(pcmData.buffer);

  for (var point = 0; point < displayPoints; point++) {
    final windowStart = (point * samplesPerWindow).floor();
    final windowEnd = ((point + 1) * samplesPerWindow).floor().clamp(
      0,
      sampleLength,
    );

    var peak = 0;
    for (var s = windowStart; s < windowEnd && s < pcmView.length; s++) {
      final absolute = pcmView[s].abs();
      if (absolute > peak) {
        peak = absolute;
      }
    }

    // Scale 0-32767 to 0-15.
    final nibble = (peak * 15 ~/ 32767).clamp(0, 15);

    // Pack two 4-bit values per byte: even points in low nibble,
    // odd points in high nibble.
    final byteIndex = point ~/ 2;
    if (point.isEven) {
      info.setUint8(byteIndex, nibble);
    } else {
      info.setUint8(byteIndex, info.getUint8(byteIndex) | (nibble << 4));
    }
  }
}

/// Sets the P_SAMPLE raw value in a preset binary buffer.
///
/// [presetBytes] is a 1552-byte preset buffer (modified in place).
/// [firmwareSlotIndex] is the Plinky sample slot (0-7).
void setPresetSampleSlot(Uint8List presetBytes, int firmwareSlotIndex) {
  final raw = sampleSlotToRaw(firmwareSlotIndex);
  final byteData = ByteData.sublistView(presetBytes);
  byteData.setInt16(_sampleParameterOffset, raw, Endian.little);
}

/// Parsed sample metadata extracted from a SampleInfo struct in PRESETS.UF2.
class ParsedSampleInfo {
  ParsedSampleInfo({
    required this.sampleLength,
    required this.slicePoints,
    required this.sliceNotes,
    required this.pitched,
  });

  /// Total number of PCM frames in the sample.
  final int sampleLength;

  /// Fractional slice positions (0.0-1.0).
  final List<double> slicePoints;

  /// Slice notes in MIDI-based scheme (where 60 = C4).
  final List<int> sliceNotes;

  /// Whether the sample is in pitched/multisample mode.
  final bool pitched;
}

/// Parses a 1072-byte SampleInfo struct and returns extracted metadata.
///
/// Returns `null` if the struct appears empty (sample length is 0).
ParsedSampleInfo? parseSampleInfo(Uint8List sampleInfoBytes) {
  if (sampleInfoBytes.length < sampleInfoSize) {
    return null;
  }

  final data = ByteData.sublistView(sampleInfoBytes);

  // Read sample length at offset 1056.
  const sampleLengthOffset = 1056;
  final sampleLength = data.getInt32(sampleLengthOffset, Endian.little);
  if (sampleLength <= 0) {
    return null;
  }

  // Read 8 split points (int32) at offset 1024, convert to fractional.
  const splitpointsOffset = 1024;
  final slicePoints = <double>[];
  for (var i = 0; i < 8; i++) {
    final absolutePosition = data.getInt32(
      splitpointsOffset + i * 4,
      Endian.little,
    );
    slicePoints.add(
      sampleLength > 0 ? (absolutePosition / sampleLength).clamp(0.0, 1.0) : 0,
    );
  }

  // Read 8 slice notes (s8) at offset 1060, convert from Plinky to MIDI-based.
  const notesOffset = 1060;
  final sliceNotes = <int>[];
  for (var i = 0; i < 8; i++) {
    final plinkyNote = data.getInt8(notesOffset + i);
    // Convert from Plinky scheme (value + 12 = MIDI) back to MIDI-based.
    sliceNotes.add((plinkyNote + 12).clamp(0, 127));
  }

  // Read pitched flag at offset 1068.
  const pitchedOffset = 1068;
  final pitched = data.getUint8(pitchedOffset) != 0;

  return ParsedSampleInfo(
    sampleLength: sampleLength,
    slicePoints: slicePoints,
    sliceNotes: sliceNotes,
    pitched: pitched,
  );
}


/// Extracts all items from a raw PRESETS flash image using the wear-leveling
/// page footer to identify each item correctly.
///
/// Returns a [ParsedFlashImage] containing presets, sample infos, and
/// pattern quarter data.
ParsedFlashImage parseFlashImage(Uint8List flashImage) {
  final pages = _scanFlashPages(flashImage);

  // Extract presets (item IDs 0-31).
  final presets = List<Uint8List?>.filled(presetCount, null);
  for (var i = 0; i < presetCount; i++) {
    final page = pages[i];
    if (page == null) {
      continue;
    }
    final presetBytes = Uint8List.sublistView(page, 0, presetSize);
    final isEmpty =
        presetBytes.every((b) => b == 0xFF) ||
        presetBytes.every((b) => b == 0);
    if (!isEmpty) {
      presets[i] = Uint8List.fromList(presetBytes);
    }
  }

  // Extract sample infos (item IDs 128-135).
  final sampleInfos = List<ParsedSampleInfo?>.filled(sampleCount, null);
  for (var i = 0; i < sampleCount; i++) {
    final page = pages[_sampleInfoItemIdStart + i];
    if (page == null) {
      continue;
    }
    final sampleInfoBytes = Uint8List.sublistView(page, 0, sampleInfoSize);
    sampleInfos[i] = parseSampleInfo(sampleInfoBytes);
  }

  // Extract pattern quarters (item IDs 32-127).
  final patternQuarters =
      List<Uint8List?>.filled(_patternQuarterCount, null);
  for (var i = 0; i < _patternQuarterCount; i++) {
    final page = pages[_patternQuarterItemIdStart + i];
    if (page == null) {
      continue;
    }
    patternQuarters[i] =
        Uint8List.fromList(page.sublist(0, patternQuarterSize));
  }

  return ParsedFlashImage(
    presets: presets,
    sampleInfos: sampleInfos,
    patternQuarters: patternQuarters,
  );
}

/// Result of parsing a PRESETS.UF2 flash image.
class ParsedFlashImage {
  ParsedFlashImage({
    required this.presets,
    required this.sampleInfos,
    required this.patternQuarters,
  });

  /// 32 preset entries (null for empty slots).
  final List<Uint8List?> presets;

  /// 8 sample info entries (null for empty slots).
  final List<ParsedSampleInfo?> sampleInfos;

  /// 96 pattern quarter entries (24 patterns × 4 quarters, null for empty).
  final List<Uint8List?> patternQuarters;

  /// Returns true if any pattern quarter for the given [patternIndex] is
  /// non-null (i.e., the pattern has data).
  bool hasPattern(int patternIndex) {
    final start = patternIndex * _quartersPerPattern;
    for (var q = 0; q < _quartersPerPattern; q++) {
      if (patternQuarters[start + q] != null) {
        return true;
      }
    }
    return false;
  }

  /// Returns the number of non-empty patterns.
  int get nonEmptyPatternCount {
    var count = 0;
    for (var i = 0; i < patternCount; i++) {
      if (hasPattern(i)) {
        count++;
      }
    }
    return count;
  }

  /// Returns the indices of non-empty patterns.
  List<int> get nonEmptyPatternIndices {
    final indices = <int>[];
    for (var i = 0; i < patternCount; i++) {
      if (hasPattern(i)) {
        indices.add(i);
      }
    }
    return indices;
  }
}


/// Generates a complete PRESETS.UF2 file from presets, sample metadata,
/// and pattern quarters.
///
/// [presets] is a list of 32 entries. Each entry is either the raw 1552-byte
/// preset data or null for an empty slot.
///
/// [sampleInfos] is a list of up to 8 SampleInfo byte arrays (1072 bytes
/// each), indexed by Plinky sample slot. Null entries are skipped.
///
/// [patternQuarters] is an optional list of up to 96 entries (24 patterns ×
/// 4 quarters). Each entry is either a 1792-byte `Uint8List` or null.
Uint8List generatePresetsUf2({
  required List<Uint8List?> presets,
  required List<Uint8List?> sampleInfos,
  List<Uint8List?>? patternQuarters,
}) {
  assert(presets.length == presetCount);
  assert(sampleInfos.length <= sampleCount);
  assert(
    patternQuarters == null ||
        patternQuarters.length <= _patternQuarterCount,
  );

  // Create raw flash image: 256 pages × 2048 bytes, initialized to 0xFF
  // (erased flash state).
  final flashImage = Uint8List(flashPageCount * flashPageSize);
  for (var i = 0; i < flashImage.length; i++) {
    flashImage[i] = 0xFF;
  }

  var seq = 1;
  var pageIndex = 0;

  // Presets (item IDs 0-31).
  for (var i = 0; i < presetCount; i++) {
    final presetData = presets[i] ?? Uint8List(presetSize);
    _writePage(flashImage, pageIndex++, presetData, i, seq++);
  }

  // Pattern quarters (item IDs 32-127).
  if (patternQuarters != null) {
    for (var i = 0; i < patternQuarters.length; i++) {
      if (patternQuarters[i] != null) {
        _writePage(
          flashImage,
          pageIndex,
          patternQuarters[i]!,
          _patternQuarterItemIdStart + i,
          seq++,
        );
      }
      pageIndex++;
    }
  } else {
    pageIndex += _patternQuarterCount;
  }

  // SampleInfo entries (item IDs 128-135).
  for (var i = 0; i < sampleInfos.length; i++) {
    if (sampleInfos[i] != null) {
      _writePage(
        flashImage,
        pageIndex,
        sampleInfos[i]!,
        _sampleInfoItemIdStart + i,
        seq++,
      );
    }
    pageIndex++;
  }

  // Floating preset (item ID 136, copy of preset 0).
  final floatingPreset = presets[0] ?? Uint8List(presetSize);
  _writePage(
    flashImage,
    pageIndex++,
    floatingPreset,
    _floatingPresetItemId,
    seq++,
  );

  // Floating pattern quarters (item IDs 137-140, copy of pattern 0).
  if (patternQuarters != null) {
    for (var q = 0; q < _quartersPerPattern; q++) {
      final quarterData = q < patternQuarters.length
          ? patternQuarters[q]
          : null;
      if (quarterData != null) {
        _writePage(
          flashImage,
          pageIndex,
          quarterData,
          _floatingPatternItemIdStart + q,
          seq++,
        );
      }
      pageIndex++;
    }
  }

  // Convert the flash image to UF2 format.
  return dataToUf2(flashImage, presetsBaseAddress);
}

/// Serializes a list of pattern quarters into a flat binary blob.
///
/// Each slot occupies [patternQuarterSize] bytes. Empty slots are filled
/// with 0xFF (erased flash state). The blob is always 96 × 1792 bytes.
Uint8List serializePatternQuarters(List<Uint8List?> quarters) {
  const totalSize = _patternQuarterCount * patternQuarterSize;
  final blob = Uint8List(totalSize);
  // Fill with 0xFF (erased flash).
  for (var i = 0; i < totalSize; i++) {
    blob[i] = 0xFF;
  }
  for (var i = 0; i < quarters.length && i < _patternQuarterCount; i++) {
    final quarter = quarters[i];
    if (quarter != null) {
      final offset = i * patternQuarterSize;
      for (var j = 0; j < quarter.length && j < patternQuarterSize; j++) {
        blob[offset + j] = quarter[j];
      }
    }
  }
  return blob;
}

/// Deserializes a flat binary blob back into a list of pattern quarters.
///
/// Returns a list of 96 entries. Slots that are all 0xFF are returned
/// as null.
List<Uint8List?> deserializePatternQuarters(Uint8List blob) {
  final quarters = List<Uint8List?>.filled(_patternQuarterCount, null);
  for (var i = 0; i < _patternQuarterCount; i++) {
    final offset = i * patternQuarterSize;
    if (offset + patternQuarterSize > blob.length) {
      break;
    }
    final quarter = Uint8List.sublistView(
      blob,
      offset,
      offset + patternQuarterSize,
    );
    final isEmpty = quarter.every((b) => b == 0xFF);
    if (!isEmpty) {
      quarters[i] = Uint8List.fromList(quarter);
    }
  }
  return quarters;
}
