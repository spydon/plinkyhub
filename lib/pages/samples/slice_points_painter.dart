import 'package:flutter/material.dart';

class SlicePointsPainter extends CustomPainter {
  const SlicePointsPainter({
    required this.slicePoints,
    required this.color,
    required this.backgroundColor,
  });

  final List<double> slicePoints;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(4),
      ),
      backgroundPaint,
    );

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

  @override
  bool shouldRepaint(SlicePointsPainter oldDelegate) =>
      slicePoints != oldDelegate.slicePoints ||
      color != oldDelegate.color ||
      backgroundColor != oldDelegate.backgroundColor;
}
