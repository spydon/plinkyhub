import 'dart:typed_data';

import 'package:plinkyhub/utils/wavetable.dart';

/// ASCII magic bytes ("vawt") at the start of a `.wt` wavetable file.
const _wtMagic = [0x76, 0x61, 0x77, 0x74];

/// Flag bit set when the file holds a sample instead of a wavetable.
const _wtFlagSample = 0x10;

/// Flag bit set when the sample data is int16 rather than float32.
const _wtFlagInt16 = 0x40;

/// Guards against absurd allocations from malformed headers.
const _maxWtWaveLen = 65536;
const _maxWtBankLen = 4096;

/// Returns whether [bytes] begins with the `.wt` "vawt" magic.
bool isWtFile(Uint8List bytes) {
  if (bytes.length < _wtMagic.length) {
    return false;
  }
  for (var i = 0; i < _wtMagic.length; i++) {
    if (bytes[i] != _wtMagic[i]) {
      return false;
    }
  }
  return true;
}

/// Parses a `.wt` wavetable file into [wavetableUserShapeCount] sample slots.
///
/// The `.wt` format begins with a 12-byte header: the ASCII magic `vawt`, a
/// little-endian uint32 samples-per-waveform count, a little-endian uint16
/// waveform count, and a little-endian uint16 flags field. The sample data
/// follows as either int16 (scaled by 1/32768) or little-endian float32
/// values.
///
/// `.wt` banks can hold any number of waveforms; they are mapped onto the 15
/// user slots by selecting evenly spaced waveforms across the bank. The
/// waveforms are returned at their native length and are resampled to the
/// internal lookup resolution by [generateWavetableUf2FromSamples].
///
/// Throws [FormatException] if [bytes] is not a valid wavetable `.wt` file.
List<List<double>> wtToWavetableSamples(Uint8List bytes) {
  if (bytes.length < 12 || !isWtFile(bytes)) {
    throw const FormatException('Not a valid .wt file: missing "vawt" header');
  }

  final view = ByteData.sublistView(bytes);
  final waveLen = view.getUint32(4, Endian.little);
  final bankLen = view.getUint16(8, Endian.little);
  final flags = view.getUint16(10, Endian.little);

  if (flags & _wtFlagSample != 0) {
    throw const FormatException(
      'This .wt file contains a sample, not a wavetable',
    );
  }
  if (waveLen == 0 || bankLen == 0) {
    throw const FormatException('This .wt file contains no waveforms');
  }
  if (waveLen > _maxWtWaveLen || bankLen > _maxWtBankLen) {
    throw const FormatException('This .wt file is too large to import');
  }

  final sampleCount = waveLen * bankLen;
  final remaining = bytes.length - 12;

  // Detect the sample format from the payload size, which is unambiguous and
  // robust against differing flag conventions, falling back to the flags
  // field when the size matches neither layout exactly.
  final bool isInt16;
  if (remaining == sampleCount * 4) {
    isInt16 = false;
  } else if (remaining == sampleCount * 2) {
    isInt16 = true;
  } else {
    isInt16 = flags & _wtFlagInt16 != 0;
  }

  if (remaining < sampleCount * (isInt16 ? 2 : 4)) {
    throw const FormatException('This .wt file is truncated');
  }

  final raw = Float64List(sampleCount);
  if (isInt16) {
    for (var i = 0; i < sampleCount; i++) {
      raw[i] = view.getInt16(12 + i * 2, Endian.little) / 32768.0;
    }
  } else {
    for (var i = 0; i < sampleCount; i++) {
      raw[i] = view.getFloat32(12 + i * 4, Endian.little);
    }
  }

  return List<List<double>>.generate(wavetableUserShapeCount, (slot) {
    final sourceIndex = bankLen == 1
        ? 0
        : (slot * (bankLen - 1) / (wavetableUserShapeCount - 1)).round();
    final start = sourceIndex * waveLen;
    return raw.sublist(start, start + waveLen);
  });
}
