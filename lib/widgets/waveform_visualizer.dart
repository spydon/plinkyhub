import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plinkyhub/state/midi_state.dart';

/// Plinky-style oscilloscope visualization.
///
/// Mimics the firmware's scope rendering: discrete pixel columns, trigger
/// detection to stabilize the waveform, and dual-channel (L+R) plotting
/// with audio samples mapped to a 32-row vertical grid.
class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({
    required this.activeNotes,
    super.key,
  });

  final Map<int, ActiveNote> activeNotes;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ScopePainter(
            activeNotes: widget.activeNotes,
            phase: _controller.value * 2 * pi,
            color: theme.colorScheme.primary,
            idleColor: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Scope resolution matching the Plinky OLED: 128 columns × 32 rows.
const _scopeWidth = 128;

/// Number of oversampled audio points to generate before trigger detection.
/// The firmware uses 256 samples compressed into 128 columns (2:1).
const _sampleCount = 512;

class _ScopePainter extends CustomPainter {
  _ScopePainter({
    required this.activeNotes,
    required this.phase,
    required this.color,
    required this.idleColor,
  });

  final Map<int, ActiveNote> activeNotes;
  final double phase;
  final Color color;
  final Color idleColor;

  static double _midiToFrequency(int note) {
    return 440.0 * pow(2, (note - 69) / 12);
  }

  /// Synthesize a sample value at time [t] from all active notes.
  /// Returns a value roughly in [-1, 1].
  double _synthesize(double t, List<ActiveNote> notes, double totalAmp) {
    var y = 0.0;
    for (final note in notes) {
      final freq = _midiToFrequency(note.note);
      final amp = note.velocity / 127.0 / max(totalAmp, 1.0);
      // Fundamental + harmonics matching a rich Plinky-like timbre.
      y += amp * sin(2 * pi * freq * t + phase);
      y += amp * 0.5 * sin(2 * pi * freq * 2 * t + phase * 2);
      y += amp * 0.33 * sin(2 * pi * freq * 3 * t + phase * 3);
      y += amp * 0.25 * sin(2 * pi * freq * 4 * t + phase * 4);
    }
    // Normalize so the harmonic sum doesn't clip.
    return y / 2.08;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (activeNotes.isEmpty) {
      final paint = Paint()
        ..color = idleColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final centerY = size.height / 2;
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        paint,
      );
      return;
    }

    final notes = activeNotes.values.toList();
    final totalAmp = notes.fold<double>(
      0,
      (sum, n) => sum + n.velocity / 127.0,
    );

    // Determine the lowest frequency to set the time window.
    final lowestFreq = notes
        .map((n) => _midiToFrequency(n.note))
        .reduce(min);
    // Generate enough samples to cover ~4 cycles for trigger detection.
    final windowSeconds = 4.0 / lowestFreq;
    final dt = windowSeconds / _sampleCount;

    // Generate raw samples.
    final samples = List<double>.generate(
      _sampleCount,
      (i) => _synthesize(i * dt, notes, totalAmp),
    );

    // Trigger detection: find a rising zero-crossing with the largest
    // preceding peak-to-trough swing, matching the firmware's edge
    // detection logic.
    var triggerIndex = 0;
    var bestEdge = 0.0;
    var prevSample = samples[0];
    var troughVal = samples[0];

    for (var i = 1; i < _sampleCount - _scopeWidth * 2; i++) {
      final s = samples[i];
      if (s < troughVal) {
        troughVal = s;
      }
      // Rising zero-crossing.
      if (prevSample <= 0 && s > 0) {
        final edgeSize = s - troughVal;
        if (edgeSize > bestEdge) {
          bestEdge = edgeSize;
          triggerIndex = i;
        }
      }
      prevSample = s;
    }

    // Build a smooth path from triggered samples, using the same
    // 2:1 compression and vertical mapping as the firmware scope.
    final path = Path();
    final centerY = size.height / 2;
    final scaleY = size.height * 0.44;
    final stepX = size.width / _scopeWidth;

    for (var x = 0; x < _scopeWidth; x++) {
      final sampleIdx = triggerIndex + x * 2;
      if (sampleIdx >= _sampleCount) {
        break;
      }
      final s = samples[sampleIdx];
      final px = x * stepX;
      final py = centerY - s * scaleY;

      if (x == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }

    // Glow behind the main line.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    // Main waveform line.
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScopePainter oldDelegate) => true;
}
