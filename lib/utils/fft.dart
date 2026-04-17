import 'dart:math';
import 'dart:typed_data';

/// In-place radix-2 Cooley–Tukey FFT on interleaved complex data.
///
/// [data] is a [Float64List] of length 2*N where N is a power of two.
/// Even indices hold real parts, odd indices hold imaginary parts.
/// When [inverse] is true, computes the inverse FFT (with 1/N scaling).
void fft(Float64List data, {bool inverse = false}) {
  final length = data.length ~/ 2;
  assert(length > 0 && (length & (length - 1)) == 0, 'N must be a power of 2');

  // Bit-reversal permutation.
  final halfLength = length >> 1;
  var reversedIndex = 0;
  for (var i = 0; i < length - 1; i++) {
    if (i < reversedIndex) {
      // Swap real parts.
      final temporaryReal = data[2 * i];
      data[2 * i] = data[2 * reversedIndex];
      data[2 * reversedIndex] = temporaryReal;
      // Swap imaginary parts.
      final temporaryImaginary = data[2 * i + 1];
      data[2 * i + 1] = data[2 * reversedIndex + 1];
      data[2 * reversedIndex + 1] = temporaryImaginary;
    }
    var mask = halfLength;
    while (mask <= reversedIndex) {
      reversedIndex -= mask;
      mask >>= 1;
    }
    reversedIndex += mask;
  }

  // Butterfly passes.
  final angleSign = inverse ? 1.0 : -1.0;
  for (var stride = 2; stride <= length; stride <<= 1) {
    final halfStride = stride >> 1;
    final angleStep = angleSign * 2.0 * pi / stride;
    final cosStep = cos(angleStep);
    final sinStep = sin(angleStep);

    var twiddleReal = 1.0;
    var twiddleImaginary = 0.0;
    for (var j = 0; j < halfStride; j++) {
      for (var i = j; i < length; i += stride) {
        final pairedIndex = i + halfStride;
        final productReal =
            twiddleReal * data[2 * pairedIndex] -
            twiddleImaginary * data[2 * pairedIndex + 1];
        final productImaginary =
            twiddleReal * data[2 * pairedIndex + 1] +
            twiddleImaginary * data[2 * pairedIndex];

        data[2 * pairedIndex] = data[2 * i] - productReal;
        data[2 * pairedIndex + 1] = data[2 * i + 1] - productImaginary;
        data[2 * i] += productReal;
        data[2 * i + 1] += productImaginary;
      }
      final newTwiddleReal = twiddleReal * cosStep - twiddleImaginary * sinStep;
      twiddleImaginary = twiddleReal * sinStep + twiddleImaginary * cosStep;
      twiddleReal = newTwiddleReal;
    }
  }

  // Scale by 1/N for inverse transform.
  if (inverse) {
    final scale = 1.0 / length;
    for (var i = 0; i < data.length; i++) {
      data[i] *= scale;
    }
  }
}

/// Converts real-valued samples to interleaved complex format for [fft].
Float64List samplesToComplex(List<double> samples) {
  final complexData = Float64List(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    complexData[2 * i] = samples[i];
    // Imaginary part remains 0.0.
  }
  return complexData;
}

/// Extracts real parts from interleaved complex data.
List<double> complexToSamples(Float64List complexData) {
  final length = complexData.length ~/ 2;
  return List<double>.generate(length, (i) => complexData[2 * i]);
}

/// Extracts harmonic magnitudes from a complex spectrum.
///
/// Returns N/2 magnitudes (harmonics 0 through N/2−1) where harmonic 0
/// is the DC component.
List<double> spectrumToHarmonics(Float64List complexSpectrum) {
  final length = complexSpectrum.length ~/ 2;
  final harmonicCount = length ~/ 2;
  return List<double>.generate(harmonicCount, (i) {
    final real = complexSpectrum[2 * i];
    final imaginary = complexSpectrum[2 * i + 1];
    return sqrt(real * real + imaginary * imaginary);
  });
}

/// Rebuilds a complex spectrum from harmonic magnitudes, preserving
/// phases from the original spectrum.
///
/// If the original magnitude was zero (no phase info), defaults to a
/// 90-degree phase (pure imaginary, matching WaveEdit behaviour).
void applyHarmonicsToSpectrum(
  List<double> harmonics,
  Float64List complexSpectrum,
) {
  final length = complexSpectrum.length ~/ 2;

  for (var i = 0; i < harmonics.length; i++) {
    final real = complexSpectrum[2 * i];
    final imaginary = complexSpectrum[2 * i + 1];
    final oldMagnitude = sqrt(real * real + imaginary * imaginary);
    final newMagnitude = harmonics[i];

    if (oldMagnitude > 1e-10) {
      final scale = newMagnitude / oldMagnitude;
      complexSpectrum[2 * i] = real * scale;
      complexSpectrum[2 * i + 1] = imaginary * scale;
    } else {
      // No existing phase: default to pure imaginary (90° phase).
      complexSpectrum[2 * i] = 0.0;
      complexSpectrum[2 * i + 1] = -newMagnitude;
    }

    // Mirror to conjugate symmetric bin (except DC and Nyquist).
    if (i > 0 && i < length ~/ 2) {
      final mirrorIndex = length - i;
      complexSpectrum[2 * mirrorIndex] = complexSpectrum[2 * i];
      complexSpectrum[2 * mirrorIndex + 1] = -complexSpectrum[2 * i + 1];
    }
  }
}
