import 'package:flutter/material.dart';

class PlinkyButton extends StatelessWidget {
  const PlinkyButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = onPressed != null;
    final foreground = isEnabled
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final background = isEnabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.12);
    final borderColor = isEnabled
        ? colorScheme.primary.withValues(alpha: 0.4)
        : Colors.transparent;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        side: BorderSide(color: borderColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}
