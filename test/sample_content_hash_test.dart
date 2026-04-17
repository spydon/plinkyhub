// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:plinkyhub/utils/content_hash.dart';
import 'package:plinkyhub/utils/plinky_device_parser.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:test/test.dart';

void main() {
  const testDataDirectory = '/home/spydon/Downloads/plinky/Meska';

  group('Sample content hash consistency', () {
    late Uint8List presetsUf2;
    late Uint8List sample0Uf2;
    late ParsedPresetsPhase presetsResult;

    setUpAll(() {
      presetsUf2 = File('$testDataDirectory/PRESETS.UF2').readAsBytesSync();
      sample0Uf2 = File('$testDataDirectory/SAMPLE0.UF2').readAsBytesSync();
      presetsResult = parsePresetsPhase(presetsUf2);
    });

    test('parsing the same UF2 twice produces the same hash', () async {
      final sampleUf2s = <Uint8List?>[
        sample0Uf2,
        ...List.filled(7, null),
      ];

      final result1 = await parseSamplesPhase(
        SamplesPhaseInput(
          sampleUf2s: sampleUf2s,
          sampleInfos: presetsResult.sampleInfos,
        ),
      );

      final result2 = await parseSamplesPhase(
        SamplesPhaseInput(
          sampleUf2s: sampleUf2s,
          sampleInfos: presetsResult.sampleInfos,
        ),
      );

      expect(result1.sampleHashes[0], isNotNull, reason: 'Hash should exist');
      expect(
        result1.sampleHashes[0],
        equals(result2.sampleHashes[0]),
        reason: 'Hashes should be identical for the same UF2',
      );
    });

    test('hash from parseSamplesPhase matches manual extraction', () async {
      final sampleUf2s = <Uint8List?>[
        sample0Uf2,
        ...List.filled(7, null),
      ];

      final result = await parseSamplesPhase(
        SamplesPhaseInput(
          sampleUf2s: sampleUf2s,
          sampleInfos: presetsResult.sampleInfos,
        ),
      );

      // Manually extract and trim the same way parseSamplesPhase does.
      var pcmData = uf2ToData(sample0Uf2);
      final sampleInfo = presetsResult.sampleInfos[0];
      if (sampleInfo != null && sampleInfo.sampleLength * 2 < pcmData.length) {
        pcmData = Uint8List.sublistView(
          pcmData,
          0,
          sampleInfo.sampleLength * 2,
        );
      }
      final manualHash = computeContentHash(pcmData);

      expect(
        result.sampleHashes[0],
        equals(manualHash),
        reason: 'parseSamplesPhase hash should match manual extraction',
      );
    });

    test('raw uf2ToData size vs trimmed size', () {
      final rawPcm = uf2ToData(sample0Uf2);
      final sampleInfo = presetsResult.sampleInfos[0];

      print('Raw PCM from uf2ToData: ${rawPcm.length} bytes');
      print('sampleInfo: $sampleInfo');
      if (sampleInfo != null) {
        print('sampleInfo.sampleLength: ${sampleInfo.sampleLength}');
        print('Trimmed size would be: ${sampleInfo.sampleLength * 2} bytes');
        print('Needs trimming: ${sampleInfo.sampleLength * 2 < rawPcm.length}');
      } else {
        print('sampleInfo is null, no trimming applied');
      }

      final trimmedPcm =
          (sampleInfo != null && sampleInfo.sampleLength * 2 < rawPcm.length)
          ? Uint8List.sublistView(rawPcm, 0, sampleInfo.sampleLength * 2)
          : rawPcm;

      final hash = computeContentHash(trimmedPcm);
      print('Content hash: $hash');
      print('Trimmed PCM size: ${trimmedPcm.length} bytes');
    });

    test(
      'hash matches what saveSample would compute from same PCM',
      () async {
        // Simulate the "Load from Plinky" upload path:
        // parseSamplesPhase extracts PCM -> _samplePcmData
        // upload uses _samplePcmData[slot] as pcmBytes
        // saveSample calls computeContentHash(pcmBytes)
        final sampleUf2s = <Uint8List?>[
          sample0Uf2,
          ...List.filled(7, null),
        ];

        final result = await parseSamplesPhase(
          SamplesPhaseInput(
            sampleUf2s: sampleUf2s,
            sampleInfos: presetsResult.sampleInfos,
          ),
        );

        final pcmFromParser = result.samplePcmData[0]!;
        final hashFromParser = result.sampleHashes[0]!;
        final hashFromSavePath = computeContentHash(pcmFromParser);

        expect(
          hashFromParser,
          equals(hashFromSavePath),
          reason:
              'Hash from parser should match hash '
              'computed on the same PCM data',
        );

        print('Parser hash: $hashFromParser');
        print('Save-path hash: $hashFromSavePath');
        print('PCM data size: ${pcmFromParser.length} bytes');
      },
    );

    test('hash without sampleInfo trimming differs', () async {
      // Test what happens if sampleInfo is missing (no trimming).
      final sampleUf2s = <Uint8List?>[
        sample0Uf2,
        ...List.filled(7, null),
      ];

      final resultWithInfo = await parseSamplesPhase(
        SamplesPhaseInput(
          sampleUf2s: sampleUf2s,
          sampleInfos: presetsResult.sampleInfos,
        ),
      );

      final resultWithoutInfo = await parseSamplesPhase(
        SamplesPhaseInput(
          sampleUf2s: sampleUf2s,
          sampleInfos: List.filled(8, null),
        ),
      );

      final hashWithInfo = resultWithInfo.sampleHashes[0];
      final hashWithoutInfo = resultWithoutInfo.sampleHashes[0];

      print('Hash WITH sampleInfo trimming: $hashWithInfo');
      print(
        'PCM size WITH trimming: ${resultWithInfo.samplePcmData[0]?.length}',
      );
      print('Hash WITHOUT sampleInfo trimming: $hashWithoutInfo');
      print(
        'PCM size WITHOUT trimming: '
        '${resultWithoutInfo.samplePcmData[0]?.length}',
      );

      if (hashWithInfo != hashWithoutInfo) {
        print('MISMATCH: trimming changes the hash!');
      } else {
        print('Hashes are the same (no trimming needed or no effect)');
      }
    });
  });
}
