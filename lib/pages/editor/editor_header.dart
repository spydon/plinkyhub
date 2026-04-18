import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/editor/connect_button.dart';
import 'package:plinkyhub/pages/editor/create_preset_button.dart';
import 'package:plinkyhub/pages/editor/widgets/linux_webusb_instructions.dart';
import 'package:plinkyhub/pages/editor/widgets/preset_controls.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_state.dart';

class EditorHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Preset Editor',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: state.connectionState.name,
              child: Icon(
                switch (state.connectionState) {
                  PlinkyConnectionState.connected => Icons.usb,
                  PlinkyConnectionState.connecting => Icons.sync,
                  PlinkyConnectionState.loadingPreset ||
                  PlinkyConnectionState.readingFlashDump => Icons.download,
                  PlinkyConnectionState.savingPreset ||
                  PlinkyConnectionState.sendingSample ||
                  PlinkyConnectionState.sendingWavetable => Icons.upload,
                  PlinkyConnectionState.error => Icons.error_outline,
                  PlinkyConnectionState.disconnected => Icons.usb_off,
                },
                color: switch (state.connectionState) {
                  PlinkyConnectionState.connected ||
                  PlinkyConnectionState.loadingPreset ||
                  PlinkyConnectionState.savingPreset ||
                  PlinkyConnectionState.sendingSample ||
                  PlinkyConnectionState.sendingWavetable ||
                  PlinkyConnectionState.readingFlashDump => Colors.green,
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
          if (!WebUsbService.isSupported) ...[
            const SizedBox(height: 8),
            const Text(
              'Please use a Chromium based browser '
              '(Chrome, Edge). Firefox does not support '
              'WebUSB.',
            ),
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
          ],
          LinuxWebusbInstructions(
            expanded:
                isError &&
                (state.errorMessage?.contains('Access denied') ?? false),
          ),
          if (isError && state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const ConnectButton(),
              if (state.preset == null) ...[
                const SizedBox(width: 8),
                const CreatePresetButton(),
              ],
            ],
          ),
        ],
        if (isConnected) ...[
          const SizedBox(height: 16),
          const PresetControls(),
        ],
      ],
    );
  }
}
