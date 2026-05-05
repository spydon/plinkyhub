import 'dart:math';
import 'dart:typed_data';

import 'package:plinkyhub/utils/uf2.dart';

/// Number of waveform shapes in the wavetable.
const wavetableShapeCount = 17;

/// Number of samples in the highest-resolution octave.
const wavetableSamplesPerCycle = 512;

/// Number of octave variants per shape.
const wavetableOctaveCount = 9;

/// Total samples per shape: sum of (512>>oct)+1 for oct in 0..8 = 1031.
const wavetableSamplesPerShape = 1031;

/// High-resolution lookup table size per shape.
const wavetableLookupSize = 65536;

/// Number of user-provided WAV files (c0 through c14).
const wavetableUserShapeCount = 15;

/// Base flash address for the wavetable region.
const wavetableBaseAddress = 0x08077000;

/// Size of the wavetable region in bytes (36 KB).
const wavetableSize = 36 * 1024;

/// Base flash address of CURRENT.UF2.
const _currentUf2BaseAddress = 0x08010000;

/// UF2 flags indicating familyID is present.
const _wavetableUf2Flags = 0x00002000;

/// RP2040 family ID.
const _wavetableUf2FamilyId = 0x00ff6919;

/// Scale factor for output samples (matching the C++ tool).
const _outputScale = 16384.0;

/// Generates a wavetable UF2 file from 15 raw sample arrays.
///
/// [sampleArrays] must contain exactly 15 entries, one for each cycle
/// (c0–c14). Each entry is a list of floating-point samples in the range
/// −1.0 to 1.0 representing one cycle of a waveform. The samples are
/// resampled to the internal lookup table resolution automatically.
///
/// The output contains 17 shapes: a built-in saw (shape 0), a built-in sine
/// (shape 1), and the 15 user waveforms (shapes 2–16), matching the official
/// Plinky wavetable format.
///
/// Returns the complete UF2 file as bytes, ready to be flashed to a Plinky.
Uint8List generateWavetableUf2FromSamples(List<List<double>> sampleArrays) {
  if (sampleArrays.length != wavetableUserShapeCount) {
    throw ArgumentError(
      'Expected $wavetableUserShapeCount sample arrays, '
      'got ${sampleArrays.length}',
    );
  }

  final lookups = List<Float64List>.generate(wavetableShapeCount, (shape) {
    if (shape == 0) {
      return _generateSawLookup();
    }
    if (shape == 1) {
      return _generateSineLookup();
    }
    return _samplesToLookup(sampleArrays[shape - 2]);
  });

  return _generateUf2FromLookups(lookups);
}

/// Shared UF2 generation from pre-built lookup tables.
Uint8List _generateUf2FromLookups(List<Float64List> lookups) {
  // Build the windowed sinc anti-aliasing kernel.
  final kernel = _buildKernel();

  // Filter each shape into octave variants.
  final allSamples = Int16List(wavetableShapeCount * wavetableSamplesPerShape);
  var offset = 0;

  for (var shape = 0; shape < wavetableShapeCount; shape++) {
    final lookup = lookups[shape];
    for (var octave = 0; octave < wavetableOctaveCount; octave++) {
      final samplesInOctave = wavetableSamplesPerCycle >> octave;
      for (var i = 0; i <= samplesInOctave; i++) {
        var value = 0.0;
        for (var j = -255; j <= 255; j++) {
          final phase = (i << (octave + 7)) + (j << (octave + 2));
          value += kernel[j.abs()] * lookup[phase & 0xFFFF];
        }
        allSamples[offset++] = (value * _outputScale).round().clamp(
          -32768,
          32767,
        );
      }
    }
  }

  // Convert Int16 array to little-endian bytes.
  final rawBytes = Uint8List(allSamples.length * 2);
  final byteView = ByteData.sublistView(rawBytes);
  for (var i = 0; i < allSamples.length; i++) {
    byteView.setInt16(i * 2, allSamples[i], Endian.little);
  }

  return packWavetableUf2(rawBytes);
}

/// Extracts the 15 user waveform slots from raw wavetable data.
///
/// [rawData] should be the output of `uf2ToData` applied to a wavetable UF2.
/// Returns a list of 15 sample arrays (512 samples each, in the range −1.0
/// to 1.0), corresponding to shapes 2–16 (the user-drawn waveforms c0–c14).
///
/// Because the UF2 stores anti-aliased octave variants, the extracted samples
/// are taken from the highest-resolution octave and may differ slightly from
/// the original drawn waveforms.
List<List<double>> extractSamplesFromWavetableData(Uint8List rawData) {
  final view = ByteData.sublistView(rawData);
  const samplesPerShapeBytes = wavetableSamplesPerShape * 2;

  final result = <List<double>>[];
  for (var shape = 2; shape < wavetableShapeCount; shape++) {
    final shapeByteOffset = shape * samplesPerShapeBytes;
    final samples = List<double>.filled(wavetableSamplesPerCycle, 0);

    // Read the highest-resolution octave (octave 0): 512 samples.
    var peak = 0.0;
    for (var i = 0; i < wavetableSamplesPerCycle; i++) {
      final value = view.getInt16(shapeByteOffset + i * 2, Endian.little);
      final sample = value / _outputScale;
      samples[i] = sample;
      final absolute = sample.abs();
      if (absolute > peak) {
        peak = absolute;
      }
    }

    // Normalise to peak = 1.0 to match the editor's expected range.
    if (peak > 0) {
      final gain = 1.0 / peak;
      for (var i = 0; i < wavetableSamplesPerCycle; i++) {
        samples[i] = (samples[i] * gain).clamp(-1.0, 1.0);
      }
    }

    result.add(samples);
  }
  return result;
}

