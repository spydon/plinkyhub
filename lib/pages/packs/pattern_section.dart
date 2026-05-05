import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/packs/pattern_picker_dialog.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/pages/patterns/pattern_card.dart';
import 'package:plinkyhub/pages/patterns/providers/saved_patterns_notifier.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/widgets/linked_item_icon.dart';

class PatternSection extends StatelessWidget {
  const PatternSection({
    required this.patternIds,
    required this.onPatternChanged,
    this.devicePatternIndices = const {},
    this.dirtyPatterns = const {},
    this.readOnly = false,
    super.key,
  });

  final Map<int, String?> patternIds;
  final void Function(int patternIndex, String? patternId) onPatternChanged;
  final Set<int> devicePatternIndices;
  final Set<int> dirtyPatterns;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patterns',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: 64,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: patternCount,
          itemBuilder: (context, index) {
            final row = index ~/ 4;
            final column = index % 4;
            final patternIndex = column * 6 + row;
            return _PatternTile(
              patternIndex: patternIndex,
              hasDevicePattern: devicePatternIndices.contains(patternIndex),
              patternId: patternIds[patternIndex],
              isDirty: dirtyPatterns.contains(patternIndex),
              onChanged: (patternId) =>
                  onPatternChanged(patternIndex, patternId),
              readOnly: readOnly,
            );
          },
        ),
      ],
    );
  }
}

class _PatternTile extends ConsumerWidget {
  const _PatternTile({
    required this.patternIndex,
    required this.hasDevicePattern,
    required this.patternId,
    required this.onChanged,
    this.isDirty = false,
    this.readOnly = false,
  });

  final int patternIndex;
  final bool hasDevicePattern;
  final String? patternId;
  final ValueChanged<String?> onChanged;
  final bool isDirty;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLinked = patternId != null;

    String displayName;
    if (isLinked) {
      final patternsState = ref.watch(savedPatternsProvider);
      displayName =
          patternsState.allItems
              .firstWhereOrNull((pattern) => pattern.id == patternId)
              ?.name ??
          '(unknown)';
    } else if (hasDevicePattern) {
      displayName = 'Pattern ${patternIndex + 1}';
    } else {
      displayName = 'Empty';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: readOnly ? null : () => _showPatternPicker(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${patternIndex + 1}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLinked) ...[
                    const SizedBox(width: 4),
                    LinkedItemIcon(
                      onTap: () => _showLinkedPattern(context, ref),
                    ),
                  ],
                  if (isDirty) ...[
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Unsaved changes',
                      child: Icon(
                        Icons.edit,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                displayName,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLinkedPattern(BuildContext context, WidgetRef ref) {
    final patternsState = ref.read(savedPatternsProvider);
    final pattern = patternsState.allItems.firstWhereOrNull(
      (pattern) => pattern.id == patternId,
    );
    if (pattern == null) {
      return;
    }
    final currentUserId = ref.read(authenticationProvider).user?.id;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PatternCard(
              pattern: pattern,
              isOwned: pattern.userId == currentUserId,
            ),
          ),
        ),
      ),
    );
  }

  void _showPatternPicker(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authenticationProvider);
    final patternsState = ref.read(savedPatternsProvider);
    showDialog<SavedPattern>(
      context: context,
      builder: (context) => PatternPickerDialog(
        patterns: patternsState.allItems,
        currentUserId: authState.user?.id,
      ),
    ).then((selected) {
      if (selected != null) {
        onChanged(selected.id);
      }
    });
  }
}
