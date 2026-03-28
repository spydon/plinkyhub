import 'dart:math';

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

/// Computes the MIDI note number for a pad at [row], [col] in the 8x8 grid.
///
/// [scale] selects the musical scale.
/// [stride] is the semitone interval between columns (typically 7 = fifth).
/// [octaveOffset] shifts the base by octaves (-4 to +4 mapped from param).
/// [pitchOffset] is a fine-tune in semitones (fractional).
int midiNoteForPad({
  required int row,
  required int col,
  PlinkyScale scale = PlinkyScale.chromatic,
  int stride = 7,
  int octaveOffset = 0,
  double pitchOffset = 0,
}) {
  const baseMidi = 48; // C3
  final colOffset = col * stride;
  final rowOffset = _scaleDegreeSemitones(row, scale);
  return baseMidi +
      octaveOffset * 12 +
      colOffset +
      rowOffset +
      pitchOffset.round();
}

/// Returns the playback speed multiplier to pitch-shift from [baseMidi]
/// to [targetMidi]. Speed 1.0 = no shift, 2.0 = one octave up, etc.
double playbackSpeedForMidi(int targetMidi, int baseMidi) {
  return pow(2, (targetMidi - baseMidi) / 12).toDouble();
}
