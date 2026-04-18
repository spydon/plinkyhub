import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/patterns/models/pattern_data.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/pages/patterns/pattern_grid_editor.dart';
import 'package:plinkyhub/pages/patterns/pattern_play_controls.dart';
import 'package:plinkyhub/utils/pitch.dart';

/// Plays a pattern through WebMIDI to the connected Plinky and renders
/// a read-only copy of the grid with a vertical playhead bar.
class PatternPlaybackPanel extends ConsumerStatefulWidget {
  const PatternPlaybackPanel({
    required this.pattern,
    required this.patternData,
    this.loadError,
    this.header,
    super.key,
  });

  final SavedPattern pattern;
  final PatternData? patternData;
  final String? loadError;

  /// Optional widget rendered at the top of the panel's card, above
  /// the play controls. Used by the pattern detail page to embed the
  /// pattern metadata (name, description, action buttons) into the
  /// same card as the playback grid so the grid gets more space.
  final Widget? header;

  @override
  ConsumerState<PatternPlaybackPanel> createState() =>
      _PatternPlaybackPanelState();
}

class _PatternPlaybackPanelState extends ConsumerState<PatternPlaybackPanel> {
  bool _isGridExpanded = true;

  /// Pads each step out to exactly 8 entries so the grid widget always
  /// has a value for every (step, row) cell.
  List<List<int>> _normalizedGrid(PatternData patternData) {
    return [
      for (final step in patternData.grid)
        [for (var row = 0; row < 8; row++) row < step.length ? step[row] : 0],
    ];
  }

  PlinkyScale _scale(PatternData patternData) {
    final index = patternData.scaleIndex;
    if (index < 0 || index >= PlinkyScale.values.length) {
      return PlinkyScale.major;
    }
    return PlinkyScale.values[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final patternData = widget.patternData;
    final loadError = widget.loadError;
    final header = widget.header;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              header,
              const Divider(height: 24),
            ],
            PatternPlayControls(
              patternId: widget.pattern.id,
              patternData: patternData,
            ),
            if (loadError != null) ...[
              const SizedBox(height: 12),
              Text(
                'Could not load pattern data: $loadError',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _GridFoldHeader(
              isExpanded: _isGridExpanded,
              onToggle: () =>
                  setState(() => _isGridExpanded = !_isGridExpanded),
            ),
            if (_isGridExpanded) ...[
              const SizedBox(height: 8),
              if (patternData != null)
                Expanded(
                  child: PatternGridEditor(
                    grid: _normalizedGrid(patternData),
                    scale: _scale(patternData),
                    enabled: false,
                    readOnly: true,
                    playbackPatternId: widget.pattern.id,
                    onGridChanged: (_) {},
                  ),
                )
              else if (loadError == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GridFoldHeader extends StatelessWidget {
  const _GridFoldHeader({
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text('Pattern Grid', style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
