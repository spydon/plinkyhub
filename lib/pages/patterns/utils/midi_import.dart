import 'dart:typed_data';

import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:plinkyhub/pages/patterns/create_pattern_tab.dart';
import 'package:plinkyhub/utils/pitch.dart';

/// Result of importing a MIDI file into the pattern grid format.
class MidiImportResult {
  MidiImportResult({
    required this.grid,
    required this.trackNames,
  });

  /// 2D grid indexed by step then row. Cell value: 0 = inactive,
  /// 1..8 = active at touch-strip column 0..7.
  final List<List<int>> grid;

  /// Names of tracks found in the MIDI file (for track selection UI).
  final List<String> trackNames;
}

/// Imports a MIDI file and converts it to a pattern grid.
///
/// [midiBytes] is the raw MIDI file content.
/// [scale] determines how MIDI note numbers map to grid rows.
/// [trackIndex] selects which track to import (null = merge all tracks).
MidiImportResult importMidiToGrid({
  required Uint8List midiBytes,
  required PlinkyScale scale,
  int? trackIndex,
}) {
  final parser = MidiParser();
  final midiFile = parser.parseMidiFromBuffer(midiBytes);
  final ticksPerBeat = midiFile.header.ticksPerBeat ?? 480;

  // Extract track names.
  final trackNames = <String>[];
  for (var i = 0; i < midiFile.tracks.length; i++) {
    String? name;
    for (final event in midiFile.tracks[i]) {
      if (event is TrackNameEvent) {
        name = event.text;
        break;
      }
    }
    trackNames.add(name ?? 'Track ${i + 1}');
  }

  // Collect note-on events from selected track(s).
  final noteOns = <({int tick, int noteNumber})>[];

  final tracksToProcess = trackIndex != null
      ? [midiFile.tracks[trackIndex]]
      : midiFile.tracks;

  for (final track in tracksToProcess) {
    var absoluteTick = 0;
    for (final event in track) {
      absoluteTick += event.deltaTime;
      if (event is NoteOnEvent && event.velocity > 0) {
        noteOns.add((tick: absoluteTick, noteNumber: event.noteNumber));
      }
    }
  }

  if (noteOns.isEmpty) {
    return MidiImportResult(
      grid: [
        for (var s = 0; s < fixedStepCount; s++)
          [for (var r = 0; r < 8; r++) 0],
      ],
      trackNames: trackNames,
    );
  }

  // Determine the quantization grid: one step = one sixteenth note.
  final ticksPerStep = ticksPerBeat ~/ 4;

  // Compute every (string, column) pad for the current scale so we
  // can map each MIDI note to the closest pad rather than rounding
  // to one of just 8 strings.
  final pads = plinkyPadsByPitch(scale);

  final grid = [
    for (var s = 0; s < fixedStepCount; s++) [for (var r = 0; r < 8; r++) 0],
  ];

  for (final note in noteOns) {
    final step = (note.tick / ticksPerStep).round();
    if (step >= fixedStepCount) {
      continue;
    }
    final pad = closestPadForMidiNote(pads, note.noteNumber);
    // Cell value 1..8 = column 0..7. Per-string monophony: each step
    // can hold one column per string.
    grid[step][pad.string] = pad.column + 1;
  }

  return MidiImportResult(
    grid: grid,
    trackNames: trackNames,
  );
}
