import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/save_wavetable_to_plinky_dialog.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';

class WavetableCard extends ConsumerWidget {
  const WavetableCard({
    required this.wavetable,
    required this.isOwned,
    super.key,
  });

  final SavedWavetable wavetable;
  final bool isOwned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: wavetable.username.isNotEmpty
            ? () => context.go(
                '/${wavetable.username}/wavetable/'
                '${Uri.encodeComponent(wavetable.name)}',
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wavetable.name.isEmpty ? '(unnamed)' : wavetable.name,
                style: theme.textTheme.titleMedium,
              ),
              if (wavetable.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  wavetable.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 4),
              UsernameDateLine(
                userId: wavetable.userId,
                username: wavetable.username,
                updatedAt: wavetable.updatedAt,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StarButton(
                    isStarred: wavetable.isStarred,
                    starCount: wavetable.starCount,
                    onToggle: () => ref
                        .read(savedWavetablesProvider.notifier)
                        .toggleStar(wavetable),
                  ),
                  if (wavetable.username.isNotEmpty)
                    ShareLinkButton(
                      username: wavetable.username,
                      itemType: 'wavetable',
                      itemName: wavetable.name,
                    ),
                  IconButton(
                    icon: const Icon(Icons.usb, size: 20),
                    tooltip: 'Save to Plinky',
                    onPressed: () => _saveToPlinky(context),
                  ),
                  const Spacer(),
                  if (isOwned) ...[
                    IconButton(
                      icon: Icon(
                        wavetable.isPublic ? Icons.public : Icons.public_off,
                        size: 20,
                      ),
                      tooltip: wavetable.isPublic
                          ? 'Make private'
                          : 'Make public',
                      onPressed: () {
                        ref
                            .read(savedWavetablesProvider.notifier)
                            .updateWavetable(
                              wavetable.copyWith(
                                isPublic: !wavetable.isPublic,
                              ),
                            );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                      ),
                      tooltip: 'Delete wavetable',
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveToPlinky(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveWavetableToPlinkyDialog(wavetable: wavetable),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete wavetable?'),
        content: Text(
          'Are you sure you want to delete '
          '"${wavetable.name.isEmpty ? '(unnamed)' : wavetable.name}"?',
        ),
        actions: [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.close,
            label: 'Cancel',
          ),
          PlinkyButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(savedWavetablesProvider.notifier)
                  .deleteWavetable(wavetable.id);
            },
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}
