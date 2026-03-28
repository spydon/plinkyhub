import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';

class SamplesSection extends ConsumerWidget {
  const SamplesSection({required this.slots, super.key});

  final List<({String? presetId, String? sampleId})> slots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final samples = ref.watch(
      savedSamplesProvider.select((state) => state.userSamples),
    );

    final uniqueSampleIds = slots
        .map((slot) => slot.sampleId)
        .whereType<String>()
        .toSet()
        .toList();
    final hasOverflow = uniqueSampleIds.length > 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Samples',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (hasOverflow)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'A pack can use at most 8 samples. '
              'Currently using ${uniqueSampleIds.length}.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        Row(
          children: List.generate(8, (index) {
            final sampleId = index < uniqueSampleIds.length
                ? uniqueSampleIds[index]
                : null;
            final sample = sampleId != null
                ? samples
                      .where((sample) => sample.id == sampleId)
                      .firstOrNull
                : null;
            return Expanded(
              child: Card(
                color: sampleId != null
                    ? theme.colorScheme.primaryContainer
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${index + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sample?.name ?? '-',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
