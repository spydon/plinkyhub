import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/pattern_playback_notifier.dart';
import 'package:plinkyhub/utils/pitch.dart';

const _noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

/// Returns a human-readable note name for a MIDI note number (e.g. "C4").
String _midiNoteName(int midi) {
  final octave = (midi ~/ 12) - 1;
  return '${_noteNames[midi % 12]}$octave';
}

/// How the pattern grid arranges and colours its rows.
enum GridViewMode {
  /// No string colouring; rows sorted high-to-low by pitch.
  blank,

  /// Rows sorted high-to-low by pitch, but each row is tinted with
  /// the colour of its Plinky string (per-string monophony).
  coloredByString,

  /// Rows grouped by string (string 0 on top, string 7 on bottom),
  /// columns inside a string run from highest position to lowest;
  /// each row is tinted with its string colour.
  orderedByString,
}

/// One distinct hue per Plinky string (0..7). Picked from evenly
/// spaced HSV hues so adjacent strings stay easy to tell apart.
/// Active cells use the full saturated colour; inactive cells get a
/// muted version via [_inactiveStringColor] so the row-grouping is
/// still readable but doesn't compete with the active marks.
Color _stringColor(int stringIndex) {
  final hue = (stringIndex * 360 / 8) % 360;
  return HSLColor.fromAHSL(1, hue, 0.6, 0.55).toColor();
}

Color _inactiveStringColor(int stringIndex, ColorScheme colorScheme) {
  final base = _stringColor(stringIndex);
  return Color.lerp(colorScheme.surfaceContainerLow, base, 0.08)!;
}

Color _inactiveDownbeatStringColor(int stringIndex, ColorScheme colorScheme) {
  final base = _stringColor(stringIndex);
  return Color.lerp(colorScheme.surfaceContainerHighest, base, 0.12)!;
}

/// A piano-roll-style step-sequencer grid for Plinky patterns.
///
/// Each row is one of the 64 Plinky pads (8 strings × 8 columns) sorted
/// from highest to lowest pitch. Each column is one step. Tapping a
/// cell places a note at that pitch and step; clicking again clears it.
/// Per-string monophony is enforced: placing a note on a string at a
/// step automatically clears any other column the same string had at
/// the same step.
///
/// Cell values in [grid] use the firmware-friendly encoding:
///   0     = inactive
///   1..8  = active at touch-strip column 0..7
class PatternGridEditor extends StatefulWidget {
  const PatternGridEditor({
    required this.grid,
    required this.scale,
    required this.onGridChanged,
    this.enabled = true,
    this.readOnly = false,
    this.playbackPatternId,
    this.onAppendSteps,
    this.appendStepsTooltip,
    this.viewMode = GridViewMode.coloredByString,
    super.key,
  });

  /// 2D grid indexed by step then string. Cell value: 0 = inactive,
  /// 1..8 = active at touch-strip column 0..7.
  final List<List<int>> grid;
  final PlinkyScale scale;
  final ValueChanged<List<List<int>>> onGridChanged;
  final bool enabled;

  /// When true, cells cannot be toggled and hover effects are disabled.
  final bool readOnly;

  /// When non-null, an isolated [_PlayheadOverlay] widget watches the
  /// playback provider for this pattern id and draws the vertical
  /// playback bar over the active column. Subscribing locally means
  /// step changes only repaint the overlay (a single Positioned),
  /// not the entire grid (which is up to 64×64 cells).
  final String? playbackPatternId;

  /// When non-null, renders a vertically-centred "+" button right
  /// after the last step inside the horizontal scroll area, so the
  /// user can extend the pattern length without leaving the grid.
  /// Pass null to disable the button entirely.
  final VoidCallback? onAppendSteps;
  final String? appendStepsTooltip;

  /// Controls how rows are arranged and coloured.
  final GridViewMode viewMode;

  @override
  State<PatternGridEditor> createState() => _PatternGridEditorState();
}

class _PatternGridEditorState extends State<PatternGridEditor> {
  /// Cell width including the 1px margin on each side.
  static const _cellWithMargin = 26.0;

  /// Cell height including the 1px margin on each side.
  static const _rowHeight = 22.0;

  /// Width reserved for the pitch label column.
  static const _labelWidth = 56.0;

  /// Height of the step-numbers header row.
  static const _headerHeight = 20.0;

  /// Default viewport when the parent doesn't constrain our height
  /// (e.g. when nested in a SingleChildScrollView).
  static const _fallbackViewportHeight = 520.0;

  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();

  /// The cell value the current drag gesture is painting (0 to clear,
  /// or `column + 1` to paint).
  int? _dragPaintValue;

  late List<PlinkyPad> _pads;

