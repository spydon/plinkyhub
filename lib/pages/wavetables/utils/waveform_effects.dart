import 'dart:math';

import 'package:plinkyhub/pages/wavetables/utils/fft.dart';

/// All effect parameters for a single waveform, each in [0.0, 1.0].
class WaveformEffects {
  double preGain;
  double harmonicShift;
  double comb;
  double ringModulation;
  double chebyshev;
  double sampleAndHold;
  double quantization;
  double slewLimiter;
  double lowpass;
  double highpass;
  double postGain;
  bool normalize;
  bool cycle;

  WaveformEffects({
    this.preGain = 0,
    this.harmonicShift = 0,
    this.comb = 0,
    this.ringModulation = 0,
    this.chebyshev = 0,
    this.sampleAndHold = 0,
    this.quantization = 0,
    this.slewLimiter = 0,
    this.lowpass = 0,
    this.highpass = 0,
    this.postGain = 0,
    this.normalize = false,
    this.cycle = false,
  });

  bool get hasAnyEffect =>
      preGain > 0 ||
      harmonicShift > 0 ||
      comb > 0 ||
      ringModulation > 0 ||
      chebyshev > 0 ||
      sampleAndHold > 0 ||
      quantization > 0 ||
      slewLimiter > 0 ||
      lowpass > 0 ||
      highpass > 0 ||
      postGain > 0 ||
      normalize ||
      cycle;

  void reset() {
    preGain = 0;
    harmonicShift = 0;
    comb = 0;
    ringModulation = 0;
    chebyshev = 0;
    sampleAndHold = 0;
    quantization = 0;
    slewLimiter = 0;
    lowpass = 0;
    highpass = 0;
    postGain = 0;
    normalize = false;
    cycle = false;
  }
}

