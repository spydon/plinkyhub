import 'dart:math';

import 'package:flutter/material.dart';

class ArcIconButton extends StatefulWidget {
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
  State<ArcIconButton> createState() => _ArcIconButtonState();
}

class _ArcIconButtonState extends State<ArcIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hovered) {
    if (hovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.arcColor ??
        (widget.isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.4));
    final foreground = widget.iconColor ??
        (widget.isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface);

    return InkWell(
      onTap: widget.onPressed,
      onHover: _onHover,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) => CustomPaint(
            painter: _ArcPainter(
              color: color,
              gapAngle: widget.gapAngle,
              strokeWidth: widget.strokeWidth,
              isSelected: widget.isSelected,
              hoverProgress: _hoverController.value,
            ),
            child: child,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: foreground,
                  size: widget.size * 0.3,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: widget.textStyle ??
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

double _lerp(double a, double b, double t) => a + (b - a) * t;

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.color,
    required this.gapAngle,
    required this.strokeWidth,
    required this.isSelected,
    required this.hoverProgress,
  });

  final Color color;
  final double gapAngle;
  final double strokeWidth;
  final bool isSelected;
  final double hoverProgress;

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
    canvas.drawArc(
      rect, pi / 2 + gapAngle / 2, sweepAngle, false, paint,
    );

    // Right arc: from top-right to bottom-right
    canvas.drawArc(
      rect, -pi / 2 + gapAngle / 2, sweepAngle, false, paint,
    );

    final glowCenter = Offset(size.width * 0.05, size.height * 0.05);
    final glowRadius = size.width * 0.22;
    final baseColor = isSelected
        ? const Color(0xFF4488FF)
        : const Color(0xFF888888);
    final hoverColor =
        isSelected ? const Color(0xFF4488FF) : Colors.white;
    final glowColor =
        Color.lerp(baseColor, hoverColor, hoverProgress)!;

    final baseInner = isSelected ? 0.7 : 0.4;
    final hoverInner = isSelected ? 0.9 : 0.6;
    final baseMid = isSelected ? 0.2 : 0.1;
    final hoverMid = isSelected ? 0.3 : 0.15;

    // Outer soft glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(
            alpha: _lerp(baseInner, hoverInner, hoverProgress),
          ),
          glowColor.withValues(
            alpha: _lerp(baseMid, hoverMid, hoverProgress),
          ),
          glowColor.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(
        Rect.fromCircle(center: glowCenter, radius: glowRadius),
      );
    canvas.drawCircle(glowCenter, glowRadius, glowPaint);

    // Bright core
    final baseCore = isSelected ? 0.9 : 0.5;
    final hoverCore = isSelected ? 1.0 : 0.8;
    final coreColor = Color.lerp(
      isSelected ? Colors.white : const Color(0xFFAAAAAA),
      Colors.white,
      hoverProgress,
    )!;
    final corePaint = Paint()
      ..color = coreColor.withValues(
        alpha: _lerp(baseCore, hoverCore, hoverProgress),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(glowCenter, 2, corePaint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      color != oldDelegate.color ||
      gapAngle != oldDelegate.gapAngle ||
      strokeWidth != oldDelegate.strokeWidth ||
      isSelected != oldDelegate.isSelected ||
      hoverProgress != oldDelegate.hoverProgress;
}
