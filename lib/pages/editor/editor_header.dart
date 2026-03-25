import 'package:flutter/material.dart';
import 'package:plinkyhub/pages/editor/connect_button.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/widgets/linux_webusb_instructions.dart';
import 'package:plinkyhub/widgets/patch_controls.dart';

class EditorHeader extends StatelessWidget {
  const EditorHeader({
    required this.state,
    required this.isConnected,
    required this.isError,
    super.key,
  });

  final PlinkyState state;
  final bool isConnected;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Patch Editor',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: state.connectionState.name,
              child: Icon(
                switch (state.connectionState) {
                  PlinkyConnectionState.connected => Icons.usb,
                  PlinkyConnectionState.connecting => Icons.sync,
                  PlinkyConnectionState.loadingPatch => Icons.download,
                  PlinkyConnectionState.savingPatch => Icons.upload,
                  PlinkyConnectionState.error => Icons.error_outline,
                  PlinkyConnectionState.disconnected => Icons.usb_off,
                },
                color: switch (state.connectionState) {
                  PlinkyConnectionState.connected ||
                  PlinkyConnectionState.loadingPatch ||
                  PlinkyConnectionState.savingPatch => Colors.green,
                  PlinkyConnectionState.connecting => Colors.orange,
                  PlinkyConnectionState.error => Colors.red,
                  PlinkyConnectionState.disconnected => Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                },
              ),
            ),
          ],
        ),
        if (!isConnected) ...[
          const SizedBox(height: 8),
          const Text(
            'You need the 0.9l firmware (or newer) to use '
            'this. Please use a Chromium based browser '
            '(Chrome, Edge). Firefox does not support '
            'WebUSB.',
          ),
          if (!WebUsbService.isSupported)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'WebUSB is not supported in this browser.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          LinuxWebusbInstructions(
            expanded: isError &&
                (state.errorMessage?.contains('Access denied') ??
                    false),
          ),
          if (isError && state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 8),
          const ConnectButton(),
        ],
        if (isConnected) ...[
          const SizedBox(height: 16),
          const PatchControls(),
        ],
      ],
    );
  }
}
