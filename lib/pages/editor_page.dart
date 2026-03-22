import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/widgets/linux_webusb_instructions.dart';
import 'package:plinkyhub/widgets/patch_controls.dart';
import 'package:plinkyhub/widgets/patch_details.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUrlForPatch();
    });
  }

  void _checkUrlForPatch() {
    final uri = Uri.base;
    final patchParameter = uri.queryParameters['p'];
    if (patchParameter != null && patchParameter.isNotEmpty) {
      ref
          .read(plinkyProvider.notifier)
          .parsePatchFromUrl(patchParameter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plinkyProvider);
    final isConnected = switch (state.connectionState) {
      PlinkyConnectionState.connected ||
      PlinkyConnectionState.loadingPatch ||
      PlinkyConnectionState.savingPatch =>
        true,
      _ => false,
    };
    final isError =
        state.connectionState == PlinkyConnectionState.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patch Editor',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Current state: ${state.connectionState.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (isError && state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
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
            const LinuxWebusbInstructions(),
            const SizedBox(height: 8),
            PlinkyButton(
              onPressed: state.connectionState ==
                      PlinkyConnectionState.connecting
                  ? null
                  : () => ref
                      .read(plinkyProvider.notifier)
                      .connect(),
              icon: Icons.usb,
              label: 'Connect',
            ),
          ],
          if (isConnected) ...[
            const SizedBox(height: 16),
            const PatchControls(),
          ],
          const SizedBox(height: 16),
          Text(
            'Current patch',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const PatchDetails(),
        ],
      ),
    );
  }
}
