import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/editor/editor_header.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/widgets/parameter_tile.dart';
import 'package:plinkyhub/widgets/patch_details.dart';

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
      ref.read(plinkyProvider.notifier).parsePatchFromUrl(patchParameter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plinkyProvider);
    final patch = state.patch;
    final isConnected = switch (state.connectionState) {
      PlinkyConnectionState.connected ||
      PlinkyConnectionState.loadingPatch ||
      PlinkyConnectionState.savingPatch => true,
      _ => false,
    };
    final isError = state.connectionState == PlinkyConnectionState.error;
    final isLoading =
        state.connectionState == PlinkyConnectionState.loadingPatch;

    final filteredParameters = patch?.parameters
        .where(
          (parameter) =>
              parameter.name != null && !parameter.name!.endsWith('_UNUSED'),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const minimumTileWidth = 320.0;
        final columnCount = (constraints.maxWidth / minimumTileWidth)
            .floor()
            .clamp(1, 6);
        final tileWidth =
            (constraints.maxWidth - 32 - (columnCount - 1) * 8) / columnCount;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: EditorHeader(
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
              if (filteredParameters != null && filteredParameters.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: tileWidth / 260,
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
