import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/play/patch_picker_dialog.dart';
import 'package:plinkyhub/pages/play/play_pad.dart';
import 'package:plinkyhub/pages/play/sample_picker_dialog.dart';
import 'package:plinkyhub/state/midi_notifier.dart';
import 'package:plinkyhub/state/play_notifier.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/waveform_visualizer.dart';

/// Icon grid matching the physical Plinky pad layout.
/// Column 0 is always blank (shift strip on hardware).
/// Each row corresponds to a functional parameter group.
const _padIcons = <List<String>>[
  // Row 0 — Sound
  [
    'blank', 'shape', 'distortion--resonance', 'pitch',
    'octave--scale', 'glide--microtone',
    'osc-interval--column', 'mod-src--sample',
  ],
  // Row 1 — Envelope 1
  [
    'blank', 'sensitivity--env-2-level', 'attack', 'decay',
    'sustain', 'release', 'blank', 'mod-src--base',
  ],
  // Row 2 — Effects
  [
    'blank', 'delay--reverb', 'time',
    'pingpong--shimmer', 'wobble', 'feedback',
    'tempo--swing', 'mod-src--sensitivity',
  ],
  // Row 3 — Arp / Seq
  [
    'blank', 'arp--latch', 'order', 'clock-div',
    'chance', 'euclid-len', 'arp-octaves', 'mod-src--a',
  ],
  // Row 4 — Sampler
  [
    'blank', 'scrub--jitter', 'grain-size--jitter',
    'play-speed--jitter', 'time', 'sample',
    'pattern--step-offset', 'mod-src--b',
  ],
  // Row 5 — Mod A / B
  [
    'blank', 'a-b-cv-level', 'offset', 'lfo--depth',
    'lfo--rate', 'lfo--shape', 'lfo--symmetry',
    'mod-src--x',
  ],
  // Row 6 — Mod X / Y
  [
    'blank', 'x-y-cv-level', 'offset', 'lfo--depth',
    'lfo--rate', 'lfo--shape', 'lfo--symmetry',
    'mod-src--y',
  ],
  // Row 7 — Mix / System
  [
    'blank', 'synth', 'wet-dry', 'hpf', 'blank',
    'cv-quantize', 'volume', 'mod-src--random',
  ],
];

class PlayPage extends ConsumerWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playState = ref.watch(playProvider);
    final plinkyState = ref.watch(plinkyProvider);
    final midiState = ref.watch(midiProvider);
    final patchName = plinkyState.patch?.name ?? '';
    final canPlay = plinkyState.patch != null ||
        playState.sampleWavBytes != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              PlinkyButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const PatchPickerDialog(),
                ),
                icon: Icons.piano,
                label: patchName.isEmpty
                    ? 'Load Patch'
                    : patchName,
              ),
              const SizedBox(width: 16),
              PlinkyButton(
                onPressed: playState.isLoadingSample
                    ? null
                    : () => showDialog<void>(
                          context: context,
                          builder: (_) =>
                              const SamplePickerDialog(),
                        ),
                icon: playState.isLoadingSample
                    ? Icons.hourglass_empty
                    : Icons.audio_file,
                label: playState.sampleName.isEmpty
                    ? 'Load Sample'
                    : playState.sampleName,
              ),
              const SizedBox(width: 16),
              PlinkyButton(
                onPressed: midiState.isConnected
                    ? null
                    : () => ref
                          .read(midiProvider.notifier)
                          .connect(),
                icon: midiState.isConnected
                    ? Icons.music_note
                    : Icons.music_off,
                label: midiState.isConnected
                    ? 'MIDI Connected'
                    : 'Connect MIDI',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Waveform visualizer
          SizedBox(
            height: 120,
            child: WaveformVisualizer(
              activeNotes: midiState.activeNotes,
            ),
          ),
          const SizedBox(height: 16),
          // 8x8 grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _PadGrid(
                      size: constraints.maxWidth,
                      activePads: playState.activePads,
                      canPlay: canPlay,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PadGrid extends ConsumerWidget {
  const _PadGrid({
    required this.size,
    required this.activePads,
    required this.canPlay,
  });

  final double size;
  final Set<int> activePads;
  final bool canPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gridSize = 8;
    final padSize = size / gridSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(gridSize, (row) {
        return SizedBox(
          height: padSize,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gridSize, (col) {
              final icon = '${_padIcons[row][col]}.png';
              final padIndex = row * gridSize + col;

              return SizedBox(
                width: padSize,
                height: padSize,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: PlayPad(
                    iconAsset: icon,
                    isActive: activePads.contains(padIndex),
                    onPressStart: canPlay
                        ? () => ref
                            .read(playProvider.notifier)
                            .playPad(row, col)
                        : () {},
                    onPressEnd: () => ref
                        .read(playProvider.notifier)
                        .stopPad(row, col),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
