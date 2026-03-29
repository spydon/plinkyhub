import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SlicePointsPainter extends CustomPainter {
  const SlicePointsPainter({
    required this.slicePoints,
    required this.color,
    required this.backgroundColor,
    this.waveformPeaks,
  });

  final List<double> slicePoints;
  final Color color;
  final Color backgroundColor;

  /// Min/max amplitude pairs for waveform visualization.
  final List<(double, double)>? waveformPeaks;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    final roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(roundedRect, backgroundPaint);

    canvas.save();
    canvas.clipRRect(roundedRect);

    final peaks = waveformPeaks;
    if (peaks != null && peaks.isNotEmpty) {
      _paintWaveform(canvas, size, peaks);
    }

    canvas.restore();

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2;

    for (final point in slicePoints) {
      final x = point * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }
  }

  void _paintWaveform(
    Canvas canvas,
    Size size,
    List<(double, double)> peaks,
  ) {
    final centerY = size.height / 2;
    final bucketCount = peaks.length;
    final bucketWidth = size.width / bucketCount;

    final waveformPath = Path();
    // Draw top edge (max values) left to right
    for (var i = 0; i < bucketCount; i++) {
      final x = i * bucketWidth + bucketWidth / 2;
      final (_, maxValue) = peaks[i];
      final y = centerY - maxValue * centerY;
      if (i == 0) {
        waveformPath.moveTo(x, y);
      } else {
        waveformPath.lineTo(x, y);
      }
    }
    // Draw bottom edge (min values) right to left
    for (var i = bucketCount - 1; i >= 0; i--) {
      final x = i * bucketWidth + bucketWidth / 2;
      final (minValue, _) = peaks[i];
      final y = centerY - minValue * centerY;
      waveformPath.lineTo(x, y);
    }
    waveformPath.close();

    final waveformPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [
          color.withValues(alpha: 0.4),
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.4),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawPath(waveformPath, waveformPaint);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerLinePaint,
    );
  }

  @override
  bool shouldRepaint(SlicePointsPainter oldDelegate) =>
      slicePoints != oldDelegate.slicePoints ||
      color != oldDelegate.color ||
      backgroundColor != oldDelegate.backgroundColor ||
      waveformPeaks != oldDelegate.waveformPeaks;
}
