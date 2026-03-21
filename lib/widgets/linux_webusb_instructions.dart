import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

bool get _isLinux =>
    web.window.navigator.userAgent.toLowerCase().contains('linux');

class LinuxWebusbInstructions extends StatelessWidget {
  const LinuxWebusbInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    if (!_isLinux) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: ExpansionTile(
        leading: Icon(Icons.info_outline),
        title: Text('Linux: WebUSB access denied?'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: 8),
        children: [
          _InstructionStep(
            number: '1',
            title: 'Add your user to the plugdev group:',
            code: r'sudo usermod -a -G plugdev $USER',
            detail: 'Log out and back in for the change to take effect.',
          ),
          _InstructionStep(
            number: '2',
            title: 'Create a udev rule:',
            code: 'sudo nano /etc/udev/rules.d/99-plinky.rules',
            detail:
                'Add the following line:\n'
                'SUBSYSTEM=="usb", ATTRS{idVendor}=="cafe", '
                'MODE="0660", GROUP="plugdev"',
          ),
          _InstructionStep(
            number: '3',
            title: 'Reload udev rules:',
            code: 'sudo udevadm control --reload-rules',
          ),
          _InstructionStep(
            number: '4',
            title: 'Reconnect Plinky',
            detail: 'Unplug and replug the USB cable.',
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.title,
    this.code,
    this.detail,
  });

  final String number;
  final String title;
  final String? code;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (code != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                code!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
            ),
          if (detail != null)
            SelectableText(detail!),
        ],
      ),
    );
  }
}
