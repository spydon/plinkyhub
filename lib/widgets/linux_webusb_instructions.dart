import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

bool get _isLinux =>
    web.window.navigator.userAgent.toLowerCase().contains('linux');

class LinuxWebusbInstructions extends StatefulWidget {
  const LinuxWebusbInstructions({
    super.key,
    this.expanded = false,
  });

  final bool expanded;

  @override
  State<LinuxWebusbInstructions> createState() =>
      _LinuxWebusbInstructionsState();
}

class _LinuxWebusbInstructionsState extends State<LinuxWebusbInstructions> {
  final _controller = ExpansibleController();

  @override
  void didUpdateWidget(LinuxWebusbInstructions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded && !oldWidget.expanded) {
      _controller.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLinux) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        controller: _controller,
        leading: const Icon(Icons.info_outline),
        title: const Text('Linux: WebUSB access denied?'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _InstructionStep(
            number: '1',
            title: 'Add your user to the plugdev group:',
            code: r'sudo usermod -a -G plugdev $USER',
            detail: 'Log out and back in for the change to take effect.',
          ),
          _InstructionStep(
            number: '2',
            title: 'Create a udev rule:',
            code:
                'echo \'SUBSYSTEM=="usb", ATTRS{idVendor}=="cafe", '
                'MODE="0660", GROUP="plugdev"\' '
                '| sudo tee /etc/udev/rules.d/99-plinky.rules',
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
          _InstructionStep(
            number: '5',
            title: 'If your browser is installed via snap, '
                'grant USB access:',
            code: 'sudo snap connect chromium:raw-usb',
            detail: 'Replace "chromium" with your browser\'s '
                'snap name if different.',
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
          if (detail != null) SelectableText(detail!),
        ],
      ),
    );
  }
}
