import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/harmonic_editor.dart';
import 'package:plinkyhub/pages/wavetables/waveform_drawer.dart';
import 'package:plinkyhub/pages/wavetables/waveform_effects_panel.dart';
import 'package:plinkyhub/pages/wavetables/waveform_thumbnail.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/utils/waveform_effects.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

/// Tab for creating wavetables by drawing waveforms directly in the browser.
class DrawWavetableTab extends ConsumerStatefulWidget {
  const DrawWavetableTab({this.onCreated, super.key});

  final VoidCallback? onCreated;

  @override
  ConsumerState<DrawWavetableTab> createState() => _DrawWavetableTabState();
}

class _DrawWavetableTabState extends ConsumerState<DrawWavetableTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isGenerating = false;
  bool _isUploading = false;
  String? _errorMessage;

  int _selectedSlot = 0;
  DrawingTool _selectedTool = DrawingTool.pencil;

  late final List<List<double>> _slots;
  late final List<WaveformEffects> _effects;

  /// Cached post-effect samples for the selected slot.
  List<double>? _postEffectSamples;

  @override
  void initState() {
    super.initState();
    _slots = List<List<double>>.generate(
      wavetableUserShapeCount,
      (_) => generateSinePreset(),
    );
    _effects = List<WaveformEffects>.generate(
      wavetableUserShapeCount,
      (_) => WaveformEffects(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isBusy => _isGenerating || _isUploading;

  WaveformEffects get _currentEffects => _effects[_selectedSlot];

  void _updatePostEffectSamples() {
    if (_currentEffects.hasAnyEffect) {
      _postEffectSamples = applyEffects(
        _slots[_selectedSlot],
        _currentEffects,
      );
    } else {
      _postEffectSamples = null;
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _isPublic = true;
      _isGenerating = false;
      _isUploading = false;
      _errorMessage = null;
      _selectedSlot = 0;
      _selectedTool = DrawingTool.pencil;
      _postEffectSamples = null;
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = generateSinePreset();
        _effects[i].reset();
      }
    });
  }

  void _applyPresetToSlot(List<double> Function() generator) {
    setState(() {
      _slots[_selectedSlot] = generator();
      _updatePostEffectSamples();
    });
  }

  void _applyPresetToAll(List<double> Function() generator) {
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = generator();
      }
      _updatePostEffectSamples();
    });
  }

  void _copyToAllSlots() {
    final source = List<double>.from(_slots[_selectedSlot]);
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = List<double>.from(source);
      }
    });
  }

  void _bakeEffects() {
    setState(() {
      _slots[_selectedSlot] = applyEffects(
        _slots[_selectedSlot],
        _currentEffects,
      );
      _currentEffects.reset();
      _postEffectSamples = null;
    });
  }

  /// Returns samples for upload: baked with effects applied.
  List<List<double>> _getFinalSamples() {
    return List<List<double>>.generate(_slots.length, (i) {
      if (_effects[i].hasAnyEffect) {
        return applyEffects(_slots[i], _effects[i]);
      }
      return _slots[i];
    });
  }

  Future<void> _createAndUpload() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      await Future<void>.delayed(Duration.zero);

      final finalSamples = _getFinalSamples();
      final uf2Bytes = generateWavetableUf2FromSamples(finalSamples);

      setState(() {
        _isGenerating = false;
        _isUploading = true;
      });

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'wavetable';
      final storageName = '${name}_$timestamp.uf2';

      final wavetable = SavedWavetable(
        id: '',
        userId: userId,
        name: name,
        filePath: '$userId/$storageName',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
      );

      await ref
          .read(savedWavetablesProvider.notifier)
          .saveWavetable(wavetable, uf2Bytes: uf2Bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wavetable created')),
        );
        _resetForm();
        widget.onCreated?.call();
      }
    } on FormatException catch (formatError) {
      setState(() {
        _isGenerating = false;
        _isUploading = false;
        _errorMessage = formatError.message;
      });
    } on Exception catch (error) {
      debugPrint('Failed to create wavetable: $error');
      setState(() {
        _isGenerating = false;
        _isUploading = false;
        _errorMessage = error.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updatePostEffectSamples();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DrawWavetableDescription(),
              const SizedBox(height: 12),
              _SlotThumbnailSelector(
                slots: _slots,
                selectedSlot: _selectedSlot,
                onSlotSelected: (index) {
                  setState(() {
                    _selectedSlot = index;
                    _updatePostEffectSamples();
                  });
                },
              ),
              const SizedBox(height: 12),
              _DrawingToolSelector(
                selectedTool: _selectedTool,
                onToolSelected: (tool) {
                  setState(() => _selectedTool = tool);
                },
              ),
              const SizedBox(height: 8),
              WaveformDrawer(
                samples: _slots[_selectedSlot],
                postEffectSamples: _postEffectSamples,
                tool: _selectedTool,
                onSamplesChanged: (updatedSamples) {
                  setState(() {
                    _slots[_selectedSlot] = updatedSamples;
                    _updatePostEffectSamples();
                  });
                },
              ),
              const SizedBox(height: 12),
              HarmonicEditor(
                samples: _slots[_selectedSlot],
                postEffectSamples: _postEffectSamples,
                onSamplesChanged: (updatedSamples) {
                  setState(() {
                    _slots[_selectedSlot] = updatedSamples;
                    _updatePostEffectSamples();
                  });
                },
              ),
              const SizedBox(height: 12),
              _PresetButtons(
                isBusy: _isBusy,
                onPresetSelected: _applyPresetToSlot,
              ),
              const SizedBox(height: 8),
              _BulkActions(
                isBusy: _isBusy,
                onCopyToAll: _copyToAllSlots,
                onSineAll: () => _applyPresetToAll(generateSinePreset),
              ),
              const SizedBox(height: 16),
              WaveformEffectsPanel(
                effects: _currentEffects,
                enabled: !_isBusy,
                onEffectsChanged: () {
                  setState(_updatePostEffectSamples);
                },
                onApply: _bakeEffects,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Share with community'),
                value: _isPublic,
                onChanged: _isBusy
                    ? null
                    : (value) => setState(() => _isPublic = value),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                _ErrorMessageText(errorMessage: _errorMessage!),
              ],
              const SizedBox(height: 16),
              if (_isGenerating)
                const _GeneratingIndicator()
              else
                PlinkyButton(
                  onPressed: _isBusy ? null : _createAndUpload,
                  icon: _isUploading ? Icons.hourglass_empty : Icons.upload,
                  label: _isUploading ? 'Uploading...' : 'Create & Upload',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawWavetableDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Draw waveforms for each of the 15 slots (c0–c14). '
      'Select a slot, then click and drag on the canvas to shape '
      'the waveform. Edit harmonics in the bar chart below. '
      'Use the waveshaper effects to further sculpt the sound. '
      'A built-in saw and sine are added automatically as the '
      'first and last shapes.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SlotThumbnailSelector extends StatefulWidget {
  const _SlotThumbnailSelector({
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final List<List<double>> slots;
  final int selectedSlot;
  final ValueChanged<int> onSlotSelected;

  @override
  State<_SlotThumbnailSelector> createState() => _SlotThumbnailSelectorState();
}

class _SlotThumbnailSelectorState extends State<_SlotThumbnailSelector> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        trackVisibility: WidgetStateProperty.all(true),
        thumbVisibility: WidgetStateProperty.all(true),
      ),
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: List.generate(wavetableUserShapeCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < wavetableUserShapeCount - 1 ? 4 : 0,
                ),
                child: WaveformThumbnail(
                  samples: widget.slots[index],
                  isSelected: index == widget.selectedSlot,
                  slotIndex: index,
                  onTap: () => widget.onSlotSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _DrawingToolSelector extends StatelessWidget {
  const _DrawingToolSelector({
    required this.selectedTool,
    required this.onToolSelected,
  });

  final DrawingTool selectedTool;
  final ValueChanged<DrawingTool> onToolSelected;

  static const _toolLabels = {
    DrawingTool.pencil: 'Pencil',
    DrawingTool.brush: 'Brush',
    DrawingTool.grab: 'Grab',
    DrawingTool.line: 'Line',
    DrawingTool.eraser: 'Eraser',
    DrawingTool.smooth: 'Smooth',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: DrawingTool.values.map((tool) {
        final isSelected = tool == selectedTool;
        return ChoiceChip(
          label: Text(_toolLabels[tool]!),
          selected: isSelected,
          onSelected: (_) => onToolSelected(tool),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}

class _PresetButtons extends StatelessWidget {
  const _PresetButtons({
    required this.isBusy,
    required this.onPresetSelected,
  });

  final bool isBusy;
  final void Function(List<double> Function() generator) onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Presets', style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _PresetChip(
              label: 'Sine',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateSinePreset),
            ),
            _PresetChip(
              label: 'Saw',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateSawPreset),
            ),
            _PresetChip(
              label: 'Triangle',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateTrianglePreset),
            ),
            _PresetChip(
              label: 'Square',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateSquarePreset),
            ),
            _PresetChip(
              label: 'Rectangle',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateRectanglePreset),
            ),
            _PresetChip(
              label: 'Rectified',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateRectifiedSinePreset),
            ),
            _PresetChip(
              label: 'Noise',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateNoisePreset),
            ),
            _PresetChip(
              label: 'Chirp',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateChirpPreset),
            ),
            _PresetChip(
              label: 'Flat',
              onPressed: isBusy
                  ? null
                  : () => onPresetSelected(generateFlatPreset),
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

class _BulkActions extends StatelessWidget {
  const _BulkActions({
    required this.isBusy,
    required this.onCopyToAll,
    required this.onSineAll,
  });

  final bool isBusy;
  final VoidCallback onCopyToAll;
  final VoidCallback onSineAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bulk actions', style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ActionChip(
              label: const Text('Copy to all slots'),
              onPressed: isBusy ? null : onCopyToAll,
            ),
            ActionChip(
              label: const Text('Reset all to sine'),
              onPressed: isBusy ? null : onSineAll,
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorMessageText extends StatelessWidget {
  const _ErrorMessageText({required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      errorMessage,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
      ),
    );
  }
}

class _GeneratingIndicator extends StatelessWidget {
  const _GeneratingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 8),
        Text('Generating wavetable...'),
      ],
    );
  }
}
