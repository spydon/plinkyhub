import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/state/saved_presets_notifier.dart';
import 'package:plinkyhub/widgets/star_button.dart';

class PresetStarButton extends ConsumerWidget {
  const PresetStarButton({required this.preset, super.key});

  final SavedPreset preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StarButton(
      isStarred: preset.isStarred,
      starCount: preset.starCount,
      onToggle: () => ref
          .read(savedPresetsProvider.notifier)
          .toggleStar(preset),
    );
  }
}
