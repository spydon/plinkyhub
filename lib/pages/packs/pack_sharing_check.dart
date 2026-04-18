import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/patterns/providers/saved_patterns_notifier.dart';
import 'package:plinkyhub/pages/presets/providers/saved_presets_notifier.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/pages/wavetables/providers/saved_wavetables_notifier.dart';
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
    required this.patternIds,
    required this.wavetableId,
  });

  final List<String> presetIds;
  final List<String> sampleIds;
  final List<String> patternIds;
  final String? wavetableId;

  bool get hasPrivateItems =>
      presetIds.isNotEmpty ||
      sampleIds.isNotEmpty ||
      patternIds.isNotEmpty ||
      wavetableId != null;

  int get totalCount =>
      presetIds.length +
      sampleIds.length +
      patternIds.length +
      (wavetableId != null ? 1 : 0);
}

PrivateItemSummary findPrivateItems({
  required WidgetRef ref,
  required String currentUserId,
  required List<({String? presetId, String? sampleId, String? patternId})>
  slots,
  required String? wavetableId,
}) {
  final presetsState = ref.read(savedPresetsProvider);
  final samplesState = ref.read(savedSamplesProvider);
  final wavetablesState = ref.read(savedWavetablesProvider);
  final patternsState = ref.read(savedPatternsProvider);

  final privatePresetIds = <String>[];
  final privateSampleIds = <String>[];
  final privatePatternIds = <String>[];

  final seenPresetIds = <String>{};
  final seenSampleIds = <String>{};
  final seenPatternIds = <String>{};

  for (final slot in slots) {
    if (slot.presetId != null && seenPresetIds.add(slot.presetId!)) {
      final preset = presetsState.userItems
          .where((p) => p.id == slot.presetId)
          .firstOrNull;
      if (preset != null &&
          preset.userId == currentUserId &&
          !preset.isPublic) {
        privatePresetIds.add(preset.id);
      }
    }
    if (slot.sampleId != null && seenSampleIds.add(slot.sampleId!)) {
      final sample = samplesState.userItems
          .where((s) => s.id == slot.sampleId)
          .firstOrNull;
      if (sample != null &&
          sample.userId == currentUserId &&
          !sample.isPublic) {
        privateSampleIds.add(sample.id);
      }
    }
    if (slot.patternId != null && seenPatternIds.add(slot.patternId!)) {
      final pattern = patternsState.userItems
          .where((p) => p.id == slot.patternId)
          .firstOrNull;
      if (pattern != null &&
          pattern.userId == currentUserId &&
          !pattern.isPublic) {
        privatePatternIds.add(pattern.id);
      }
    }
  }

  String? privateWavetableId;
  if (wavetableId != null) {
    final wavetable = wavetablesState.userItems
        .where((w) => w.id == wavetableId)
        .firstOrNull;
    if (wavetable != null &&
        wavetable.userId == currentUserId &&
        !wavetable.isPublic) {
      privateWavetableId = wavetableId;
    }
  }

  return PrivateItemSummary(
    presetIds: privatePresetIds,
    sampleIds: privateSampleIds,
    patternIds: privatePatternIds,
    wavetableId: privateWavetableId,
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
  if (summary.patternIds.isNotEmpty) {
    final count = summary.patternIds.length;
    parts.add('$count pattern${count == 1 ? '' : 's'}');
  }
  if (summary.wavetableId != null) {
    parts.add('1 wavetable');
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
  if (summary.patternIds.isNotEmpty) {
    await supabase
        .from('patterns')
        .update({'is_public': true})
        .inFilter(
          'id',
          summary.patternIds,
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
}
