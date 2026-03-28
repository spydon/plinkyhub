import 'package:flutter/material.dart';
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

/// An interactive step-sequencer grid for creating Plinky patterns.
///
/// Displays an 8-row (notes) × `stepCount`-column grid. Users tap cells to
/// toggle them on/off. Each row label shows the note name derived from the
/// selected [scale].
class PatternGridEditor extends StatefulWidget {
  const PatternGridEditor({
    required this.grid,
    required this.stepCount,
    required this.scale,
    required this.onGridChanged,
    this.enabled = true,
    super.key,
  });

  // 2D grid indexed by step then row, true = active.
  final List<List<bool>> grid;
  final int stepCount;
  final PlinkyScale scale;
  final ValueChanged<List<List<bool>>> onGridChanged;
  final bool enabled;

  @override
  State<PatternGridEditor> createState() => _PatternGridEditorState();
}

class _PatternGridEditorState extends State<PatternGridEditor> {
  final _scrollController = ScrollController();

  /// Tracks whether the current drag gesture is painting or erasing cells.
  bool? _dragPaintValue;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleCell(int step, int row) {
    if (!widget.enabled) {
      return;
    }
    final newGrid = [
      for (var s = 0; s < widget.grid.length; s++)
        [for (var r = 0; r < 8; r++) widget.grid[s][r]],
    ];
    newGrid[step][row] = !newGrid[step][row];
    widget.onGridChanged(newGrid);
  }

  void _setCellValue(int step, int row, {required bool value}) {
    if (!widget.enabled) {
      return;
    }
    if (widget.grid[step][row] == value) {
      return;
    }
    final newGrid = [
      for (var s = 0; s < widget.grid.length; s++)
        [for (var r = 0; r < 8; r++) widget.grid[s][r]],
    ];
    newGrid[step][row] = value;
    widget.onGridChanged(newGrid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const cellSize = 36.0;
    const labelWidth = 48.0;

    // Each cell is cellSize + 2px margin (1px each side).
    const cellWithMargin = cellSize + 2;
    // Header row (step numbers) + 8 rows of cells.
    const gridHeight = 20.0 + cellWithMargin * 8;

    return Column(
      children: [
        Text('Pattern Grid', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: gridHeight,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row labels (note names)
                SizedBox(
                  width: labelWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      for (var row = 0; row < 8; row++)
                        SizedBox(
                          height: cellWithMargin,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                _midiNoteName(
                                  midiNoteForPad(
                                    row: row,
                                    col: 0,
                                    scale: widget.scale,
                                  ),
                                ),
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Scrollable grid
                Flexible(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step numbers header
                          Row(
                            children: [
                              for (
                                var step = 0;
                                step < widget.stepCount;
                                step++
                              )
                                SizedBox(
                                  width: cellWithMargin,
                                  height: 20,
                                  child: Center(
                                    child: Text(
                                      '${step + 1}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Grid cells
                          for (var row = 0; row < 8; row++)
                            Row(
                              children: [
                                for (
                                  var step = 0;
                                  step < widget.stepCount;
                                  step++
                                )
                                  _GridCell(
                                    isActive: widget.grid[step][row],
                                    isDownbeat: step % 4 == 0,
                                    cellSize: cellSize,
                                    colorScheme: colorScheme,
                                    onTap: () => _toggleCell(step, row),
                                    onDragStart: () {
                                      _dragPaintValue = !widget.grid[step][row];
                                      _toggleCell(step, row);
                                    },
                                    onDragEnter: () {
                                      if (_dragPaintValue != null) {
                                        _setCellValue(
                                          step,
                                          row,
                                          value: _dragPaintValue!,
                                        );
                                      }
                                    },
                                    onDragEnd: () => _dragPaintValue = null,
                                  ),
                              ],
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
      ],
    );
  }
}

class _GridCell extends StatefulWidget {
  const _GridCell({
    required this.isActive,
    required this.isDownbeat,
    required this.cellSize,
    required this.colorScheme,
    required this.onTap,
    required this.onDragStart,
    required this.onDragEnter,
    required this.onDragEnd,
  });

  final bool isActive;
  final bool isDownbeat;
  final double cellSize;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnter;
  final VoidCallback onDragEnd;

  @override
  State<_GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<_GridCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isActive
        ? widget.colorScheme.primary
        : widget.isDownbeat
        ? widget.colorScheme.surfaceContainerHighest
        : widget.colorScheme.surfaceContainerLow;
    final fillColor = _isHovered
        ? Color.lerp(
            baseColor,
            widget.colorScheme.onSurface,
            0.15,
          )!
        : baseColor;
    final borderColor = _isHovered
        ? widget.colorScheme.outline
        : widget.colorScheme.outlineVariant;

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
          builder: (context, _, __) => Container(
            width: widget.cellSize,
            height: widget.cellSize,
            decoration: BoxDecoration(
              color: fillColor,
              border: Border.all(
                color: borderColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.all(1),
          ),
        ),
      ),
    );
  }
}
