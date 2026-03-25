const noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

String noteNameFromMidi(int midiNote, int fineTune) {
  final noteName = noteNames[midiNote % 12];
  final octave = (midiNote ~/ 12) - 1;
  if (fineTune == 0) {
    return '$noteName$octave';
  }
  final sign = fineTune > 0 ? '+' : '';
  return '$noteName$octave ($sign${fineTune}c)';
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
