import 'dart:math';
import 'dart:typed_data';

/// Plinky's native sample rate.
const plinkySampleRate = 31250;

/// Maximum number of PCM frames that fit in one Plinky sample slot.
const maxPcmFrames = 2097152;

/// Maximum raw PCM size in bytes for one Plinky sample slot.
const maxPcmBytes = maxPcmFrames * 2;

/// Minimum number of samples between adjacent slice points (firmware
/// constraint).
const minSliceSamples = 1024;

/// Parses a WAV file and converts the audio to Plinky's native format:
/// 16-bit signed, mono, little-endian, 31,250 Hz.
///
/// Throws [FormatException] if the file is not a valid PCM WAV.
Uint8List wavToPlinkyPcm(Uint8List wavBytes) {
  final data = ByteData.sublistView(wavBytes);
  var offset = 0;

  // RIFF header
  if (_readFourCC(data, offset) != 'RIFF') {
    throw const FormatException('Not a WAV file: missing RIFF header');
  }
  offset += 4;
  offset += 4; // file size
  if (_readFourCC(data, offset) != 'WAVE') {
    throw const FormatException('Not a WAV file: missing WAVE identifier');
  }
  offset += 4;

  // Find fmt and data chunks
  int? channels;
  int? sampleRate;
  int? bitsPerSample;
  Uint8List? rawData;

  while (offset < data.lengthInBytes - 8) {
    final chunkId = _readFourCC(data, offset);
    final chunkSize = data.getUint32(offset + 4, Endian.little);
    offset += 8;

    if (chunkId == 'fmt ') {
      final audioFormat = data.getUint16(offset, Endian.little);
      if (audioFormat != 1) {
        throw const FormatException(
          'Only uncompressed PCM WAV files are supported',
        );
      }
      channels = data.getUint16(offset + 2, Endian.little);
      sampleRate = data.getUint32(offset + 4, Endian.little);
      // skip byte rate (4) and block align (2)
      bitsPerSample = data.getUint16(offset + 14, Endian.little);
    } else if (chunkId == 'data') {
      rawData = wavBytes.sublist(offset, offset + chunkSize);
    }

    offset += chunkSize;
    // Chunks are word-aligned
    if (chunkSize.isOdd) {
      offset += 1;
    }
  }

  if (channels == null || sampleRate == null || bitsPerSample == null) {
    throw const FormatException('WAV file missing fmt chunk');
  }
  if (rawData == null) {
    throw const FormatException('WAV file missing data chunk');
  }

  // Decode samples to double (-1.0 to 1.0)
  final samples = _decodeSamples(rawData, channels, bitsPerSample);

  // Resample to Plinky's native rate
  final resampled = _resample(samples, sampleRate, plinkySampleRate);

  // Encode as 16-bit signed little-endian
  return _encodePcm16(resampled);
}

/// Decodes raw PCM bytes into mono floating-point samples normalized to
/// -1.0..1.0.
List<double> _decodeSamples(Uint8List raw, int channels, int bitsPerSample) {
  final bytesPerSample = bitsPerSample ~/ 8;
  final frameSize = bytesPerSample * channels;
  final frameCount = raw.length ~/ frameSize;
  final data = ByteData.sublistView(raw);
  final samples = List<double>.filled(frameCount, 0);

  for (var i = 0; i < frameCount; i++) {
    var sum = 0.0;
    for (var ch = 0; ch < channels; ch++) {
      final byteOffset = i * frameSize + ch * bytesPerSample;
      sum += _readSample(data, byteOffset, bitsPerSample);
    }
    samples[i] = sum / channels;
  }

  return samples;
}

/// Reads a single sample from [data] at [offset] and returns it normalized
/// to -1.0..1.0.
double _readSample(ByteData data, int offset, int bitsPerSample) {
  switch (bitsPerSample) {
    case 8:
      // 8-bit WAV is unsigned
      return (data.getUint8(offset) - 128) / 128.0;
    case 16:
      return data.getInt16(offset, Endian.little) / 32768.0;
    case 24:
      final b0 = data.getUint8(offset);
      final b1 = data.getUint8(offset + 1);
      final b2 = data.getInt8(offset + 2);
      final value = b0 | (b1 << 8) | (b2 << 16);
      return value / 8388608.0;
    case 32:
      return data.getInt32(offset, Endian.little) / 2147483648.0;
    default:
      throw FormatException('Unsupported bit depth: $bitsPerSample');
  }
}

