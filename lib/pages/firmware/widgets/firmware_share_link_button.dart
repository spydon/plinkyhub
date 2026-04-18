import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirmwareShareLinkButton extends StatelessWidget {
  const FirmwareShareLinkButton({
    required this.firmwareName,
    super.key,
  });

  final String firmwareName;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share, size: 20),
      tooltip: 'Copy link',
      onPressed: () {
        final encodedName = Uri.encodeComponent(firmwareName);
        final base = Uri.base;
        final url = Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.port,
          path: '/firmware/$encodedName',
        ).toString();
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard'),
          ),
        );
      },
    );
  }
}
