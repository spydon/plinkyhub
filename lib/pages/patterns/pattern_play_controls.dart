import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/midi_state.dart';
import 'package:plinkyhub/pages/patterns/models/pattern_data.dart';
import 'package:plinkyhub/pages/patterns/providers/pattern_playback_notifier.dart';
import 'package:plinkyhub/providers/midi_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

/// Total number of preset slots on the Plinky (patterns are 0-31).
const _presetSlotCount = 32;

/// Reusable play/stop + tempo + MIDI output + preset selector for a
/// single pattern. The parent owns the [PatternData] snapshot; this
/// widget just drives `patternPlaybackProvider` for the given
/// [patternId] and handles the input controls.
class PatternPlayControls extends ConsumerStatefulWidget {
  const PatternPlayControls({
    required this.patternId,
    required this.patternData,
    super.key,
  });

  final String patternId;

  /// Snapshot of pattern data to play. When null the play button is
  /// disabled (e.g. while the pattern hasn't loaded yet, or there are
  /// no notes to play).
  final PatternData? patternData;

  @override
  ConsumerState<PatternPlayControls> createState() =>
      _PatternPlayControlsState();
}

class _PatternPlayControlsState extends ConsumerState<PatternPlayControls> {
  static const _minimumBpm = 20.0;
  static const _maximumBpm = 300.0;

  int? _presetSlot;
  late final TextEditingController _bpmController;
  double _beatsPerMinute = 80;

  @override
  void initState() {
    super.initState();
    _bpmController = TextEditingController(
      text: _beatsPerMinute.toStringAsFixed(0),
    );
    // Try to get a MIDI output port ready so the user can play right away.
    Future.microtask(() async {
      final midiState = ref.read(midiProvider);
      if (!midiState.isConnected) {
        await ref.read(midiProvider.notifier).connect();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PatternPlayControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Push live edits to the notifier so the user can keep editing
    // the grid while it's playing.
    final pattern = widget.patternData;
    if (pattern != null && pattern != oldWidget.patternData) {
      ref
          .read(patternPlaybackProvider.notifier)
          .updatePattern(widget.patternId, pattern);
    }
  }

  @override
  void dispose() {
    _bpmController.dispose();
    super.dispose();
  }

  void _commitBpm(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      _bpmController.text = _beatsPerMinute.toStringAsFixed(0);
      return;
    }
    final clamped = parsed.clamp(_minimumBpm, _maximumBpm);
    setState(() => _beatsPerMinute = clamped);
    _bpmController.text = clamped.toStringAsFixed(0);
    ref.read(patternPlaybackProvider.notifier).setBeatsPerMinute(clamped);
  }

  void _togglePlay() {
    final playbackState = ref.read(patternPlaybackProvider);
    final notifier = ref.read(patternPlaybackProvider.notifier);
    final isPlayingThisPattern =
        playbackState.isPlaying &&
        playbackState.currentPatternId == widget.patternId;

    if (isPlayingThisPattern) {
      notifier.stop();
      return;
    }

    final patternData = widget.patternData;
    if (patternData == null) {
      return;
    }

    notifier.play(
      patternId: widget.patternId,
      pattern: patternData,
      presetSlot: _presetSlot,
      beatsPerMinute: _beatsPerMinute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final midiState = ref.watch(midiProvider);
    final playbackState = ref.watch(patternPlaybackProvider);

    final isPlayingThisPattern =
        playbackState.isPlaying &&
        playbackState.currentPatternId == widget.patternId;
    final hasOutput = midiState.selectedOutputId != null;
    final hasNotes =
        widget.patternData != null &&
        widget.patternData!.grid.any(
          (step) => step.any((cell) => cell != 0),
        );
    final canPlay = hasOutput && hasNotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PlinkyButton(
              onPressed: canPlay ? _togglePlay : null,
              icon: isPlayingThisPattern ? Icons.stop : Icons.play_arrow,
              label: isPlayingThisPattern ? 'Stop' : 'Play',
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: _BpmField(
                controller: _bpmController,
                onSubmitted: _commitBpm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MidiOutputDropdown(
                midiState: midiState,
                onSelected: ref.read(midiProvider.notifier).selectOutput,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _PresetSlotDropdown(
          presetSlot: _presetSlot,
          onChanged: playbackState.isPlaying
              ? null
              : (value) => setState(() => _presetSlot = value),
        ),
        if (!hasOutput) ...[
          const SizedBox(height: 12),
          Text(
            'No MIDI output detected. Plug in your Plinky and refresh the '
            'MIDI access permission if needed.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _BpmField extends StatelessWidget {
  const _BpmField({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
      ],
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        labelText: 'BPM',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      onSubmitted: onSubmitted,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
        onSubmitted(controller.text);
      },
    );
  }
}

class _MidiOutputDropdown extends StatelessWidget {
  const _MidiOutputDropdown({
    required this.midiState,
    required this.onSelected,
  });

  final MidiState midiState;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final outputs = midiState.outputs;
    if (outputs.isEmpty) {
      return const Text('No MIDI outputs');
    }
    return DropdownButtonFormField<String>(
      initialValue: midiState.selectedOutputId,
      decoration: const InputDecoration(
        labelText: 'MIDI output',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: [
        for (final output in outputs)
          DropdownMenuItem<String>(
            value: output.id,
            child: Text(
              output.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onSelected,
    );
  }
}

class _PresetSlotDropdown extends StatelessWidget {
  const _PresetSlotDropdown({
    required this.presetSlot,
    required this.onChanged,
  });

  final int? presetSlot;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: presetSlot,
      decoration: const InputDecoration(
        labelText: 'Preset slot (optional)',
        helperText: 'Sends a program change to select the preset on the Plinky',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: [
        const DropdownMenuItem<int?>(
          child: Text('Use currently selected preset'),
        ),
        for (var slot = 0; slot < _presetSlotCount; slot++)
          DropdownMenuItem<int?>(
            value: slot,
            child: Text('Preset ${slot + 1}'),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
