import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/pages/wavetables/utils/waveform_effects.dart';
import 'package:plinkyhub/utils/wavetable.dart';

class BakedSlot {
  final List<double> samples;
  final bool effects;
  List<double>? get postEffectSamples => effects ? samples : null;

  Int16List toPCM16({
    int fadeInSamples = 0,
    int fadeOutSamples = 0,
    double frequency = 220.0,
    int sampleRate = 44100,
    int copies = 1,
  }) {
    final targetLength = (sampleRate / frequency).round();
    final src = samples;
    final srcLen = src.length;
    final out = List.generate(targetLength, (i) {
      final pos = i / targetLength * srcLen;
      final lo = pos.floor() % srcLen;
      final hi = (lo + 1) % srcLen;
      final s = src[lo] + (src[hi] - src[lo]) * (pos - pos.floor());
      if (i < fadeInSamples) {
        return (s * (i / fadeInSamples) * 32767).clamp(-32768, 32767).toInt();
      } else if (i >= targetLength - fadeOutSamples && fadeOutSamples > 0) {
        return (s * ((targetLength - i) / fadeOutSamples) * 32767)
            .clamp(-32768, 32767)
            .toInt();
      } else {
        return (s * 32767).clamp(-32768, 32767).toInt();
      }
    });
    return Int16List.fromList(
      copies == 1
          ? out
          : List.generate(copies, (_) => out).expand((x) => x).toList(),
    );
  }

  BakedSlot mixWith(BakedSlot other, double mix) {
    if (samples.length != other.samples.length) {
      throw ArgumentError('Cannot mix slots with different sample lengths');
    }
    final mixedSamples = List.generate(
      samples.length,
      (i) => samples[i] * (1 - mix) + other.samples[i] * mix,
    );
    return BakedSlot(mixedSamples, effects: effects || other.effects);
  }

  BakedSlot(this.samples, {required this.effects});
}

class WavetableCache extends ChangeNotifier {
  late final List<BakedSlot> _baked;
  late final int sampleCount;

  int lastUpdatedSlot = -1;

  WavetableCache(List<List<double>> slots, List<WaveformEffects> effects) {
    _baked = List.generate(
      wavetableUserShapeCount,
      (i) => _bake(slots[i], effects[i]),
      growable: false,
    );
    sampleCount = slots.isNotEmpty ? slots[0].length : 0;
  }

  BakedSlot operator [](int i) => _baked[i];
  List<List<double>> get all => List.unmodifiable(_baked);

  BakedSlot _bake(List<double> samples, WaveformEffects effects) {
    return BakedSlot(
      effects.hasAnyEffect ? applyEffects(samples, effects) : samples,
      effects: effects.hasAnyEffect,
    );
  }

  BakedSlot invalidate(
    int slot,
    List<double> samples,
    WaveformEffects effects,
  ) {
    _baked[slot] = _bake(samples, effects);
    lastUpdatedSlot = slot;
    notifyListeners();
    return _baked[slot];
  }
}
