import 'dart:math';
import 'dart:typed_data';

import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/utils/wt.dart';
import 'package:test/test.dart';

List<double> _makeSawtooth(int length) {
  return List<double>.generate(length, (i) => 2.0 * i / length - 1.0);
}

List<double> _makeSine(int length) {
  return List<double>.generate(length, (i) => sin(2.0 * pi * i / length));
}

double _correlation(List<double> a, List<double> b) {
  assert(a.length == b.length);
  var sumAb = 0.0;
  var sumA2 = 0.0;
  var sumB2 = 0.0;
  for (var i = 0; i < a.length; i++) {
    sumAb += a[i] * b[i];
    sumA2 += a[i] * a[i];
    sumB2 += b[i] * b[i];
  }
  if (sumA2 == 0 || sumB2 == 0) {
    return 0;
  }
  return sumAb / sqrt(sumA2 * sumB2);
}

/// Builds a `.wt` file from [waves] (each waveform must be [waveLen] samples).
Uint8List _buildWt(
  List<List<double>> waves,
  int waveLen, {
  required bool int16,
}) {
  final sampleSize = int16 ? 2 : 4;
  final bytes = Uint8List(12 + waves.length * waveLen * sampleSize);
  final view = ByteData.sublistView(bytes);
  // Magic "vawt".
  bytes[0] = 0x76;
  bytes[1] = 0x61;
  bytes[2] = 0x77;
  bytes[3] = 0x74;
  view.setUint32(4, waveLen, Endian.little);
  view.setUint16(8, waves.length, Endian.little);
  view.setUint16(10, int16 ? 0x40 : 0x00, Endian.little);

  var offset = 12;
  for (final wave in waves) {
    for (final sample in wave) {
      if (int16) {
        view.setInt16(
          offset,
          (sample * 32767).round().clamp(-32768, 32767),
          Endian.little,
        );
      } else {
        view.setFloat32(offset, sample, Endian.little);
      }
      offset += sampleSize;
    }
  }
  return bytes;
}

void main() {
  group('isWtFile', () {
    test('recognises the vawt magic', () {
      final wt = _buildWt([_makeSine(512)], 512, int16: true);
      expect(isWtFile(wt), isTrue);
    });

    test('rejects non-wt bytes', () {
      expect(isWtFile(Uint8List.fromList([0, 1, 2, 3])), isFalse);
      expect(isWtFile(Uint8List(0)), isFalse);
    });
  });

  group('wtToWavetableSamples', () {
    test('returns 15 slots for an int16 bank', () {
      final wt = _buildWt(
        [_makeSawtooth(512), _makeSine(512)],
        512,
        int16: true,
      );
      final slots = wtToWavetableSamples(wt);
      expect(slots.length, equals(wavetableUserShapeCount));
      expect(slots.every((s) => s.length == 512), isTrue);
    });

    test('returns 15 slots for a float32 bank', () {
      final wt = _buildWt([_makeSine(256)], 256, int16: false);
      final slots = wtToWavetableSamples(wt);
      expect(slots.length, equals(wavetableUserShapeCount));
      expect(slots.every((s) => s.length == 256), isTrue);
    });

    test('maps a single waveform to every slot', () {
      final saw = _makeSawtooth(512);
      final wt = _buildWt([saw], 512, int16: true);
      final slots = wtToWavetableSamples(wt);
      for (final slot in slots) {
        expect(_correlation(slot, saw), greaterThan(0.99));
      }
    });

    test('spreads multiple waveforms across slots', () {
      final saw = _makeSawtooth(512);
      final sine = _makeSine(512);
      final wt = _buildWt([saw, sine], 512, int16: true);
      final slots = wtToWavetableSamples(wt);
      // First slot maps to the saw, last slot maps to the sine.
      expect(_correlation(slots.first, saw), greaterThan(0.99));
      expect(_correlation(slots.last, sine), greaterThan(0.99));
    });

    test('rejects files without the vawt magic', () {
      expect(
        () => wtToWavetableSamples(Uint8List.fromList(List.filled(64, 0))),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects files flagged as a sample', () {
      final wt = _buildWt([_makeSine(512)], 512, int16: true);
      final view = ByteData.sublistView(wt);
      view.setUint16(10, 0x40 | 0x10, Endian.little);
      expect(
        () => wtToWavetableSamples(wt),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects truncated files', () {
      final wt = _buildWt([_makeSine(512)], 512, int16: true);
      final truncated = Uint8List.sublistView(wt, 0, wt.length - 100);
      expect(
        () => wtToWavetableSamples(truncated),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('wt import round-trip through the wavetable generator', () {
    test('a saw/sine bank survives conversion to UF2 and back', () {
      final wt = _buildWt(
        [_makeSawtooth(512), _makeSine(512)],
        512,
        int16: true,
      );
      final slots = wtToWavetableSamples(wt);
      final uf2Bytes = generateWavetableUf2FromSamples(slots);

      expect(isWavetableUf2(uf2Bytes), isTrue);

      final extracted = extractSamplesFromWavetableData(uf2ToData(uf2Bytes));
      expect(extracted.length, equals(wavetableUserShapeCount));
      expect(
        _correlation(extracted.first, _makeSawtooth(512)),
        greaterThan(0.9),
      );
      expect(
        _correlation(extracted.last, _makeSine(512)),
        greaterThan(0.9),
      );
    });

    test('a non-512 waveLen bank is resampled correctly', () {
      final wt = _buildWt([_makeSine(256)], 256, int16: false);
      final slots = wtToWavetableSamples(wt);
      final uf2Bytes = generateWavetableUf2FromSamples(slots);
      final extracted = extractSamplesFromWavetableData(uf2ToData(uf2Bytes));
      expect(
        _correlation(extracted.first, _makeSine(512)),
        greaterThan(0.9),
      );
    });
  });

  group('isWavetableUf2', () {
    test('accepts a generated wavetable UF2', () {
      final slots = List<List<double>>.generate(
        wavetableUserShapeCount,
        (_) => _makeSine(512),
      );
      final uf2Bytes = generateWavetableUf2FromSamples(slots);
      expect(isWavetableUf2(uf2Bytes), isTrue);
    });

    test('rejects a sample UF2', () {
      final sampleUf2 = sampleToUf2(Uint8List(1024));
      expect(isWavetableUf2(sampleUf2), isFalse);
    });

    test('rejects non-UF2 bytes', () {
      expect(isWavetableUf2(Uint8List(16)), isFalse);
    });
  });
}
