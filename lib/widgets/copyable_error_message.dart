import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Renders an error string with a copy-to-clipboard button next to it so the
/// user can paste the message into a bug report.
class CopyableErrorMessage extends StatelessWidget {
  const CopyableErrorMessage({
    required this.message,
    this.style,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  final String message;
  final TextStyle? style;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(child: Text(message, style: style)),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copy error',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: message));
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error copied to clipboard')),
            );
          },
        ),
      ],
    );
  }
}
