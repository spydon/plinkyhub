import 'dart:math';
import 'dart:typed_data';

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

/// Base flash address for the wavetable UF2 on the RP2040.
const _wavetableBaseAddress = 0x08077000;

/// UF2 flags indicating familyID is present.
const _wavetableUf2Flags = 0x00002000;

/// RP2040 family ID.
const _wavetableUf2FamilyId = 0x00ff6919;

/// Scale factor for output samples (matching the C++ tool).
const _outputScale = 16384.0;

/// Generates a wavetable UF2 file from 15 single-cycle WAV files.
///
/// [wavFiles] must contain exactly 15 entries, one for each cycle (c0–c14).
/// Each WAV must be a mono or stereo PCM file containing a single-cycle
/// waveform with at least 512 samples.
///
/// The output contains 17 shapes: a built-in saw (shape 0), the 15 user
/// waveforms (shapes 1–15), and a built-in sine (shape 16).
///
/// Returns the complete UF2 file as bytes, ready to be flashed to a Plinky.
Uint8List generateWavetableUf2(List<Uint8List> wavFiles) {
  if (wavFiles.length != wavetableUserShapeCount) {
    throw ArgumentError(
      'Expected $wavetableUserShapeCount WAV files, '
      'got ${wavFiles.length}',
    );
  }

  // Build high-resolution lookup tables for all 17 shapes.
  final lookups = List<Float64List>.generate(wavetableShapeCount, (shape) {
    if (shape == 0) {
      return _generateSawLookup();
    }
    if (shape == wavetableShapeCount - 1) {
      return _generateSineLookup();
    }
    return _wavToLookup(wavFiles[shape - 1]);
  });

  // Build the windowed sinc anti-aliasing kernel.
  final kernel = _buildKernel();

  // Filter each shape into octave variants.
  final allSamples =
      Int16List(wavetableShapeCount * wavetableSamplesPerShape);
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
        allSamples[offset++] =
            (value * _outputScale).round().clamp(-32768, 32767);
      }
    }
  }

  // Convert Int16 array to little-endian bytes.
  final rawBytes = Uint8List(allSamples.length * 2);
  final byteView = ByteData.sublistView(rawBytes);
  for (var i = 0; i < allSamples.length; i++) {
    byteView.setInt16(i * 2, allSamples[i], Endian.little);
  }

  return _packWavetableUf2(rawBytes);
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

/// Decodes a WAV file and resamples the single-cycle waveform into a
/// normalised 65 536-sample lookup table.
Float64List _wavToLookup(Uint8List wavBytes) {
  final samples = _decodeWavMono(wavBytes);

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
// WAV decoding (self-contained so we don't depend on wav.dart internals)
// ---------------------------------------------------------------------------

/// Decodes a PCM WAV file to mono floating-point samples in the range
/// −1.0 … 1.0.
List<double> _decodeWavMono(Uint8List wavBytes) {
  final data = ByteData.sublistView(wavBytes);
  var offset = 0;

  if (_readFourCC(data, offset) != 'RIFF') {
    throw const FormatException('Not a WAV file: missing RIFF header');
  }
  offset += 8; // skip 'RIFF' + file size
  if (_readFourCC(data, offset) != 'WAVE') {
    throw const FormatException('Not a WAV file: missing WAVE identifier');
  }
  offset += 4;

  int? channels;
  int? bitsPerSample;
  Uint8List? rawData;

  while (offset < data.lengthInBytes - 8) {
    final chunkId = _readFourCC(data, offset);
    final chunkSize = data.getUint32(offset + 4, Endian.little);
    offset += 8;

    if (chunkId == 'fmt ') {
      final audioFormat = data.getUint16(offset, Endian.little);
      if (audioFormat != 1) {
        throw const FormatException('Only PCM WAV files are supported');
      }
      channels = data.getUint16(offset + 2, Endian.little);
      bitsPerSample = data.getUint16(offset + 14, Endian.little);
    } else if (chunkId == 'data') {
      rawData = wavBytes.sublist(offset, offset + chunkSize);
    }

    offset += chunkSize;
    if (chunkSize.isOdd) {
      offset += 1;
    }
  }

  if (channels == null || bitsPerSample == null) {
    throw const FormatException('WAV file missing fmt chunk');
  }
  if (rawData == null) {
    throw const FormatException('WAV file missing data chunk');
  }

  final bytesPerSample = bitsPerSample ~/ 8;
  final frameSize = bytesPerSample * channels;
  final frameCount = rawData.length ~/ frameSize;
  final rawView = ByteData.sublistView(rawData);
  final samples = List<double>.filled(frameCount, 0);

  for (var i = 0; i < frameCount; i++) {
    var sum = 0.0;
    for (var ch = 0; ch < channels; ch++) {
      final byteOffset = i * frameSize + ch * bytesPerSample;
      sum += _readSample(rawView, byteOffset, bitsPerSample);
    }
    samples[i] = sum / channels;
  }
  return samples;
}

double _readSample(ByteData data, int offset, int bitsPerSample) {
  return switch (bitsPerSample) {
    8 => (data.getUint8(offset) - 128) / 128.0,
    16 => data.getInt16(offset, Endian.little) / 32768.0,
    24 => () {
        final b0 = data.getUint8(offset);
        final b1 = data.getUint8(offset + 1);
        final b2 = data.getInt8(offset + 2);
        return (b0 | (b1 << 8) | (b2 << 16)) / 8388608.0;
      }(),
    32 => data.getInt32(offset, Endian.little) / 2147483648.0,
    _ => throw FormatException('Unsupported bit depth: $bitsPerSample'),
  };
}

String _readFourCC(ByteData data, int offset) {
  return String.fromCharCodes([
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
    data.getUint8(offset + 3),
  ]);
}

// ---------------------------------------------------------------------------
// UF2 packing (wavetable-specific flags & base address)
// ---------------------------------------------------------------------------

Uint8List _packWavetableUf2(Uint8List rawData) {
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
      _wavetableBaseAddress + dataOffset,
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
