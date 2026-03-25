import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';

class StarButton extends ConsumerWidget {
  const StarButton({required this.patch, super.key});

  final SavedPatch patch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn =
        ref.watch(authenticationProvider).user != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            patch.isStarred ? Icons.star : Icons.star_border,
            size: 20,
            color: patch.isStarred ? Colors.amber : null,
          ),
          tooltip: patch.isStarred
              ? 'Remove star'
              : 'Star this patch',
          onPressed: () => isSignedIn
              ? ref
                  .read(savedPatchesProvider.notifier)
                  .toggleStar(patch)
              : showSignInDialog(context),
        ),
        if (patch.starCount > 0)
          Text(
            '${patch.starCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
