import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareLinkButton extends StatelessWidget {
  const ShareLinkButton({
    required this.username,
    required this.itemType,
    required this.itemName,
    super.key,
  });

  final String username;
  final String itemType;
  final String itemName;

  String get itemPath {
    final encodedName = Uri.encodeComponent(itemName);
    return '/$username/$itemType/$encodedName';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share, size: 20),
      tooltip: 'Copy link',
      onPressed: () {
        final base = Uri.base;
        final url = Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.port,
          path: itemPath,
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
