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

/// Flash item ID for the first SampleInfo (F_SAMPLES_START = 128).
const _sampleInfoItemIdStart = 128;

/// Flash item ID for the floating preset (FLOAT_PRESET_ID = 136).
const _floatingPresetItemId = 136;

/// Byte offset of P_SAMPLE base value in the preset binary.
/// eParams index 52 × 16 bytes per parameter = 832.
/// The raw Int16 value occupies bytes 832-833 (little-endian).
const _sampleParameterOffset = 832;

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
  final samplesPerWindow =
      sampleLength > 0 ? sampleLength / displayPoints : 1.0;
  final pcmView = Int16List.view(pcmData.buffer);

  for (var point = 0; point < displayPoints; point++) {
    final windowStart = (point * samplesPerWindow).floor();
    final windowEnd =
        ((point + 1) * samplesPerWindow).floor().clamp(0, sampleLength);

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

/// Generates a complete PRESETS.UF2 file from presets and sample metadata.
///
/// [presets] is a list of 32 entries. Each entry is either the raw 1552-byte
/// preset data or null for an empty slot.
///
/// [sampleInfos] is a list of up to 8 SampleInfo byte arrays (1072 bytes
/// each), indexed by Plinky sample slot. Null entries are skipped.
Uint8List generatePresetsUf2({
  required List<Uint8List?> presets,
  required List<Uint8List?> sampleInfos,
}) {
  assert(presets.length == presetCount);
  assert(sampleInfos.length <= sampleCount);

  // Create raw flash image: 256 pages × 2048 bytes, initialized to 0xFF
  // (erased flash state).
  final flashImage = Uint8List(flashPageCount * flashPageSize);
  for (var i = 0; i < flashImage.length; i++) {
    flashImage[i] = 0xFF;
  }

  var seq = 1;

  // Pages 0-31: Presets.
  for (var i = 0; i < presetCount; i++) {
    final presetData = presets[i] ?? Uint8List(presetSize);
    _writePage(flashImage, i, presetData, i, seq++);
  }

  // Pages 32-39: SampleInfo entries.
  for (var i = 0; i < sampleInfos.length; i++) {
    if (sampleInfos[i] != null) {
      _writePage(
        flashImage,
        presetCount + i,
        sampleInfos[i]!,
        _sampleInfoItemIdStart + i,
        seq++,
      );
    }
  }

  // Page 40: Floating preset (copy of preset 0).
  final floatingPreset = presets[0] ?? Uint8List(presetSize);
  _writePage(flashImage, presetCount + sampleCount, floatingPreset,
      _floatingPresetItemId, seq++);

  // Convert the flash image to UF2 format.
  return dataToUf2(flashImage, presetsBaseAddress);
}
