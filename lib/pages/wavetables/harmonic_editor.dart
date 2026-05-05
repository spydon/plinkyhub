import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plinkyhub/pages/wavetables/utils/fft.dart';

/// Interactive bar chart for editing harmonic magnitudes.
///
/// Displays N/2 harmonics as vertical bars that the user can draw on.
/// Changes are bidirectionally synced with the time-domain waveform
/// via FFT/IFFT.
class HarmonicEditor extends StatefulWidget {
  const HarmonicEditor({
    required this.samples,
    required this.onSamplesChanged,
    this.postEffectSamples,
    this.height = 200,
    super.key,
  });

  final List<double> samples;
  final List<double>? postEffectSamples;
  final ValueChanged<List<double>> onSamplesChanged;
  final double height;

  @override
  State<HarmonicEditor> createState() => _HarmonicEditorState();
}

class _HarmonicEditorState extends State<HarmonicEditor> {
  void _applyDrawAt(Offset localPosition, Size canvasSize) {
    final sampleCount = widget.samples.length;
    final harmonicCount = sampleCount ~/ 2;
    final visibleCount = min(harmonicCount, 128);

    final harmonicIndex = (localPosition.dx / canvasSize.width * visibleCount)
        .floor()
        .clamp(0, visibleCount - 1);
    final magnitude = (1.0 - localPosition.dy / canvasSize.height).clamp(
      0.0,
      1.0,
    );

    // Forward FFT to get current spectrum.
    final complexData = samplesToComplex(widget.samples);
    fft(complexData);

    // Extract harmonics, modify, and apply back.
    final harmonics = spectrumToHarmonics(complexData);

    // Find peak to scale drawing relative to it.
    var peak = 0.0;
    for (final harmonic in harmonics) {
      if (harmonic > peak) {
        peak = harmonic;
      }
    }
    final scale = peak > 1e-10 ? peak : 1.0;

    harmonics[harmonicIndex] = magnitude * scale;
    applyHarmonicsToSpectrum(harmonics, complexData);

    // Inverse FFT back to time domain.
    fft(complexData, inverse: true);
    final newSamples = complexToSamples(complexData);

    widget.onSamplesChanged(newSamples);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, widget.height);
        return GestureDetector(
          onPanStart: (details) =>
              _applyDrawAt(details.localPosition, canvasSize),
          onPanUpdate: (details) =>
              _applyDrawAt(details.localPosition, canvasSize),
          onTapDown: (details) =>
              _applyDrawAt(details.localPosition, canvasSize),
          child: MouseRegion(
            cursor: SystemMouseCursors.precise,
            child: CustomPaint(
              size: canvasSize,
              painter: _HarmonicPainter(
                harmonics: _computeHarmonics(widget.samples),
                postEffectHarmonics: widget.postEffectSamples != null
                    ? _computeHarmonics(widget.postEffectSamples!)
                    : null,
                barColor: Theme.of(context).colorScheme.tertiary,
                ghostColor: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: 0.25),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow,
              ),
            ),
          ),
        );
      },
    );
  }

  static List<double> _computeHarmonics(List<double> samples) {
    final complexData = samplesToComplex(samples);
    fft(complexData);
    return spectrumToHarmonics(complexData);
  }
}

class _HarmonicPainter extends CustomPainter {
  _HarmonicPainter({
    required this.harmonics,
    required this.barColor,
    required this.ghostColor,
    required this.backgroundColor,
    this.postEffectHarmonics,
  });

  final List<double> harmonics;
  final List<double>? postEffectHarmonics;
  final Color barColor;
  final Color ghostColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Background.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(8),
      ),
      Paint()..color = backgroundColor,
    );

    if (harmonics.isEmpty) {
      return;
    }

    // Find peak for normalisation.
    var peak = 0.0;
    for (final harmonic in harmonics) {
      if (harmonic > peak) {
        peak = harmonic;
      }
    }
    if (postEffectHarmonics != null) {
      for (final harmonic in postEffectHarmonics!) {
        if (harmonic > peak) {
          peak = harmonic;
        }
      }
    }
    if (peak < 1e-10) {
      return;
    }

    final harmonicCount = harmonics.length;
    // Show at most 128 harmonics for readability.
    final visibleCount = min(harmonicCount, 128);
    final barWidth = size.width / visibleCount;

    // Ghost bars (post-effect harmonics).
    if (postEffectHarmonics != null) {
      final ghostPaint = Paint()..color = ghostColor;
      final ghostVisibleCount = min(postEffectHarmonics!.length, 128);
      for (var i = 0; i < ghostVisibleCount; i++) {
        final normalised = postEffectHarmonics![i] / peak;
        final barHeight = normalised * size.height;
        canvas.drawRect(
          Rect.fromLTWH(
            i * barWidth,
            size.height - barHeight,
            max(barWidth - 1, 1),
            barHeight,
          ),
          ghostPaint,
        );
      }
    }

    // Main harmonic bars.
    final barPaint = Paint()..color = barColor;
    for (var i = 0; i < visibleCount; i++) {
      final normalised = harmonics[i] / peak;
      final barHeight = normalised * size.height;
      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - barHeight,
          max(barWidth - 1, 1),
          barHeight,
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HarmonicPainter oldDelegate) => true;
}
