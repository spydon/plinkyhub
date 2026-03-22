import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinkyhub/widgets/arc_icon_button.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: CustomPaint(
        painter: const _StripePainter(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Plinky\n'),
                  TextSpan(text: 'Hub'),
                ],
              ),
              style: GoogleFonts.fingerPaint(
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ArcIconButton(
              icon: Icons.piano,
              label: 'Editor',
              isSelected: selectedIndex == 0,
              onPressed: () => onDestinationSelected(0),
            ),
            const SizedBox(height: 8),
            ArcIconButton(
              icon: Icons.cloud,
              label: 'My Patches',
              isSelected: selectedIndex == 1,
              onPressed: () => onDestinationSelected(1),
            ),
            const SizedBox(height: 8),
            ArcIconButton(
              icon: Icons.info,
              label: 'About',
              isSelected: selectedIndex == 2,
              onPressed: () => onDestinationSelected(2),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: AuthenticationButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  const _StripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stripePositions = [0.25, 0.5, 0.75];
    for (final position in stripePositions) {
      final x = size.width * position;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(x - 4, 0, 8, size.height))
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(x, size.height * 0.05),
        Offset(x, size.height * 0.95),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter oldDelegate) => false;
}
