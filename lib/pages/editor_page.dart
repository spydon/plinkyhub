import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/widgets/linux_webusb_instructions.dart';
import 'package:plinkyhub/widgets/parameter_tile.dart';
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
    final patch = state.patch;
    final isConnected = switch (state.connectionState) {
      PlinkyConnectionState.connected ||
      PlinkyConnectionState.loadingPatch ||
      PlinkyConnectionState.savingPatch =>
        true,
      _ => false,
    };
    final isError =
        state.connectionState == PlinkyConnectionState.error;
    final isLoading =
        state.connectionState == PlinkyConnectionState.loadingPatch;

    final filteredParameters = patch?.parameters
        .where(
          (parameter) =>
              parameter.name != null &&
              !parameter.name!.endsWith('_UNUSED'),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const minimumTileWidth = 320.0;
        final columnCount = (constraints.maxWidth / minimumTileWidth)
            .floor()
            .clamp(1, 6);
        final tileWidth =
            (constraints.maxWidth - 32 - (columnCount - 1) * 8) /
                columnCount;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _EditorHeader(
                  state: state,
                  isConnected: isConnected,
                  isError: isError,
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (patch != null) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: PatchDetailsHeader(patch: patch),
                ),
              ),
              if (filteredParameters != null &&
                  filteredParameters.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: tileWidth / 310,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ParameterTile(
                          parameter: filteredParameters[index],
                        );
                      },
                      childCount: filteredParameters.length,
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.state,
    required this.isConnected,
    required this.isError,
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
                  PlinkyConnectionState.savingPatch =>
                    Colors.green,
                  PlinkyConnectionState.connecting => Colors.orange,
                  PlinkyConnectionState.error => Colors.red,
                  PlinkyConnectionState.disconnected =>
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                },
              ),
            ),
          ],
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
          _ConnectButton(),
        ],
        if (isConnected) ...[
          const SizedBox(height: 16),
          const PatchControls(),
        ],
      ],
    );
  }
}

class _ConnectButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plinkyProvider);
    return PlinkyButton(
      onPressed: state.connectionState ==
              PlinkyConnectionState.connecting
          ? null
          : () => ref.read(plinkyProvider.notifier).connect(),
      icon: Icons.usb,
      label: 'Connect',
    );
  }
}
