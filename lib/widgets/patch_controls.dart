import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';

class PatchControls extends ConsumerStatefulWidget {
  const PatchControls({super.key});

  @override
  ConsumerState<PatchControls> createState() =>
      _PatchControlsState();
}

class _PatchControlsState extends ConsumerState<PatchControls> {
  late TextEditingController _patchNumberController;

  @override
  void initState() {
    super.initState();
    final patchNumber = ref.read(plinkyProvider).patchNumber;
    _patchNumberController = TextEditingController(
      text: (patchNumber + 1).toString(),
    );
  }

  @override
  void dispose() {
    _patchNumberController.dispose();
    super.dispose();
  }

  void _updatePatchNumber() {
    final parsed = int.tryParse(_patchNumberController.text);
    if (parsed != null) {
      ref.read(plinkyProvider.notifier).patchNumber = parsed - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plinkyProvider);
    final isLoading = state.connectionState ==
            PlinkyConnectionState.loadingPatch ||
        state.connectionState ==
            PlinkyConnectionState.savingPatch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patch',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        const Text(
          'Per-patch operations - you can load and save '
          'patches on the device.',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Patch number'),
            const SizedBox(width: 8),
            SizedBox(
              width: 64,
              child: TextField(
                controller: _patchNumberController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _updatePatchNumber(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      _updatePatchNumber();
                      ref
                          .read(plinkyProvider.notifier)
                          .loadPatch();
                    },
              child: const Text('Load patch'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      _updatePatchNumber();
                      ref
                          .read(plinkyProvider.notifier)
                          .savePatch();
                    },
              child: const Text('Save patch'),
            ),
          ],
        ),
      ],
    );
  }
}
