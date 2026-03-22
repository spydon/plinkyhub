import 'dart:math';

import 'package:flutter/material.dart';

class ArcIconButton extends StatelessWidget {
  const ArcIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isSelected = false,
    this.size = 80,
    this.arcColor,
    this.iconColor,
    this.textStyle,
    this.gapAngle = 0.8,
    this.strokeWidth = 3,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final double size;
  final Color? arcColor;
  final Color? iconColor;
  final TextStyle? textStyle;

  /// The angular gap at the top and bottom of the circle, in radians.
  final double gapAngle;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = arcColor ??
        (isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.4));
    final foreground = iconColor ??
        (isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface);

    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ArcPainter(
            color: color,
            gapAngle: gapAngle,
            strokeWidth: strokeWidth,
            isSelected: isSelected,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: size * 0.3),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: textStyle ??
                      theme.textTheme.labelSmall?.copyWith(
                        color: foreground,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.color,
    required this.gapAngle,
    required this.strokeWidth,
    required this.isSelected,
  });

  final Color color;
  final double gapAngle;
  final double strokeWidth;
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Left arc: from bottom-left to top-left
    final sweepAngle = pi - gapAngle;
    canvas.drawArc(rect, pi / 2 + gapAngle / 2, sweepAngle, false, paint);

    // Right arc: from top-right to bottom-right
    canvas.drawArc(rect, -pi / 2 + gapAngle / 2, sweepAngle, false, paint);

    final glowCenter = Offset(size.width * 0.05, size.height * 0.05);
    final glowRadius = size.width * 0.22;
    final glowColor =
        isSelected ? const Color(0xFF4488FF) : const Color(0xFF888888);

    // Outer soft glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: isSelected ? 0.7 : 0.4),
          glowColor.withValues(alpha: isSelected ? 0.2 : 0.1),
          glowColor.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(
        Rect.fromCircle(center: glowCenter, radius: glowRadius),
      );
    canvas.drawCircle(glowCenter, glowRadius, glowPaint);

    // Bright core
    final corePaint = Paint()
      ..color = (isSelected ? Colors.white : const Color(0xFFAAAAAA))
          .withValues(alpha: isSelected ? 0.9 : 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(glowCenter, 2, corePaint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      color != oldDelegate.color ||
      gapAngle != oldDelegate.gapAngle ||
      strokeWidth != oldDelegate.strokeWidth ||
      isSelected != oldDelegate.isSelected;
}