/// Applies the full effect chain to [samples] and returns new samples.
///
/// The processing order matches WaveEdit:
/// Pre Gain → Harmonic Shift → Comb → Ring Mod → Chebyshev →
/// Sample & Hold → Quantization → Slew Limiter → Lowpass → Highpass →
/// Post Gain → Cycle → Normalize → Hard Clip.
List<double> applyEffects(List<double> samples, WaveformEffects effects) {
  if (!effects.hasAnyEffect) {
    return List<double>.from(samples);
  }

  var result = List<double>.from(samples);
  final sampleCount = result.length;

  // Pre Gain: gain = 20^value.
  if (effects.preGain > 0) {
    final gain = pow(20.0, effects.preGain).toDouble();
    for (var i = 0; i < sampleCount; i++) {
      result[i] *= gain;
    }
  }

  // Harmonic Shift: constant phase offset to all harmonics.
  if (effects.harmonicShift > 0) {
    final complexData = samplesToComplex(result);
    fft(complexData);
    final halfLength = sampleCount ~/ 2;
    final phaseOffset = effects.harmonicShift * 2.0 * pi;
    for (var k = 1; k < halfLength; k++) {
      final real = complexData[2 * k];
      final imaginary = complexData[2 * k + 1];
      final angle = phaseOffset * k;
      final cosAngle = cos(angle);
      final sinAngle = sin(angle);
      complexData[2 * k] = real * cosAngle - imaginary * sinAngle;
      complexData[2 * k + 1] = real * sinAngle + imaginary * cosAngle;
      // Mirror conjugate.
      final mirror = sampleCount - k;
      complexData[2 * mirror] = complexData[2 * k];
      complexData[2 * mirror + 1] = -complexData[2 * k + 1];
    }
    fft(complexData, inverse: true);
    result = complexToSamples(complexData);
  }

  // Comb Filter: frequency-domain convolution with exponentially decaying
  // taps at multiples of the comb frequency.
  if (effects.comb > 0) {
    final combFrequency = effects.comb * (sampleCount ~/ 2);
    final complexData = samplesToComplex(result);
    fft(complexData);
    final halfLength = sampleCount ~/ 2;
    const tapCount = 40;
    const decay = 0.75;
    const normalization = 1.0 - decay;
    for (var k = 0; k <= halfLength; k++) {
      var filterReal = 0.0;
      var filterImaginary = 0.0;
      for (var tap = 0; tap < tapCount; tap++) {
        final amplitude = pow(decay, tap).toDouble() * normalization;
        final phase = -2.0 * pi * combFrequency * tap * k / sampleCount;
        filterReal += amplitude * cos(phase);
        filterImaginary += amplitude * sin(phase);
      }
      final real = complexData[2 * k];
      final imaginary = complexData[2 * k + 1];
      complexData[2 * k] = real * filterReal - imaginary * filterImaginary;
      complexData[2 * k + 1] = real * filterImaginary + imaginary * filterReal;
      if (k > 0 && k < halfLength) {
        final mirror = sampleCount - k;
        complexData[2 * mirror] = complexData[2 * k];
        complexData[2 * mirror + 1] = -complexData[2 * k + 1];
      }
    }
    fft(complexData, inverse: true);
    result = complexToSamples(complexData);
  }

  // Ring Modulation: multiply by integer-frequency sine.
  if (effects.ringModulation > 0) {
    final ringFrequency =
        (effects.ringModulation * effects.ringModulation * 126).ceil();
    for (var i = 0; i < sampleCount; i++) {
      result[i] *= sin(2.0 * pi * ringFrequency * i / sampleCount);
    }
  }

  // Chebyshev Wavefolding: sin(n * asin(x)) for |x| <= 1,
  // sin(n * asin(1/x)) for |x| > 1.
  if (effects.chebyshev > 0) {
    final order = pow(50.0, effects.chebyshev).toDouble();
    for (var i = 0; i < sampleCount; i++) {
      final sample = result[i];
      if (sample.abs() <= 1.0) {
        result[i] = sin(order * asin(sample));
      } else {
        result[i] = sin(order * asin(1.0 / sample));
      }
    }
  }

  // Sample & Hold: step/staircase effect.
  if (effects.sampleAndHold > 0) {
    final frameSkip = pow(128.0, effects.sampleAndHold).toDouble();
    for (var i = 0; i < sampleCount; i++) {
      final snappedPosition = (i / frameSkip).roundToDouble() * frameSkip;
      final index0 = snappedPosition.floor().clamp(0, sampleCount - 1);
      final index1 = (index0 + 1).clamp(0, sampleCount - 1);
      final fraction = snappedPosition - index0;
      result[i] = result[index0] * (1.0 - fraction) + result[index1] * fraction;
    }
  }

  // Quantization: round to discrete amplitude levels.
  if (effects.quantization > 0) {
    final levels = pow(effects.quantization, -1.5).toDouble();
    for (var i = 0; i < sampleCount; i++) {
      result[i] = (result[i] * levels).roundToDouble() / levels;
    }
  }

  // Slew Limiter: clamp per-sample rate of change.
  if (effects.slewLimiter > 0) {
    final slewRate = pow(0.001, effects.slewLimiter).toDouble();
    for (var i = 1; i < sampleCount; i++) {
      final delta = result[i] - result[i - 1];
      result[i] = result[i - 1] + delta.clamp(-slewRate, slewRate);
    }
  }

  // Lowpass: brick-wall filter zeroing harmonics above cutoff.
  if (effects.lowpass > 0) {
    final complexData = samplesToComplex(result);
    fft(complexData);
    final halfLength = sampleCount ~/ 2;
    final cutoff = ((1.0 - effects.lowpass) * halfLength).round();
    for (var k = cutoff; k <= halfLength; k++) {
      complexData[2 * k] = 0;
      complexData[2 * k + 1] = 0;
      if (k > 0 && k < halfLength) {
        final mirror = sampleCount - k;
        complexData[2 * mirror] = 0;
        complexData[2 * mirror + 1] = 0;
      }
    }
    fft(complexData, inverse: true);
    result = complexToSamples(complexData);
  }

  // Highpass: brick-wall filter zeroing harmonics below cutoff.
  if (effects.highpass > 0) {
    final complexData = samplesToComplex(result);
    fft(complexData);
    final halfLength = sampleCount ~/ 2;
    final cutoff = (effects.highpass * halfLength).round();
    for (var k = 0; k < cutoff; k++) {
      complexData[2 * k] = 0;
      complexData[2 * k + 1] = 0;
      if (k > 0 && k < halfLength) {
        final mirror = sampleCount - k;
        complexData[2 * mirror] = 0;
        complexData[2 * mirror + 1] = 0;
      }
    }
    fft(complexData, inverse: true);
    result = complexToSamples(complexData);
  }

  // Post Gain: gain = 20^value.
  if (effects.postGain > 0) {
    final gain = pow(20.0, effects.postGain).toDouble();
    for (var i = 0; i < sampleCount; i++) {
      result[i] *= gain;
    }
  }

  // Cycle: remove start/end discontinuity by subtracting a linear ramp.
  if (effects.cycle) {
    final startValue = result[0];
    final endValue = result[sampleCount - 1];
    final discontinuity = endValue - startValue;
    for (var i = 0; i < sampleCount; i++) {
      result[i] -= discontinuity * (i - sampleCount / 2) / sampleCount;
    }
  }

  // Normalize: scale so min→−1, max→+1.
  if (effects.normalize) {
    var minValue = double.infinity;
    var maxValue = double.negativeInfinity;
    for (final sample in result) {
      if (sample < minValue) {
        minValue = sample;
      }
      if (sample > maxValue) {
        maxValue = sample;
      }
    }
    final range = maxValue - minValue;
    if (range > 1e-10) {
      for (var i = 0; i < sampleCount; i++) {
        result[i] = 2.0 * (result[i] - minValue) / range - 1.0;
      }
    }
  }

  // Hard clip: always applied as final step.
  for (var i = 0; i < sampleCount; i++) {
    result[i] = result[i].clamp(-1.0, 1.0);
  }

  return result;
}
