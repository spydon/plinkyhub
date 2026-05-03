import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/main.dart';
import 'package:plinkyhub/models/midi_state.dart';
import 'package:plinkyhub/pages/play/providers/midi_play_notifier.dart';
import 'package:plinkyhub/pages/play/webcam_play_tab.dart';
import 'package:plinkyhub/providers/midi_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
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

String _midiNoteName(int midi) {
  final octave = (midi ~/ 12) - 1;
  return '${_noteNames[midi % 12]}$octave';
}

const _presetSlotCount = 32;

enum PlayTab { pads, webcam }

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({this.initialTab, super.key});

  final String? initialTab;

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  PlinkyScale _scale = PlinkyScale.major;
  int _octaveOffset = 0;
  int? _presetSlot;
  bool _latch = false;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab != null
        ? PlayTab.values
              .firstWhere(
                (tab) => tab.name == widget.initialTab,
                orElse: () => PlayTab.pads,
              )
              .index
        : 0;
    _tabController = TabController(
      length: PlayTab.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);
    Future.microtask(() async {
      final midiState = ref.read(midiProvider);
      if (!midiState.isConnected) {
        await ref.read(midiProvider.notifier).connect();
      }
    });
  }

  @override
  void didUpdateWidget(PlayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      final tab = PlayTab.values.firstWhere(
        (tab) => tab.name == widget.initialTab,
        orElse: () => PlayTab.pads,
      );
      if (_tabController.index != tab.index) {
        _tabController.animateTo(tab.index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tabName = PlayTab.values[_tabController.index].name;
      context.go(AppRoute.play.tab(tabName));
      // Rebuild so WebcamPlayTab receives the updated active flag.
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onLatchChanged(bool value) {
    setState(() => _latch = value);
    if (!value) {
      ref.read(midiPlayProvider.notifier).releaseAll();
    }
  }

  void _onPresetSlotChanged(int? slot) {
    setState(() => _presetSlot = slot);
    if (slot != null) {
      ref.read(midiProvider.notifier).sendProgramChange(slot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final midiState = ref.watch(midiProvider);
    final hasOutput = midiState.selectedOutputId != null;
    final isPlayPageVisible =
        ShellBranchIndex.of(context) == AppRoute.play.index;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Shared controls, visible for both tabs.
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PlinkyScale>(
                  initialValue: _scale,
                  decoration: const InputDecoration(
                    labelText: 'Scale',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    for (final scale in PlinkyScale.values)
                      DropdownMenuItem(
                        value: scale,
                        child: Text(scale.displayName),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _scale = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int>(
                  initialValue: _octaveOffset,
                  decoration: const InputDecoration(
                    labelText: 'Octave',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    for (var octave = -4; octave <= 4; octave++)
                      DropdownMenuItem(
                        value: octave,
                        child: Text(octave >= 0 ? '+$octave' : '$octave'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _octaveOffset = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MidiOutputDropdown(
                  midiState: midiState,
                  onSelected: ref.read(midiProvider.notifier).selectOutput,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Sends a program change to switch the Plinky preset',
                  child: DropdownButtonFormField<int?>(
                    initialValue: _presetSlot,
                    decoration: const InputDecoration(
                      labelText: 'Preset slot (optional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        child: Text('Use currently selected preset'),
                      ),
                      for (var slot = 0; slot < _presetSlotCount; slot++)
                        DropdownMenuItem<int?>(
                          value: slot,
                          child: Text('Preset ${slot + 1}'),
                        ),
                    ],
                    onChanged: _onPresetSlotChanged,
                  ),
                ),
              ),
              if (_tabController.index == PlayTab.pads.index) ...[
                const SizedBox(width: 16),
                Tooltip(
                  message: 'Hold notes until you tap the pad again',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Latch'),
                      Switch(value: _latch, onChanged: _onLatchChanged),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!hasOutput) ...[
            const SizedBox(height: 12),
            Text(
              'No MIDI output detected. Plug in your Plinky and refresh '
              'the MIDI access permission if needed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Pads'),
              Tab(text: 'Webcam'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PadsTab(
                  scale: _scale,
                  octaveOffset: _octaveOffset,
                  enabled: hasOutput,
                  latch: _latch,
                ),
                WebcamPlayTab(
                  scale: _scale,
                  octaveOffset: _octaveOffset,
                  enabled: hasOutput,
                  latch: _latch,
                  active:
                      isPlayPageVisible &&
                      _tabController.index == PlayTab.webcam.index,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Pads tab
// -----------------------------------------------------------------------

class _PadsTab extends ConsumerWidget {
  const _PadsTab({
    required this.scale,
    required this.octaveOffset,
    required this.enabled,
    required this.latch,
  });

  final PlinkyScale scale;
  final int octaveOffset;
  final bool enabled;
  final bool latch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pressureByPad = ref.watch(
      midiPlayProvider.select((state) => state.pressureByPad),
    );

    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HintRow(
                  icon: Icons.touch_app_outlined,
                  text: 'Press near the centre for full velocity',
                  style: hintStyle,
                ),
                const SizedBox(height: 8),
                _HintRow(
                  icon: Icons.swipe_outlined,
                  text: 'Slide to send polyphonic aftertouch',
                  style: hintStyle,
                ),
                const SizedBox(height: 8),
                _HintRow(
                  icon: Icons.double_arrow_outlined,
                  text: 'Double-tap a pad to latch it',
                  style: hintStyle,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: _PadGrid(
                scale: scale,
                octaveOffset: octaveOffset,
                pressureByPad: pressureByPad,
                enabled: enabled,
                latch: latch,
              ),
            ),
          ),
        ),
        const SizedBox(width: 180),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// Shared widgets
class _HintRow extends StatelessWidget {
  const _HintRow({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: style?.color),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: style)),
      ],
    );
  }
}

// -----------------------------------------------------------------------

class _MidiOutputDropdown extends StatelessWidget {
  const _MidiOutputDropdown({
    required this.midiState,
    required this.onSelected,
  });

  final MidiState midiState;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final outputs = midiState.outputs;
    if (outputs.isEmpty) {
      return const Text('No MIDI outputs');
    }
    return DropdownButtonFormField<String>(
      initialValue: midiState.selectedOutputId,
      decoration: const InputDecoration(
        labelText: 'MIDI output',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: [
        for (final output in outputs)
          DropdownMenuItem<String>(
            value: output.id,
            child: Text(
              output.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onSelected,
    );
  }
}

// -----------------------------------------------------------------------
// Pad grid (touch-based MIDI controller)
// -----------------------------------------------------------------------

class _PadGrid extends ConsumerStatefulWidget {
  const _PadGrid({
    required this.scale,
    required this.octaveOffset,
    required this.pressureByPad,
    required this.enabled,
    required this.latch,
  });

  final PlinkyScale scale;
  final int octaveOffset;
  final Map<int, double> pressureByPad;
  final bool enabled;
  final bool latch;

  @override
  ConsumerState<_PadGrid> createState() => _PadGridState();
}

class _PadGridState extends ConsumerState<_PadGrid> {
  final Map<int, int> _pointerToPad = {};
  final Set<int> _pointersThatToggledOff = {};
  final Map<int, int> _lastPointerDownTimeByPad = {};
  final Set<int> _individuallyLatchedPads = {};

  static const _doubleTapThresholdMs = 300;

  @override
  void didUpdateWidget(covariant _PadGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latch != oldWidget.latch) {
      _individuallyLatchedPads.clear();
    }
  }

  ({int row, int column, int padIndex, double pressure})? _hitTest(
    Offset position,
    Size size,
  ) {
    final cellWidth = size.width / 8;
    final cellHeight = size.height / 8;
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= size.width ||
        position.dy >= size.height) {
      return null;
    }
    final column = (position.dx / cellWidth).floor().clamp(0, 7);
    final row = (position.dy / cellHeight).floor().clamp(0, 7);

    final padOriginX = column * cellWidth + 2;
    final padOriginY = row * cellHeight + 2;
    final innerWidth = cellWidth - 4;
    final innerHeight = cellHeight - 4;
    final localX = position.dx - padOriginX;
    final localY = position.dy - padOriginY;
    final centre = Offset(innerWidth / 2, innerHeight / 2);
    final radius = min(innerWidth, innerHeight) / 2;
    if (radius <= 0) {
      return (
        row: row,
        column: column,
        padIndex: row * 8 + column,
        pressure: 0,
      );
    }
    final distance = (Offset(localX, localY) - centre).distance;
    final pressure = (1 - distance / radius).clamp(0.0, 1.0);
    return (
      row: row,
      column: column,
      padIndex: row * 8 + column,
      pressure: pressure,
    );
  }

  void _pressPad({
    required int row,
    required int column,
    required double pressure,
  }) {
    ref
        .read(midiPlayProvider.notifier)
        .pressPad(
          row: row,
          column: column,
          scale: widget.scale,
          octaveOffset: widget.octaveOffset,
          pressure: pressure,
        );
  }

  void _updatePressure({
    required int row,
    required int column,
    required double pressure,
  }) {
    ref
        .read(midiPlayProvider.notifier)
        .updatePadPressure(row: row, column: column, pressure: pressure);
  }

  void _releasePad(int padIndex) {
    final row = padIndex ~/ 8;
    final column = padIndex % 8;
    ref.read(midiPlayProvider.notifier).releasePad(row, column);
  }

  void _onPointerDown(PointerDownEvent event, Size gridSize) {
    final hit = _hitTest(event.localPosition, gridSize);
    if (hit == null) {
      return;
    }
    final padIndex = hit.padIndex;
    if (widget.latch) {
      if (widget.pressureByPad.containsKey(padIndex)) {
        _releasePad(padIndex);
        _pointersThatToggledOff.add(event.pointer);
      } else {
        _pressPad(row: hit.row, column: hit.column, pressure: hit.pressure);
      }
    } else {
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastTap = _lastPointerDownTimeByPad[padIndex];
      final isDoubleTap =
          lastTap != null && (now - lastTap) < _doubleTapThresholdMs;

      if (_individuallyLatchedPads.contains(padIndex)) {
        _individuallyLatchedPads.remove(padIndex);
        _releasePad(padIndex);
        _pointersThatToggledOff.add(event.pointer);
      } else if (isDoubleTap) {
        _individuallyLatchedPads.add(padIndex);
        _pressPad(row: hit.row, column: hit.column, pressure: hit.pressure);
      } else {
        _pressPad(row: hit.row, column: hit.column, pressure: hit.pressure);
      }
      _lastPointerDownTimeByPad[padIndex] = now;
    }
    _pointerToPad[event.pointer] = padIndex;
  }

  void _onPointerMove(PointerMoveEvent event, Size gridSize) {
    final hit = _hitTest(event.localPosition, gridSize);
    final previousPad = _pointerToPad[event.pointer];

    if (hit == null) {
      if (previousPad != null &&
          !widget.latch &&
          !_individuallyLatchedPads.contains(previousPad)) {
        _releasePad(previousPad);
      }
      _pointerToPad.remove(event.pointer);
      _pointersThatToggledOff.remove(event.pointer);
      return;
    }

    if (hit.padIndex == previousPad) {
      _updatePressure(
        row: hit.row,
        column: hit.column,
        pressure: hit.pressure,
      );
      return;
    }

    if (widget.latch) {
      _pointerToPad[event.pointer] = hit.padIndex;
      _pointersThatToggledOff.remove(event.pointer);
      return;
    }

    if (previousPad != null &&
        !_individuallyLatchedPads.contains(previousPad)) {
      _releasePad(previousPad);
    }
    _pressPad(row: hit.row, column: hit.column, pressure: hit.pressure);
    _pointerToPad[event.pointer] = hit.padIndex;
  }

  void _onPointerUp(PointerEvent event) {
    final padIndex = _pointerToPad.remove(event.pointer);
    final toggledOff = _pointersThatToggledOff.remove(event.pointer);
    if (padIndex == null) {
      return;
    }
    if (widget.latch || toggledOff) {
      return;
    }
    if (_individuallyLatchedPads.contains(padIndex)) {
      return;
    }
    _releasePad(padIndex);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: disabled
              ? null
              : (event) => _onPointerDown(event, size),
          onPointerMove: disabled
              ? null
              : (event) => _onPointerMove(event, size),
          onPointerUp: disabled ? null : _onPointerUp,
          onPointerCancel: disabled ? null : _onPointerUp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var row = 0; row < 8; row++)
                Expanded(
                  child: Row(
                    children: [
                      for (var column = 0; column < 8; column++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: _Pad(
                              midiNote: midiNoteForPad(
                                row: row,
                                column: column,
                                scale: widget.scale,
                                octaveOffset: widget.octaveOffset,
                              ),
                              pressure:
                                  widget.pressureByPad[row * 8 + column] ?? 0,
                              isActive: widget.pressureByPad.containsKey(
                                row * 8 + column,
                              ),
                              enabled: widget.enabled,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({
    required this.midiNote,
    required this.pressure,
    required this.isActive,
    required this.enabled,
  });

  final int midiNote;
  final double pressure;
  final bool isActive;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disabled = !enabled;
    final activeFill = Color.lerp(
      colorScheme.surfaceContainerHighest,
      colorScheme.primary,
      pressure,
    )!;
    final fillColor = disabled
        ? colorScheme.surfaceContainerLow
        : isActive
        ? activeFill
        : colorScheme.surfaceContainerHighest;
    final textColor = isActive && pressure > 0.5
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: disabled ? 0.4 : 0.85);

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _midiNoteName(midiNote),
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
