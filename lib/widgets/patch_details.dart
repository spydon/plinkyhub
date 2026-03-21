import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/utils/compress.dart';
import 'package:plinkyhub/widgets/parameter_tile.dart';
import 'package:plinkyhub/widgets/randomize_controls.dart';

class PatchDetails extends ConsumerWidget {
  const PatchDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plinkyProvider);
    final patch = state.patch;

    if (patch == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No patch in browser memory'),
      );
    }

    final linkUrl = Uri.base
        .replace(
          queryParameters: {
            'p': bytecompress(patch.buffer.asUint8List()),
          },
        )
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This is the patch that has been loaded into '
          'browser memory.',
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () =>
              ref.read(plinkyProvider.notifier).clearPatch(),
          child: const Text('Clear patch in browser memory'),
        ),
        const SizedBox(height: 16),
        Text(
          'Link to patch',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        SelectableText(
          linkUrl,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 16),
        Text(
          'Patch name and category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: TextField(
                controller: TextEditingController(
                  text: patch.name,
                ),
                maxLength: 8,
                decoration: const InputDecoration(
                  isDense: true,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(plinkyProvider.notifier).patchName =
                      value;
                },
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<PatchCategory>(
              value: patch.category,
              items: PatchCategory.values.map((category) {
                return DropdownMenuItem<PatchCategory>(
                  value: category,
                  child: Text(
                    category.label.isEmpty
                        ? '(none)'
                        : category.label,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(plinkyProvider.notifier)
                      .patchCategory = value;
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const RandomizeControls(),
        const SizedBox(height: 16),
        Text(
          'Parameters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Arp: ${patch.arp} | '
          'Latch: ${patch.latch} | '
          'Loop start: ${patch.loopStart} | '
          'Loop length: ${patch.loopLength}',
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const minimumTileWidth = 320.0;
            final columnCount = (constraints.maxWidth /
                    minimumTileWidth)
                .floor()
                .clamp(1, 6);
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: patch.parameters
                  .where(
                    (parameter) =>
                        parameter.name != null &&
                        !parameter.name!.endsWith('_UNUSED'),
                  )
                  .map((parameter) {
                return SizedBox(
                  width:
                      (constraints.maxWidth -
                          (columnCount - 1) * 8) /
                      columnCount,
                  child: ParameterTile(
                    parameter: parameter,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
