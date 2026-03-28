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

  String get _path {
    final encodedName = Uri.encodeComponent(itemName);
    return '/$username/$itemType/$encodedName';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share, size: 20),
      tooltip: 'Copy link',
      onPressed: () {
        final uri = Uri.base.replace(
          path: _path,
          query: '',
          fragment: '',
        );
        Clipboard.setData(ClipboardData(text: uri.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      },
    );
  }
}
