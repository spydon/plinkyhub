import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/packs/wavetable_picker_dialog.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/providers/saved_wavetables_notifier.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_card.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/widgets/linked_item_icon.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class WavetableSection extends ConsumerWidget {
  const WavetableSection({
    required this.wavetableId,
    required this.onChanged,
    this.deviceHasWavetable = false,
    this.showUnknownWhenEmpty = false,
    this.isDirty = false,
    this.readOnly = false,
    super.key,
  });

  final String? wavetableId;
  final bool deviceHasWavetable;
  final bool showUnknownWhenEmpty;
  final bool isDirty;
  final bool readOnly;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wavetablesState = ref.watch(savedWavetablesProvider);
    final wavetableName = wavetableId != null
        ? wavetablesState.allItems
              .firstWhereOrNull((wavetable) => wavetable.id == wavetableId)
              ?.name
        : null;

    final isLinked = wavetableId != null;
    final statusText = isLinked
        ? wavetableName ?? '(unknown)'
        : deviceHasWavetable
        ? 'Present on device (not linked)'
        : showUnknownWhenEmpty
        ? 'Unknown'
        : 'None';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wavetable',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (isLinked)
              LinkedItemIcon(
                onTap: () {
                  final wavetable = wavetablesState.allItems.firstWhereOrNull(
                    (wavetable) => wavetable.id == wavetableId,
                  );
                  if (wavetable == null) {
                    return;
                  }
                  final currentUserId = ref
                      .read(authenticationProvider)
                      .user
                      ?.id;
                  showDialog<void>(
                    context: context,
                    builder: (context) => Dialog(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: WavetableCard(
                            wavetable: wavetable,
                            isOwned: wavetable.userId == currentUserId,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            Text(
              statusText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isDirty)
              Tooltip(
                message: 'Unsaved changes',
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (showUnknownWhenEmpty && !isLinked)
              const Tooltip(
                message:
                    "The wavetable file isn't always present in a way that "
                    'we can detect which wavetable that is being used.',
                child: Icon(Icons.info_outline, size: 20),
              ),
            if (!readOnly && wavetableId != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Remove wavetable',
                onPressed: () => onChanged(null),
              ),
            if (!readOnly)
              PlinkyButton(
                onPressed: () async {
                  final authState = ref.read(authenticationProvider);
                  final selected = await showDialog<SavedWavetable>(
                    context: context,
                    builder: (context) => WavetablePickerDialog(
                      wavetables: wavetablesState.allItems,
                      currentUserId: authState.user?.id,
                    ),
                  );
                  if (selected != null) {
                    onChanged(selected.id);
                  }
                },
                icon: Icons.waves,
                label: 'Choose',
              ),
          ],
        ),
      ],
    );
  }
}
