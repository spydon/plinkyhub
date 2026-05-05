/// Plinky firmware's 27 built-in scales with semitone intervals.
enum PlinkyScale {
  major('Major', [0, 2, 4, 5, 7, 9, 11]),
  minor('Minor', [0, 2, 3, 5, 7, 8, 10]),
  harmonicMinor('Harmonic Min', [0, 2, 3, 5, 7, 8, 11]),
  pentatonicMajor('Penta Maj', [0, 2, 4, 7, 9]),
  pentatonicMinor('Penta Min', [0, 3, 5, 7, 10]),
  hirajoshi('Hirajoshi', [0, 2, 3, 7, 8]),
  insen('Insen', [0, 1, 5, 7, 10]),
  iwato('Iwato', [0, 1, 5, 6, 10]),
  minyo('Minyo', [0, 4, 5, 7, 11]),
  fifths('Fifths', [0, 7]),
  triadMajor('Triad Maj', [0, 4, 7]),
  triadMinor('Triad Min', [0, 3, 7]),
  dorian('Dorian', [0, 2, 3, 5, 7, 9, 10]),
  phrygian('Phrygian', [0, 1, 3, 5, 7, 8, 10]),
  lydian('Lydian', [0, 2, 4, 6, 7, 9, 11]),
  mixolydian('Mixolydian', [0, 2, 4, 5, 7, 9, 10]),
  aeolian('Aeolian', [0, 2, 3, 5, 7, 8, 10]),
  locrian('Locrian', [0, 1, 3, 5, 6, 8, 10]),
  bluesMinor('Blues Min', [0, 3, 5, 6, 7, 10]),
  bluesMajor('Blues Maj', [0, 2, 3, 4, 7, 9]),
  romanian('Romanian', [0, 2, 3, 6, 7, 9, 10]),
  wholetone('Wholetone', [0, 2, 4, 6, 8, 10]),
  harmonics('Harmonics', [0, 12, 19, 24, 28, 31]),
  hexany('Hexany', [0, 3, 5, 7, 9, 11]),
  just('Just', [0, 2, 4, 5, 7, 9, 11]),
  chromatic('Chromatic', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
  ;

  const PlinkyScale(this.displayName, this.intervals);

  final String displayName;

  /// Semitone offsets for one octave of the scale.
  final List<int> intervals;
}

/// Converts a row position (0-7, top to bottom) to a semitone offset
/// using the given scale. Wraps into higher octaves as needed.
int _scaleDegreeSemitones(int row, PlinkyScale scale) {
  // Row 0 is the top of the grid (highest pitch), row 7 is the bottom
  // (lowest pitch). Invert so that pressing higher rows gives higher notes.
  final degree = 7 - row;
  final intervals = scale.intervals;
  final octave = degree ~/ intervals.length;
  final step = degree % intervals.length;
  return octave * 12 + intervals[step];
}

/// Computes the MIDI note number for a pad at [row], [column] in the
/// 8x8 grid.
///
/// [scale] selects the musical scale.
/// [stride] is the semitone interval between columns (typically 7 = fifth).
/// [octaveOffset] shifts the base by octaves (-4 to +4 mapped from param).
/// [pitchOffset] is a fine-tune in semitones (fractional).
int midiNoteForPad({
  required int row,
  required int column,
  PlinkyScale scale = PlinkyScale.chromatic,
  int stride = 7,
  int octaveOffset = 0,
  double pitchOffset = 0,
}) {
  const baseMidi = 48; // C3
  final colOffset = column * stride;
  final rowOffset = _scaleDegreeSemitones(row, scale);
  return baseMidi +
      octaveOffset * 12 +
      colOffset +
      rowOffset +
      pitchOffset.round();
}

/// One of the 64 (string, column) Plinky pads, with the MIDI note it
/// produces under a given scale/stride/octave configuration.
class PlinkyPad {
  const PlinkyPad({
    required this.string,
    required this.column,
    required this.midiNote,
  });

  /// Pattern editor row (0 = highest pitch base note, 7 = lowest).
  final int string;

  /// Touch-strip column (0 = lowest position, 7 = highest position).
  final int column;

  /// MIDI note (0-127) this pad produces.
  final int midiNote;
}

/// Returns the 64 Plinky pads grouped by string (string 0 first,
/// then string 1, ...). Within each string the columns run from 7
/// (highest pitch position) down to 0, so rows always read top-down
/// as decreasing pitch within a string group.
List<PlinkyPad> plinkyPadsByString(
  PlinkyScale scale, {
  int stride = 7,
  int octaveOffset = 0,
}) {
  return [
    for (var stringIndex = 0; stringIndex < 8; stringIndex++)
      for (var column = 7; column >= 0; column--)
        PlinkyPad(
          string: stringIndex,
          column: column,
          midiNote: midiNoteForPad(
            row: stringIndex,
            column: column,
            scale: scale,
            stride: stride,
            octaveOffset: octaveOffset,
          ),
        ),
  ];
}

/// Returns the 64 Plinky pads (8 strings × 8 columns) sorted from
/// highest to lowest pitch, suitable for piano-roll display.
List<PlinkyPad> plinkyPadsByPitch(
  PlinkyScale scale, {
  int stride = 7,
  int octaveOffset = 0,
}) {
  final pads = <PlinkyPad>[
    for (var stringIndex = 0; stringIndex < 8; stringIndex++)
      for (var column = 0; column < 8; column++)
        PlinkyPad(
          string: stringIndex,
          column: column,
          midiNote: midiNoteForPad(
            row: stringIndex,
            column: column,
            scale: scale,
            stride: stride,
            octaveOffset: octaveOffset,
          ),
        ),
  ];
  // Highest pitch at the top, like a real piano roll. Stable on
  // (string, column) so duplicate pitches keep a predictable order.
  pads.sort((a, b) {
    final byPitch = b.midiNote.compareTo(a.midiNote);
    if (byPitch != 0) {
      return byPitch;
    }
    final byString = a.string.compareTo(b.string);
    if (byString != 0) {
      return byString;
    }
    return a.column.compareTo(b.column);
  });
  return pads;
}

/// Finds the pad whose MIDI note is closest to [targetMidi], breaking
/// ties by preferring the lower string then the lower column (so
/// imported MIDI defaults to the simplest representation).
PlinkyPad closestPadForMidiNote(List<PlinkyPad> pads, int targetMidi) {
  var best = pads.first;
  var bestDistance = (best.midiNote - targetMidi).abs();
  for (final pad in pads.skip(1)) {
    final distance = (pad.midiNote - targetMidi).abs();
    if (distance < bestDistance) {
      best = pad;
      bestDistance = distance;
    }
  }
  return best;
}
