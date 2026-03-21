import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/widgets/patch_controls.dart';
import 'package:plinkyhub/widgets/patch_details.dart';

void main() {
  runApp(const ProviderScope(child: PlinkyHubApp()));
}

class PlinkyHubApp extends StatelessWidget {
  const PlinkyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlinkyHub',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF28222E),
        useMaterial3: true,
      ),
      home: const PlinkyEditorPage(),
    );
  }
}

class PlinkyEditorPage extends ConsumerStatefulWidget {
  const PlinkyEditorPage({super.key});

  @override
  ConsumerState<PlinkyEditorPage> createState() =>
      _PlinkyEditorPageState();
}

class _PlinkyEditorPageState extends ConsumerState<PlinkyEditorPage> {
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

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plinky WebUSB editor',
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
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: state.connectionState ==
                        PlinkyConnectionState.connecting
                    ? null
                    : () => ref
                        .read(plinkyProvider.notifier)
                        .connect(),
                child: const Text('Connect'),
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
      ),
    );
  }
}
