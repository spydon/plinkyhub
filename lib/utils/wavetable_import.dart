import 'dart:typed_data';

import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/utils/wt.dart';

/// Converts a picked wavetable file into the internal wavetable UF2 format.
///
/// `.wt` files are parsed and rendered into a wavetable UF2; Plinky wavetable
/// `.uf2` files are validated and returned unchanged. Throws [FormatException]
/// if [bytes] is neither a `.wt` wavetable nor a Plinky wavetable UF2.
Uint8List importedFileToWavetableUf2(Uint8List bytes) {
  if (isWtFile(bytes)) {
    return generateWavetableUf2FromSamples(wtToWavetableSamples(bytes));
  }
  if (isWavetableUf2(bytes)) {
    return bytes;
  }
  throw const FormatException(
    'Unsupported file. Pick a Plinky wavetable UF2 or a .wt wavetable file.',
  );
}