/// Generates a sawtooth lookup table (shape 0).
Float64List _generateSawLookup() {
  final lookup = Float64List(wavetableLookupSize);
  for (var i = 0; i < wavetableLookupSize; i++) {
    lookup[i] = 2.0 * i / wavetableLookupSize - 1.0;
  }
  return lookup;
}

/// Generates a sine lookup table (shape 16).
Float64List _generateSineLookup() {
  final lookup = Float64List(wavetableLookupSize);
  for (var i = 0; i < wavetableLookupSize; i++) {
    lookup[i] = sin(2.0 * pi * i / wavetableLookupSize);
  }
  return lookup;
}

/// Resamples raw floating-point samples into a normalised 65 536-sample
/// lookup table.
Float64List _samplesToLookup(List<double> samples) {
  if (samples.isEmpty) {
    throw const FormatException('Sample array is empty');
  }

  // Normalise to peak = 1.0.
  var peak = 0.0;
  for (final sample in samples) {
    final absolute = sample.abs();
    if (absolute > peak) {
      peak = absolute;
    }
  }
  final gain = peak > 0 ? 1.0 / peak : 1.0;

  // Resample to wavetableLookupSize using linear interpolation (circular).
  final lookup = Float64List(wavetableLookupSize);
  for (var i = 0; i < wavetableLookupSize; i++) {
    final sourcePosition = i * samples.length / wavetableLookupSize;
    final index = sourcePosition.floor();
    final fraction = sourcePosition - index;
    final sample0 = samples[index % samples.length];
    final sample1 = samples[(index + 1) % samples.length];
    lookup[i] = (sample0 * (1.0 - fraction) + sample1 * fraction) * gain;
  }
  return lookup;
}

/// Builds the windowed sinc kernel used for anti-aliased octave generation.
///
/// Uses a Hann window with a sinc cutoff of π / 28.
Float64List _buildKernel() {
  final kernel = Float64List(256);
  kernel[0] = 1.0;
  for (var i = 1; i < 256; i++) {
    final x = i * pi / 28.0;
    kernel[i] = (0.5 + 0.5 * cos(i * pi / 256.0)) * sin(x) / x;
  }

  // Normalise so the kernel sums to 1.0 (symmetric, so count each
  // non-zero tap twice).
  var total = kernel[0];
  for (var i = 1; i < 256; i++) {
    total += 2.0 * kernel[i];
  }
  for (var i = 0; i < 256; i++) {
    kernel[i] /= total;
  }
  return kernel;
}

// ---------------------------------------------------------------------------
// UF2 packing and extraction (wavetable-specific flags & base address)
// ---------------------------------------------------------------------------

/// Extracts the raw wavetable payload from the firmware image in
/// [currentUf2Bytes].
///
/// The wavetable lives at flash address [wavetableBaseAddress] inside the
/// firmware binary. Returns null if [currentUf2Bytes] is not a valid UF2, if
/// the firmware image is too small to contain the wavetable region, or if the
/// extracted region is blank (all 0x00 or all 0xFF).
Uint8List? extractWavetablePayloadFromCurrentUf2(Uint8List currentUf2Bytes) {
  Uint8List flashData;
  try {
    flashData = uf2ToData(currentUf2Bytes);
  } on FormatException {
    return null;
  }

  const wavetableOffset = wavetableBaseAddress - _currentUf2BaseAddress;
  if (flashData.length < wavetableOffset + wavetableSize) {
    return null;
  }

  final payload = Uint8List.sublistView(
    flashData,
    wavetableOffset,
    wavetableOffset + wavetableSize,
  );

  if (payload.every((b) => b == 0x00) || payload.every((b) => b == 0xFF)) {
    return null;
  }

  return payload;
}

/// Packs raw wavetable [rawData] into a WAVETAB.UF2-compatible file.
///
/// The output uses the wavetable-specific UF2 flags and target addresses and
/// is byte-for-byte identical to a WAVETAB.UF2 generated from the same data.
Uint8List packWavetableUf2(Uint8List rawData) {
  const dataPerBlock = 256;
  const blockSize = 512;
  final totalBlocks = (rawData.length + dataPerBlock - 1) ~/ dataPerBlock;
  final output = ByteData(totalBlocks * blockSize);

  for (var blockNumber = 0; blockNumber < totalBlocks; blockNumber++) {
    final blockOffset = blockNumber * blockSize;
    final dataOffset = blockNumber * dataPerBlock;
    final dataLength = (dataOffset + dataPerBlock <= rawData.length)
        ? dataPerBlock
        : rawData.length - dataOffset;

    // Header (32 bytes)
    output.setUint32(blockOffset + 0, 0x0A324655, Endian.little);
    output.setUint32(blockOffset + 4, 0x9E5D5157, Endian.little);
    output.setUint32(blockOffset + 8, _wavetableUf2Flags, Endian.little);
    output.setUint32(
      blockOffset + 12,
      wavetableBaseAddress + dataOffset,
      Endian.little,
    );
    output.setUint32(blockOffset + 16, dataLength, Endian.little);
    output.setUint32(blockOffset + 20, blockNumber, Endian.little);
    output.setUint32(blockOffset + 24, totalBlocks, Endian.little);
    output.setUint32(blockOffset + 28, _wavetableUf2FamilyId, Endian.little);

    // Data payload
    for (var i = 0; i < dataLength; i++) {
      output.setUint8(blockOffset + 32 + i, rawData[dataOffset + i]);
    }

    // Final magic at end of block
    output.setUint32(
      blockOffset + blockSize - 4,
      0x0AB16F30,
      Endian.little,
    );
  }

  return output.buffer.asUint8List();
}