/// Resamples [samples] from [srcRate] to [dstRate] using linear
/// interpolation.
List<double> _resample(List<double> samples, int srcRate, int dstRate) {
  if (srcRate == dstRate) {
    return samples;
  }

  final ratio = srcRate / dstRate;
  final outputLength = (samples.length / ratio).floor();
  final output = List<double>.filled(outputLength, 0);

  for (var i = 0; i < outputLength; i++) {
    final srcPos = i * ratio;
    final index = srcPos.floor();
    final frac = srcPos - index;

    if (index + 1 < samples.length) {
      output[i] = samples[index] * (1 - frac) + samples[index + 1] * frac;
    } else {
      output[i] = samples[min(index, samples.length - 1)];
    }
  }

  return output;
}

/// Encodes floating-point samples to 16-bit signed little-endian PCM.
Uint8List _encodePcm16(List<double> samples) {
  final output = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    final value = (clamped * 32767).round();
    output.setInt16(i * 2, value, Endian.little);
  }
  return output.buffer.asUint8List();
}

/// Creates a WAV file from Plinky's native PCM format (16-bit signed, mono,
/// 31,250 Hz little-endian).
Uint8List plinkyPcmToWav(Uint8List pcmBytes) {
  const channels = 1;
  const bitsPerSample = 16;
  const bytesPerSample = bitsPerSample ~/ 8;
  const blockAlign = channels * bytesPerSample;
  const byteRate = plinkySampleRate * blockAlign;

  final dataSize = pcmBytes.length;
  // RIFF header (12) + fmt chunk (24) + data chunk header (8) + data
  final fileSize = 12 + 24 + 8 + dataSize;
  final output = ByteData(fileSize);
  var offset = 0;

  // RIFF header
  _writeFourCC(output, offset, 'RIFF');
  offset += 4;
  output.setUint32(offset, fileSize - 8, Endian.little); // file size - 8
  offset += 4;
  _writeFourCC(output, offset, 'WAVE');
  offset += 4;

  // fmt chunk
  _writeFourCC(output, offset, 'fmt ');
  offset += 4;
  output.setUint32(offset, 16, Endian.little); // chunk size
  offset += 4;
  output.setUint16(offset, 1, Endian.little); // PCM format
  offset += 2;
  output.setUint16(offset, channels, Endian.little);
  offset += 2;
  output.setUint32(offset, plinkySampleRate, Endian.little);
  offset += 4;
  output.setUint32(offset, byteRate, Endian.little);
  offset += 4;
  output.setUint16(offset, blockAlign, Endian.little);
  offset += 2;
  output.setUint16(offset, bitsPerSample, Endian.little);
  offset += 2;

  // data chunk
  _writeFourCC(output, offset, 'data');
  offset += 4;
  output.setUint32(offset, dataSize, Endian.little);
  offset += 4;

  // Copy PCM data
  final outputBytes = output.buffer.asUint8List();
  outputBytes.setRange(offset, offset + dataSize, pcmBytes);

  return outputBytes;
}

void _writeFourCC(ByteData data, int offset, String fourCC) {
  for (var i = 0; i < 4; i++) {
    data.setUint8(offset + i, fourCC.codeUnitAt(i));
  }
}

/// Extracts waveform peak data from WAV bytes for visualization.
///
/// Returns a list of (min, max) amplitude pairs, one per display column.
/// Each pair represents the amplitude envelope for that portion of the audio.
/// The [bucketCount] determines the horizontal resolution.
List<(double, double)> wavToWaveformPeaks(
  Uint8List wavBytes, {
  int bucketCount = 512,
}) {
  final data = ByteData.sublistView(wavBytes);
  var offset = 0;

  // RIFF header
  if (_readFourCC(data, offset) != 'RIFF') {
    return List.filled(bucketCount, (0.0, 0.0));
  }
  offset += 4;
  offset += 4; // file size
  if (_readFourCC(data, offset) != 'WAVE') {
    return List.filled(bucketCount, (0.0, 0.0));
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

  if (channels == null || bitsPerSample == null || rawData == null) {
    return List.filled(bucketCount, (0.0, 0.0));
  }

  final samples = _decodeSamples(rawData, channels, bitsPerSample);
  if (samples.isEmpty) {
    return List.filled(bucketCount, (0.0, 0.0));
  }

  final peaks = List<(double, double)>.filled(bucketCount, (0.0, 0.0));
  final samplesPerBucket = samples.length / bucketCount;

  for (var i = 0; i < bucketCount; i++) {
    final start = (i * samplesPerBucket).floor();
    final end = ((i + 1) * samplesPerBucket).floor().clamp(
      start + 1,
      samples.length,
    );
    var minValue = double.infinity;
    var maxValue = double.negativeInfinity;
    for (var j = start; j < end; j++) {
      if (samples[j] < minValue) {
        minValue = samples[j];
      }
      if (samples[j] > maxValue) {
        maxValue = samples[j];
      }
    }
    peaks[i] = (minValue, maxValue);
  }

  return peaks;
}

String _readFourCC(ByteData data, int offset) {
  return String.fromCharCodes([
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
    data.getUint8(offset + 3),
  ]);
}
