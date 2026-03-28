import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PresetControls extends ConsumerStatefulWidget {
  const PresetControls({super.key});

  @override
  ConsumerState<PresetControls> createState() => _PresetControlsState();
}

class _PresetControlsState extends ConsumerState<PresetControls> {
  late TextEditingController _presetNumberController;

  @override
  void initState() {
    super.initState();
    final presetNumber = ref.read(plinkyProvider).presetNumber;
    _presetNumberController = TextEditingController(
      text: (presetNumber + 1).toString(),
    );
  }

  @override
  void dispose() {
    _presetNumberController.dispose();
    super.dispose();
  }

  void _updatePresetNumber() {
    final parsed = int.tryParse(_presetNumberController.text);
    if (parsed != null) {
      final clamped = parsed.clamp(1, 32);
      _presetNumberController.text = clamped.toString();
      ref.read(plinkyProvider.notifier).presetNumber = clamped - 1;
    }
  }

  void _stepPresetNumber(int delta) {
    final current = int.tryParse(_presetNumberController.text) ?? 1;
    final next = (current + delta).clamp(1, 32);
    _presetNumberController.text = next.toString();
    ref.read(plinkyProvider.notifier).presetNumber = next - 1;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plinkyProvider);
    final isLoading =
        state.connectionState == PlinkyConnectionState.loadingPreset ||
        state.connectionState == PlinkyConnectionState.savingPreset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Preset number'),
            const SizedBox(width: 8),
            SizedBox(
              width: 75,
              child: TextField(
                controller: _presetNumberController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  border: const OutlineInputBorder(),
                  suffixIconConstraints: const BoxConstraints(
                    maxHeight: 32,
                  ),
                  suffixIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                        width: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 14,
                          icon: const Icon(Icons.arrow_drop_up),
                          onPressed: isLoading
                              ? null
                              : () => _stepPresetNumber(1),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                        width: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 14,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          onPressed: isLoading
                              ? null
                              : () => _stepPresetNumber(-1),
                        ),
                      ),
                    ],
                  ),
                ),
                onSubmitted: (_) => _updatePresetNumber(),
              ),
            ),
            const SizedBox(width: 8),
            PlinkyButton(
              onPressed: isLoading
                  ? null
                  : () {
                      _updatePresetNumber();
                      ref.read(plinkyProvider.notifier).loadPreset();
                    },
              icon: Icons.download,
              label: 'Load from Plinky',
            ),
            const SizedBox(width: 8),
            PlinkyButton(
              onPressed: isLoading || state.preset == null
                  ? null
                  : () {
                      _updatePresetNumber();
                      ref.read(plinkyProvider.notifier).savePreset();
                    },
              icon: Icons.upload,
              label: 'Save to Plinky',
            ),
            const SizedBox(width: 8),
            PlinkyButton(
              onPressed: isLoading || state.preset == null
                  ? null
                  : () => ref.read(plinkyProvider.notifier).clearPreset(),
              icon: Icons.delete_outline,
              label: 'Clear loaded preset',
            ),
          ],
        ),
      ],
    );
  }
}
