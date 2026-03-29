import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/slice_note_dropdown.dart';
import 'package:plinkyhub/pages/samples/slice_points_painter.dart';
import 'package:plinkyhub/utils/wav.dart';

class SlicePointsEditor extends StatefulWidget {
  const SlicePointsEditor({
    required this.slicePoints,
    required this.wavBytes,
    required this.enabled,
    required this.onChanged,
    this.pcmFrameCount,
    this.pitched = false,
    this.sliceNotes = defaultSliceNotes,
    this.onSliceNotesChanged,
    super.key,
  });

  final List<double> slicePoints;
  final Uint8List? wavBytes;
  final bool enabled;
  final ValueChanged<List<double>> onChanged;

  /// Total number of PCM frames after conversion to Plinky format.
  /// When provided, the editor enforces a minimum gap of [minSliceSamples]
  /// between adjacent slice points.
  final int? pcmFrameCount;
  final bool pitched;
  final List<int> sliceNotes;
  final ValueChanged<List<int>>? onSliceNotesChanged;

  @override
  State<SlicePointsEditor> createState() => _SlicePointsEditorState();
}

class _SlicePointsEditorState extends State<SlicePointsEditor> {
  AudioSource? _audioSource;
  SoundHandle? _activeHandle;
  int _playingSlice = -1;
  bool _loadingAudio = false;
  List<(double, double)>? _waveformPeaks;

  @override
  void initState() {
    super.initState();
    _computeWaveformPeaks();
  }

  @override
  void didUpdateWidget(SlicePointsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wavBytes != widget.wavBytes) {
      _disposeAudio();
      _computeWaveformPeaks();
    }
  }

  void _computeWaveformPeaks() {
    final wavBytes = widget.wavBytes;
    if (wavBytes != null) {
      _waveformPeaks = wavToWaveformPeaks(wavBytes);
    } else {
      _waveformPeaks = null;
    }
  }

  @override
  void dispose() {
    _disposeAudio();
    super.dispose();
  }

  void _disposeAudio() {
    final source = _audioSource;
    if (source != null) {
      SoLoud.instance.disposeSource(source);
    }
    _audioSource = null;
    _activeHandle = null;
    _playingSlice = -1;
  }

  Future<void> _playSlice(int sliceIndex) async {
    final wavBytes = widget.wavBytes;
    if (wavBytes == null || _loadingAudio) {
      return;
    }

    final soloud = SoLoud.instance;

    // Stop any currently playing slice
    if (_activeHandle != null) {
      await soloud.stop(_activeHandle!);
      _activeHandle = null;
    }

    // Initialize engine and load audio if needed
    if (_audioSource == null) {
      setState(() => _loadingAudio = true);
      if (!soloud.isInitialized) {
        await soloud.init();
      }
      _audioSource = await soloud.loadMem('sample.wav', wavBytes);
      if (mounted) {
        setState(() => _loadingAudio = false);
      } else {
        return;
      }
    }

    final source = _audioSource!;
    final totalDuration = soloud.getLength(source);

    final startFraction = widget.slicePoints[sliceIndex];
    final endFraction = sliceIndex < 7
        ? widget.slicePoints[sliceIndex + 1]
        : 1.0;

    final startTime = totalDuration * startFraction;
    final sliceDuration = totalDuration * (endFraction - startFraction);

    final handle = await soloud.play(source, paused: true);
    soloud.seek(handle, startTime);
    soloud.setPause(handle, false);
    soloud.scheduleStop(handle, sliceDuration);

    setState(() {
      _activeHandle = handle;
      _playingSlice = sliceIndex;
    });

    // Reset playing state when the slice finishes
    await Future<void>.delayed(sliceDuration);
    if (mounted && _playingSlice == sliceIndex) {
      setState(() {
        _activeHandle = null;
        _playingSlice = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Slice points',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            TextButton(
              onPressed: widget.enabled
                  ? () => widget.onChanged(List.of(defaultSlicePoints))
                  : null,
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: SlicePointsPainter(
              slicePoints: widget.slicePoints,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              waveformPeaks: _waveformPeaks,
            ),
            size: const Size(double.infinity, 80),
          ),
        ),
        const SizedBox(height: 8),
        if (_loadingAudio)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading audio...'),
              ],
            ),
          ),
        for (var i = 0; i < 8; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    'Slice ${i + 1}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  icon: Icon(
                    _playingSlice == i ? Icons.stop : Icons.play_arrow,
                    size: 18,
                  ),
                  onPressed: widget.wavBytes != null && !_loadingAudio
                      ? () => _playSlice(i)
                      : null,
                  tooltip: 'Preview slice ${i + 1}',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: widget.slicePoints[i],
                    onChanged: widget.enabled
                        ? (value) {
                            final gap = widget.pcmFrameCount != null
                                ? minSliceSamples / widget.pcmFrameCount!
                                : 0.0;
                            final min = i > 0
                                ? widget.slicePoints[i - 1] + gap
                                : 0.0;
                            final max = i < 7
                                ? widget.slicePoints[i + 1] - gap
                                : 1.0 - gap;
                            final clamped = value.clamp(min, max);
                            final updated = List<double>.from(
                              widget.slicePoints,
                            );
                            updated[i] = double.parse(
                              clamped.toStringAsFixed(3),
                            );
                            widget.onChanged(updated);
                          }
                        : null,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${(widget.slicePoints[i] * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (widget.pitched)
                  SliceNoteDropdown(
                    note: widget.sliceNotes[i],
                    enabled: widget.enabled,
                    onChanged: (value) {
                      final updated = List<int>.from(widget.sliceNotes);
                      updated[i] = value;
                      widget.onSliceNotesChanged?.call(updated);
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
