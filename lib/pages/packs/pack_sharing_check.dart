import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/saved_patterns_notifier.dart';
import 'package:plinkyhub/state/saved_presets_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SharingCheckResult {
  makeAllPublic,
  makePackPrivate,
}

class PrivateItemSummary {
  PrivateItemSummary({
    required this.presetIds,
    required this.sampleIds,
    required this.wavetableId,
    required this.patternId,
  });

  final List<String> presetIds;
  final List<String> sampleIds;
  final String? wavetableId;
  final String? patternId;

  bool get hasPrivateItems =>
      presetIds.isNotEmpty ||
      sampleIds.isNotEmpty ||
      wavetableId != null ||
      patternId != null;

  int get totalCount =>
      presetIds.length +
      sampleIds.length +
      (wavetableId != null ? 1 : 0) +
      (patternId != null ? 1 : 0);
}

PrivateItemSummary findPrivateItems({
  required WidgetRef ref,
  required String currentUserId,
  required List<({String? presetId, String? sampleId})> slots,
  required String? wavetableId,
  required String? patternId,
}) {
  final presetsState = ref.read(savedPresetsProvider);
  final samplesState = ref.read(savedSamplesProvider);
  final wavetablesState = ref.read(savedWavetablesProvider);
  final patternsState = ref.read(savedPatternsProvider);

  final privatePresetIds = <String>[];
  final privateSampleIds = <String>[];

  final seenPresetIds = <String>{};
  final seenSampleIds = <String>{};

  for (final slot in slots) {
    if (slot.presetId != null && seenPresetIds.add(slot.presetId!)) {
      final preset = presetsState.userPresets
          .where((p) => p.id == slot.presetId)
          .firstOrNull;
      if (preset != null &&
          preset.userId == currentUserId &&
          !preset.isPublic) {
        privatePresetIds.add(preset.id);
      }
    }
    if (slot.sampleId != null && seenSampleIds.add(slot.sampleId!)) {
      final sample = samplesState.userSamples
          .where((s) => s.id == slot.sampleId)
          .firstOrNull;
      if (sample != null &&
          sample.userId == currentUserId &&
          !sample.isPublic) {
        privateSampleIds.add(sample.id);
      }
    }
  }

  String? privateWavetableId;
  if (wavetableId != null) {
    final wavetable = wavetablesState.userWavetables
        .where((w) => w.id == wavetableId)
        .firstOrNull;
    if (wavetable != null &&
        wavetable.userId == currentUserId &&
        !wavetable.isPublic) {
      privateWavetableId = wavetableId;
    }
  }

  String? privatePatternId;
  if (patternId != null) {
    final pattern = patternsState.userPatterns
        .where((p) => p.id == patternId)
        .firstOrNull;
    if (pattern != null &&
        pattern.userId == currentUserId &&
        !pattern.isPublic) {
      privatePatternId = patternId;
    }
  }

  return PrivateItemSummary(
    presetIds: privatePresetIds,
    sampleIds: privateSampleIds,
    wavetableId: privateWavetableId,
    patternId: privatePatternId,
  );
}

Future<SharingCheckResult?> showSharingConflictDialog(
  BuildContext context,
  PrivateItemSummary summary,
) {
  final parts = <String>[];
  if (summary.presetIds.isNotEmpty) {
    final count = summary.presetIds.length;
    parts.add('$count preset${count == 1 ? '' : 's'}');
  }
  if (summary.sampleIds.isNotEmpty) {
    final count = summary.sampleIds.length;
    parts.add('$count sample${count == 1 ? '' : 's'}');
  }
  if (summary.wavetableId != null) {
    parts.add('1 wavetable');
  }
  if (summary.patternId != null) {
    parts.add('1 pattern');
  }

  return showDialog<SharingCheckResult>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Private items in public pack'),
      content: Text(
        'This pack includes ${parts.join(', ')} '
        'that are currently private. '
        "Community members won't be able to "
        'access them.\n\n'
        'Would you like to make all items public, '
        'or keep the pack private?',
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(
            SharingCheckResult.makePackPrivate,
          ),
          icon: Icons.public_off,
          label: 'Keep private',
        ),
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(
            SharingCheckResult.makeAllPublic,
          ),
          icon: Icons.public,
          label: 'Make all public',
        ),
      ],
    ),
  );
}

Future<void> makeItemsPublic(PrivateItemSummary summary) async {
  final supabase = Supabase.instance.client;

  if (summary.presetIds.isNotEmpty) {
    await supabase
        .from('presets')
        .update({'is_public': true})
        .inFilter(
          'id',
          summary.presetIds,
        );
  }
  if (summary.sampleIds.isNotEmpty) {
    await supabase
        .from('samples')
        .update({'is_public': true})
        .inFilter(
          'id',
          summary.sampleIds,
        );
  }
  if (summary.wavetableId != null) {
    await supabase
        .from('wavetables')
        .update({'is_public': true})
        .eq(
          'id',
          summary.wavetableId!,
        );
  }
  if (summary.patternId != null) {
    await supabase
        .from('patterns')
        .update({'is_public': true})
        .eq(
          'id',
          summary.patternId!,
        );
  }
}
