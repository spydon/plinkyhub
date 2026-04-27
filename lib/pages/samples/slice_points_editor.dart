import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/slice_note_dropdown.dart';
import 'package:plinkyhub/pages/samples/slice_points_painter.dart';
import 'package:plinkyhub/services/sound_service.dart';
import 'package:plinkyhub/utils/wav.dart';

class SlicePointsEditor extends ConsumerStatefulWidget {
  const SlicePointsEditor({
    required this.slicePoints,
    required this.wavBytes,
    required this.enabled,
    required this.onChanged,
    required this.sampleName,
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
  final String sampleName;

  /// Total number of PCM frames after conversion to Plinky format.
  /// When provided, the editor enforces a minimum gap of [minSliceSamples]
  /// between adjacent slice points.
  final int? pcmFrameCount;
  final bool pitched;
  final List<int> sliceNotes;
  final ValueChanged<List<int>>? onSliceNotesChanged;

  @override
  ConsumerState<SlicePointsEditor> createState() => _SlicePointsEditorState();
}

class _SlicePointsEditorState extends ConsumerState<SlicePointsEditor>
    with SingleTickerProviderStateMixin {
  AudioSource? _audioSource;
  int? _playingSlice;
  int? _pausedSlice;
  int? _loadingSliceIndex;
  List<(double, double)>? _waveformPeaks;
  int _draggingIndex = -1;
  bool _isNearLine = false;

  late final Ticker _progressTicker;
  double? _playbackProgress;
  double _playbackStartFraction = 0;
  double _playbackEndFraction = 1;
  Duration _playbackSliceDuration = Duration.zero;
  DateTime? _playbackStartTime;
  Duration? _pausedElapsed;

  @override
  void initState() {
    super.initState();
    _progressTicker = createTicker(_onTick);
    _computeWaveformPeaks();
  }

  @override
  void didUpdateWidget(SlicePointsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wavBytes != widget.wavBytes) {
      _audioSource = null;
      _stopProgressTracking();
      _computeWaveformPeaks();
    }
  }

  void _computeWaveformPeaks() {
    final wavBytes = widget.wavBytes;
    if (wavBytes != null) {
      try {
        _waveformPeaks = wavToWaveformPeaks(wavBytes);
      } on Object catch (error) {
        debugPrint('Failed to compute waveform peaks: $error');
        _waveformPeaks = null;
      }
    } else {
      _waveformPeaks = null;
    }
  }

  void _onTick(Duration elapsed) {
    final startTime = _playbackStartTime;
    if (startTime == null) {
      return;
    }
    final elapsed = DateTime.now().difference(startTime);
    final fraction = _playbackSliceDuration.inMicroseconds > 0
        ? elapsed.inMicroseconds / _playbackSliceDuration.inMicroseconds
        : 1.0;
    if (fraction >= 1.0) {
      _stopProgressTracking();
      return;
    }
    final range = _playbackEndFraction - _playbackStartFraction;
    setState(() {
      _playbackProgress = _playbackStartFraction + range * fraction;
    });
  }

  void _startProgressTracking({
    required double startFraction,
    required double endFraction,
    required Duration sliceDuration,
  }) {
    _playbackStartFraction = startFraction;
    _playbackEndFraction = endFraction;
    _playbackSliceDuration = sliceDuration;
    _playbackStartTime = DateTime.now();
    _playbackProgress = startFraction;
    if (!_progressTicker.isActive) {
      _progressTicker.start();
    }
  }

  void _stopProgressTracking() {
    if (_progressTicker.isActive) {
      _progressTicker.stop();
    }
    _playbackStartTime = null;
    _pausedElapsed = null;
    setState(() {
      _playbackProgress = null;
      _playingSlice = null;
      _pausedSlice = null;
    });
  }

  @override
  void dispose() {
    ref.read(soundServiceProvider).stopPreview();
    _progressTicker.dispose();
    _audioSource = null;
    _playingSlice = null;
    _pausedSlice = null;
    super.dispose();
  }

  void _pauseSlice() {
    final soundService = ref.read(soundServiceProvider);
    soundService.setPaused(paused: true);
    _pausedElapsed = _playbackStartTime != null
        ? DateTime.now().difference(_playbackStartTime!)
        : Duration.zero;
    if (_progressTicker.isActive) {
      _progressTicker.stop();
    }
    setState(() {
      _pausedSlice = _playingSlice;
      _playingSlice = null;
    });
  }

  void _resumeSlice() {
    final soundService = ref.read(soundServiceProvider);
    soundService.setPaused(paused: false);
    _playbackStartTime = DateTime.now().subtract(
      _pausedElapsed ?? Duration.zero,
    );
    _pausedElapsed = null;
    if (!_progressTicker.isActive) {
      _progressTicker.start();
    }
    setState(() {
      _playingSlice = _pausedSlice;
      _pausedSlice = null;
    });
  }

  Future<void> _playSlice(int sliceIndex) async {
    final wavBytes = widget.wavBytes;
    if (wavBytes == null || _loadingSliceIndex != null) {
      return;
    }

    _pausedSlice = null;
    _pausedElapsed = null;

    try {
      final soundService = ref.read(soundServiceProvider);

      // Load audio if needed
      if (_audioSource == null) {
        setState(() => _loadingSliceIndex = sliceIndex);
        _audioSource = await soundService.loadSource(
          '${widget.sampleName}.wav',
          wavBytes,
        );
        if (mounted) {
          setState(() => _loadingSliceIndex = null);
        } else {
          return;
        }
      }

      final source = _audioSource!;
      final startFraction = widget.slicePoints[sliceIndex];
      final endFraction = sliceIndex < 7
          ? widget.slicePoints[sliceIndex + 1]
          : 1.0;

      await soundService.playSlice(
        source,
        startFraction: startFraction,
        endFraction: endFraction,
      );

      final totalDuration = soundService.getLength(source);
      final sliceDuration = totalDuration * (endFraction - startFraction);

      setState(() => _playingSlice = sliceIndex);
      _startProgressTracking(
        startFraction: startFraction,
        endFraction: endFraction,
        sliceDuration: sliceDuration,
      );
    } on Exception catch (error) {
      debugPrint('Failed to play slice: $error');
      if (mounted) {
        _stopProgressTracking();
        setState(() => _loadingSliceIndex = null);
      }
    }
  }

  static const double _hitPixels = 6;

  bool _isNearSliceLine(double localX, double width) {
    for (final point in widget.slicePoints) {
      if ((point * width - localX).abs() < _hitPixels) {
        return true;
      }
    }
    return false;
  }

  void _onHover(PointerEvent event, double width) {
    if (!widget.enabled || width <= 0) {
      return;
    }
    final nearLine = _isNearSliceLine(event.localPosition.dx, width);
    if (nearLine != _isNearLine) {
      setState(() => _isNearLine = nearLine);
    }
  }

  void _onDragDown(DragDownDetails details, double width) {
    if (!widget.enabled || width <= 0) {
      return;
    }
    final localX = details.localPosition.dx;
    var closestIndex = -1;
    var closestPixelDistance = double.infinity;
    final points = widget.slicePoints;
    for (var i = 0; i < points.length; i++) {
      final pixelDistance = (points[i] * width - localX).abs();
      if (pixelDistance < closestPixelDistance) {
        closestPixelDistance = pixelDistance;
        closestIndex = i;
      }
    }
    if (closestIndex >= 0 && closestPixelDistance < _hitPixels) {
      setState(() => _draggingIndex = closestIndex);
    }
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    final i = _draggingIndex;
    if (i < 0 || i >= widget.slicePoints.length || width <= 0) {
      return;
    }
    final fractionX = (details.localPosition.dx / width).clamp(0.0, 1.0);
    final gap = widget.pcmFrameCount != null
        ? minSliceSamples / widget.pcmFrameCount!
        : 0.0;
    final min = i > 0 ? widget.slicePoints[i - 1] + gap : 0.0;
    final max = i < 7 ? widget.slicePoints[i + 1] - gap : 1.0 - gap;
    if (min > max) {
      return;
    }
    final clamped = fractionX.clamp(min, max);
    final updated = List<double>.from(widget.slicePoints);
    updated[i] = double.parse(clamped.toStringAsFixed(3));
    widget.onChanged(updated);
  }

  void _onDragEnd() {
    if (_draggingIndex >= 0) {
      setState(() => _draggingIndex = -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text.rich(
              TextSpan(
                text: 'Slice points ',
                style: Theme.of(context).textTheme.titleSmall,
                children: [
                  TextSpan(
                    text: '(you can drag the lines)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
        LayoutBuilder(
          builder: (context, constraints) {
            return MouseRegion(
              onHover: (event) => _onHover(event, constraints.maxWidth),
              onExit: (_) {
                if (_isNearLine) {
                  setState(() => _isNearLine = false);
                }
              },
              cursor: _isNearLine || _draggingIndex >= 0
                  ? SystemMouseCursors.resizeColumn
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                onPanDown: (details) =>
                    _onDragDown(details, constraints.maxWidth),
                onPanUpdate: (details) =>
                    _onDragUpdate(details, constraints.maxWidth),
                onPanEnd: (_) => _onDragEnd(),
                onPanCancel: _onDragEnd,
                child: SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: SlicePointsPainter(
                      slicePoints: widget.slicePoints,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      waveformPeaks: _waveformPeaks,
                      playbackProgress: _playbackProgress,
                      progressColor: const Color(0xFFFF4081),
                    ),
                    size: const Size(double.infinity, 200),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
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
                SizedBox(
                  width: 32,
                  height: 32,
                  child: _loadingSliceIndex == i
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton.filled(
                          icon: Icon(
                            _playingSlice == i ? Icons.pause : Icons.play_arrow,
                            size: 18,
                          ),
                          onPressed: widget.wavBytes != null
                              ? () {
                                  if (_playingSlice == i) {
                                    _pauseSlice();
                                  } else if (_pausedSlice == i) {
                                    _resumeSlice();
                                  } else {
                                    _playSlice(i);
                                  }
                                }
                              : null,
                          tooltip: 'Preview slice ${i + 1}',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
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
