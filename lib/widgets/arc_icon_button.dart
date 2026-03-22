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
    with TickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final AnimationController _selectionController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _selectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isSelected ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(ArcIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _selectionController.dispose();
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
    final selectedColor = widget.arcColor ?? theme.colorScheme.primary;
    final unselectedColor = widget.arcColor ??
        theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final selectedForeground =
        widget.iconColor ?? theme.colorScheme.primary;
    final unselectedForeground =
        widget.iconColor ?? theme.colorScheme.onSurface;

    return InkWell(
      onTap: widget.onPressed,
      onHover: _onHover,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _hoverController,
            _selectionController,
          ]),
          builder: (context, child) {
            final selection = _selectionController.value;
            final color = Color.lerp(
              unselectedColor,
              selectedColor,
              selection,
            )!;
            final foreground = Color.lerp(
              unselectedForeground,
              selectedForeground,
              selection,
            )!;
            return IconTheme(
              data: IconThemeData(
                color: foreground,
                size: widget.size * 0.3,
              ),
              child: DefaultTextStyle(
                style: widget.textStyle ??
                    theme.textTheme.labelSmall!.copyWith(
                      color: foreground,
                    ),
                textAlign: TextAlign.center,
                child: CustomPaint(
                  painter: _ArcPainter(
                    color: color,
                    gapAngle: widget.gapAngle,
                    strokeWidth: widget.strokeWidth,
                    selectionProgress: selection,
                    hoverProgress: _hoverController.value,
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon),
                const SizedBox(height: 2),
                Text(widget.label),
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
    required this.selectionProgress,
    required this.hoverProgress,
  });

  final Color color;
  final double gapAngle;
  final double strokeWidth;
  final double selectionProgress;
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
    final fullSweep = pi - gapAngle;
    final sweepAngle = fullSweep * 0.85;
    final offset = (fullSweep - sweepAngle) / 2;
    canvas.drawArc(
      rect, pi / 2 + gapAngle / 2 + offset, sweepAngle, false, paint,
    );

    // Right arc: from top-right to bottom-right
    canvas.drawArc(
      rect, -pi / 2 + gapAngle / 2 + offset, sweepAngle, false, paint,
    );

    final glowCenter = Offset(size.width * 0.05, size.height * 0.05);
    final glowRadius = size.width * 0.22;
    final s = selectionProgress;
    final h = hoverProgress;

    final baseColor = Color.lerp(
      const Color(0xFF888888),
      const Color(0xFF4488FF),
      s,
    )!;
    final hoverColor = Color.lerp(Colors.white, baseColor, s)!;
    final glowColor = Color.lerp(baseColor, hoverColor, h)!;

    final baseInner = _lerp(0.4, 0.7, s);
    final hoverInner = _lerp(0.6, 0.9, s);
    final baseMid = _lerp(0.1, 0.2, s);
    final hoverMid = _lerp(0.15, 0.3, s);

    // Outer soft glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(
            alpha: _lerp(baseInner, hoverInner, h),
          ),
          glowColor.withValues(
            alpha: _lerp(baseMid, hoverMid, h),
          ),
          glowColor.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(
        Rect.fromCircle(center: glowCenter, radius: glowRadius),
      );
    canvas.drawCircle(glowCenter, glowRadius, glowPaint);

    // Bright core
    final baseCore = _lerp(0.5, 0.9, s);
    final hoverCore = _lerp(0.8, 1.0, s);
    final coreColor = Color.lerp(
      Color.lerp(
        const Color(0xFFAAAAAA),
        Colors.white,
        s,
      ),
      Colors.white,
      h,
    )!;
    final corePaint = Paint()
      ..color = coreColor.withValues(
        alpha: _lerp(baseCore, hoverCore, h),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(glowCenter, 2, corePaint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      color != oldDelegate.color ||
      gapAngle != oldDelegate.gapAngle ||
      strokeWidth != oldDelegate.strokeWidth ||
      selectionProgress != oldDelegate.selectionProgress ||
      hoverProgress != oldDelegate.hoverProgress;
}