  @override
  void initState() {
    super.initState();
    _pads = _padsForViewMode();
  }

  @override
  void didUpdateWidget(covariant PatternGridEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scale != oldWidget.scale ||
        widget.viewMode != oldWidget.viewMode) {
      _pads = _padsForViewMode();
    }
  }

  List<PlinkyPad> _padsForViewMode() {
    return widget.viewMode == GridViewMode.orderedByString
        ? plinkyPadsByString(widget.scale)
        : plinkyPadsByPitch(widget.scale);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  /// Returns true when the cell at (step, pad) should appear active,
  /// i.e. the grid records this string playing this column at this step.
  bool _isCellActive(int step, PlinkyPad pad) {
    return widget.grid[step][pad.string] == pad.column + 1;
  }

  /// Computes the value to write to (step, pad) when the user taps it:
  /// clear if it was already at this column, otherwise paint with this
  /// pad's column. Per-string monophony is implicit because the grid
  /// only stores one column per (step, string).
  int _nextValueOnTap(int step, PlinkyPad pad) {
    return _isCellActive(step, pad) ? 0 : pad.column + 1;
  }

  void _setCellValue(int step, int stringIndex, int value) {
    if (!widget.enabled || widget.readOnly) {
      return;
    }
    if (widget.grid[step][stringIndex] == value) {
      return;
    }
    final newGrid = [
      for (var s = 0; s < widget.grid.length; s++)
        [for (var r = 0; r < 8; r++) widget.grid[s][r]],
    ];
    newGrid[step][stringIndex] = value;
    widget.onGridChanged(newGrid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stepCount = widget.grid.length;
    final fullHeight = _headerHeight + _pads.length * _rowHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : _fallbackViewportHeight;
              return SizedBox(
                height: viewportHeight,
                child: _PianoRollScroller(
                  pads: _pads,
                  stepCount: stepCount,
                  fullHeight: fullHeight,
                  cellWithMargin: _cellWithMargin,
                  rowHeight: _rowHeight,
                  labelWidth: _labelWidth,
                  headerHeight: _headerHeight,
                  colorScheme: colorScheme,
                  textTheme: theme.textTheme,
                  readOnly: widget.readOnly,
                  enabled: widget.enabled,
                  playbackPatternId: widget.playbackPatternId,
                  viewMode: widget.viewMode,
                  horizontalScrollController: _horizontalScrollController,
                  verticalScrollController: _verticalScrollController,
                  isCellActive: _isCellActive,
                  onTap: (step, padIndex) {
                    final pad = _pads[padIndex];
                    _setCellValue(
                      step,
                      pad.string,
                      _nextValueOnTap(step, pad),
                    );
                  },
                  onDragStart: (step, padIndex) {
                    final pad = _pads[padIndex];
                    final next = _nextValueOnTap(step, pad);
                    _dragPaintValue = next;
                    _setCellValue(step, pad.string, next);
                  },
                  onDragEnter: (step, padIndex) {
                    final value = _dragPaintValue;
                    if (value == null) {
                      return;
                    }
                    final pad = _pads[padIndex];
                    // Only paint cells whose current state matches the
                    // value we'd paint, to avoid accidentally clearing
                    // unrelated columns.
                    if (value == 0 || widget.grid[step][pad.string] == 0) {
                      _setCellValue(step, pad.string, value);
                    }
                  },
                  onDragEnd: () => _dragPaintValue = null,
                  onAppendSteps: widget.onAppendSteps,
                  appendStepsTooltip: widget.appendStepsTooltip,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PianoRollScroller extends StatelessWidget {
  const _PianoRollScroller({
    required this.pads,
    required this.stepCount,
    required this.fullHeight,
    required this.cellWithMargin,
    required this.rowHeight,
    required this.labelWidth,
    required this.headerHeight,
    required this.colorScheme,
    required this.textTheme,
    required this.readOnly,
    required this.enabled,
    required this.playbackPatternId,
    required this.viewMode,
    required this.horizontalScrollController,
    required this.verticalScrollController,
    required this.isCellActive,
    required this.onTap,
    required this.onDragStart,
    required this.onDragEnter,
    required this.onDragEnd,
    this.onAppendSteps,
    this.appendStepsTooltip,
  });

  final List<PlinkyPad> pads;
  final int stepCount;
  final double fullHeight;
  final double cellWithMargin;
  final double rowHeight;
  final double labelWidth;
  final double headerHeight;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool readOnly;
  final bool enabled;
  final String? playbackPatternId;
  final GridViewMode viewMode;
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;
  final bool Function(int step, PlinkyPad pad) isCellActive;
  final void Function(int step, int padIndex) onTap;
  final void Function(int step, int padIndex) onDragStart;
  final void Function(int step, int padIndex) onDragEnter;
  final VoidCallback onDragEnd;
  final VoidCallback? onAppendSteps;
  final String? appendStepsTooltip;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: verticalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: verticalScrollController,
        child: SizedBox(
          height: fullHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: _PitchLabels(
                  pads: pads,
                  rowHeight: rowHeight,
                  headerHeight: headerHeight,
                  textStyle: textTheme.bodySmall,
                  viewMode: viewMode,
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  notificationPredicate: (notification) =>
                      notification.depth == 0,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: stepCount * cellWithMargin,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _StepHeader(
                                    stepCount: stepCount,
                                    cellWidth: cellWithMargin,
                                    headerHeight: headerHeight,
                                    textStyle: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  for (
                                    var padIndex = 0;
                                    padIndex < pads.length;
                                    padIndex++
                                  )
                                    _PadRow(
                                      pad: pads[padIndex],
                                      padIndex: padIndex,
                                      stepCount: stepCount,
                                      cellWithMargin: cellWithMargin,
                                      rowHeight: rowHeight,
                                      colorScheme: colorScheme,
                                      viewMode: viewMode,
                                      readOnly: readOnly || !enabled,
                                      isActive: isCellActive,
                                      onTap: onTap,
                                      onDragStart: onDragStart,
                                      onDragEnter: onDragEnter,
                                      onDragEnd: onDragEnd,
                                    ),
                                ],
                              ),
                              if (playbackPatternId != null)
                                _PlayheadOverlay(
                                  patternId: playbackPatternId!,
                                  cellWithMargin: cellWithMargin,
                                  headerHeight: headerHeight,
                                  bodyHeight: pads.length * rowHeight,
                                  primaryColor: colorScheme.primary,
                                  scrollController: horizontalScrollController,
                                ),
                            ],
                          ),
                        ),
                        if (onAppendSteps != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Center(
                              child: IconButton.outlined(
                                tooltip: appendStepsTooltip,
                                onPressed: onAppendSteps,
                                icon: const Icon(Icons.add),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Left column of pitch labels, one per pad.
class _PitchLabels extends StatelessWidget {
  const _PitchLabels({
    required this.pads,
    required this.rowHeight,
    required this.headerHeight,
    required this.textStyle,
    required this.viewMode,
  });

  final List<PlinkyPad> pads;
  final double rowHeight;
  final double headerHeight;
  final TextStyle? textStyle;
  final GridViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final colored = viewMode != GridViewMode.blank;
    return Column(
      children: [
        SizedBox(height: headerHeight),
        for (final pad in pads)
          SizedBox(
            height: rowHeight,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _midiNoteName(pad.midiNote),
                  style: textStyle?.copyWith(
                    fontSize: 11,
                    color: colored ? _stringColor(pad.string) : null,
                    fontWeight: colored ? FontWeight.w600 : null,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Step-numbers header row (1, 2, 3, ...).
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.stepCount,
    required this.cellWidth,
    required this.headerHeight,
    required this.textStyle,
  });

  final int stepCount;
  final double cellWidth;
  final double headerHeight;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var step = 0; step < stepCount; step++)
          SizedBox(
            width: cellWidth,
            height: headerHeight,
            child: Center(
              child: Text('${step + 1}', style: textStyle),
            ),
          ),
      ],
    );
  }
}

/// One row of step cells for a single pad.
class _PadRow extends StatelessWidget {
  const _PadRow({
    required this.pad,
    required this.padIndex,
    required this.stepCount,
    required this.cellWithMargin,
    required this.rowHeight,
    required this.colorScheme,
    required this.viewMode,
    required this.readOnly,
    required this.isActive,
    required this.onTap,
    required this.onDragStart,
    required this.onDragEnter,
    required this.onDragEnd,
  });

  final PlinkyPad pad;
  final int padIndex;
  final int stepCount;
  final double cellWithMargin;
  final double rowHeight;
  final ColorScheme colorScheme;
  final GridViewMode viewMode;
  final bool readOnly;
  final bool Function(int step, PlinkyPad pad) isActive;
  final void Function(int step, int padIndex) onTap;
  final void Function(int step, int padIndex) onDragStart;
  final void Function(int step, int padIndex) onDragEnter;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final colored = viewMode != GridViewMode.blank;
    final activeColor = colored
        ? _stringColor(pad.string)
        : colorScheme.primary;
    final inactiveColor = colored
        ? _inactiveStringColor(pad.string, colorScheme)
        : colorScheme.surfaceContainerLow;
    final inactiveDownbeatColor = colored
        ? _inactiveDownbeatStringColor(pad.string, colorScheme)
        : colorScheme.surfaceContainerHighest;
    return Row(
      children: [
        for (var step = 0; step < stepCount; step++)
          _GridCell(
            isActive: isActive(step, pad),
            isDownbeat: step % 4 == 0,
            cellSize: cellWithMargin - 2,
            rowHeight: rowHeight,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            inactiveDownbeatColor: inactiveDownbeatColor,
            outlineColor: colorScheme.outline,
            outlineVariantColor: colorScheme.outlineVariant,
            hoverTintColor: colorScheme.onSurface,
            readOnly: readOnly,
            onTap: () => onTap(step, padIndex),
            onDragStart: () => onDragStart(step, padIndex),
            onDragEnter: () => onDragEnter(step, padIndex),
            onDragEnd: onDragEnd,
          ),
      ],
    );
  }
}

/// Watches `patternPlaybackProvider` for the matching pattern id and
/// renders the vertical playhead bar for the active step. Lives
/// inside the grid's horizontal scroll Stack so it scrolls with the
/// cells but only this widget rebuilds on step changes; the cells
/// themselves are unaffected, which matters for large grids.
class _PlayheadOverlay extends ConsumerStatefulWidget {
  const _PlayheadOverlay({
    required this.patternId,
    required this.cellWithMargin,
    required this.headerHeight,
    required this.bodyHeight,
    required this.primaryColor,
    required this.scrollController,
  });

  final String patternId;
  final double cellWithMargin;
  final double headerHeight;
  final double bodyHeight;
  final Color primaryColor;
  final ScrollController scrollController;

  @override
  ConsumerState<_PlayheadOverlay> createState() => _PlayheadOverlayState();
}

class _PlayheadOverlayState extends ConsumerState<_PlayheadOverlay> {
  int? _previousStep;

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(
      patternPlaybackProvider.select(
        (state) => state.isPlaying && state.currentPatternId == widget.patternId
            ? state.currentStep
            : null,
      ),
    );

    if (step != _previousStep) {
      _previousStep = step;
      if (step != null) {
        _scrollToStep(step);
      }
    }

    if (step == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: step * widget.cellWithMargin,
      top: widget.headerHeight,
      width: widget.cellWithMargin,
      height: widget.bodyHeight,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: widget.primaryColor.withValues(alpha: 0.2),
            border: Border(
              left: BorderSide(color: widget.primaryColor, width: 2),
              right: BorderSide(color: widget.primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  /// Keeps the playhead horizontally centred in the viewport, clamped
  /// at both ends. Skips when the target offset is already current
  /// (within a pixel) so we don't spam scroll animations every step.
  void _scrollToStep(int step) {
    if (!widget.scrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) {
        return;
      }
      final position = widget.scrollController.position;
      final viewportWidth = position.viewportDimension;
      final cellCenter =
          step * widget.cellWithMargin + widget.cellWithMargin / 2;
      final target = (cellCenter - viewportWidth / 2).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((position.pixels - target).abs() < 1) {
        return;
      }
      widget.scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    });
  }
}

class _GridCell extends StatefulWidget {
  const _GridCell({
    required this.isActive,
    required this.isDownbeat,
    required this.cellSize,
    required this.rowHeight,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveDownbeatColor,
    required this.outlineColor,
    required this.outlineVariantColor,
    required this.hoverTintColor,
    required this.onTap,
    required this.onDragStart,
    required this.onDragEnter,
    required this.onDragEnd,
    this.readOnly = false,
  });

  final bool isActive;
  final bool isDownbeat;
  final double cellSize;
  final double rowHeight;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveDownbeatColor;
  final Color outlineColor;
  final Color outlineVariantColor;
  final Color hoverTintColor;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnter;
  final VoidCallback onDragEnd;
  final bool readOnly;

  @override
  State<_GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<_GridCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isActive
        ? widget.activeColor
        : widget.isDownbeat
        ? widget.inactiveDownbeatColor
        : widget.inactiveColor;
    final fillColor = _isHovered && !widget.readOnly
        ? Color.lerp(baseColor, widget.hoverTintColor, 0.15)!
        : baseColor;
    final borderColor = _isHovered && !widget.readOnly
        ? widget.outlineColor
        : widget.outlineVariantColor;

    final cell = Container(
      width: widget.cellSize,
      height: widget.rowHeight - 2,
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      margin: const EdgeInsets.all(1),
    );

    if (widget.readOnly) {
      return cell;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: (_) => widget.onDragStart(),
        onPanEnd: (_) => widget.onDragEnd(),
        onPanCancel: widget.onDragEnd,
        child: DragTarget<Object>(
          onWillAcceptWithDetails: (_) {
            widget.onDragEnter();
            return false;
          },
          builder: (context, _, __) => cell,
        ),
      ),
    );
  }
}
