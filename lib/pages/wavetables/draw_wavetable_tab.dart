import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/wavetables/harmonic_editor.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/providers/saved_wavetables_notifier.dart';
import 'package:plinkyhub/pages/wavetables/utils/waveform_effects.dart';
import 'package:plinkyhub/pages/wavetables/waveform_drawer.dart';
import 'package:plinkyhub/pages/wavetables/waveform_effects_panel.dart';
import 'package:plinkyhub/pages/wavetables/waveform_thumbnail.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_player.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/utils/wavetable_cache.dart';
import 'package:plinkyhub/utils/wavetable_import.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

/// Tab for creating or editing wavetables by drawing waveforms directly in the
/// browser.
class DrawWavetableTab extends ConsumerStatefulWidget {
  const DrawWavetableTab({
    this.onCreated,
    this.wavetableToEdit,
    super.key,
  });

  final VoidCallback? onCreated;

  /// When non-null, the editor opens in edit mode with this wavetable's data.
  final SavedWavetable? wavetableToEdit;

  @override
  ConsumerState<DrawWavetableTab> createState() => _DrawWavetableTabState();
}

class _DrawWavetableTabState extends ConsumerState<DrawWavetableTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  bool _isPublic = true;
  bool _isGenerating = false;
  bool _isUploading = false;
  bool _isLoadingExisting = false;
  String? _errorMessage;

  int _selectedSlot = 0;
  DrawingTool _selectedTool = DrawingTool.pencil;

  late final List<List<double>> _slots;
  late final List<WaveformEffects> _effects;
  late final WavetableCache _cache;

  bool get _isEditing => widget.wavetableToEdit != null;

  void _onNameChanged() => setState(() {});

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
    _cache = WavetableCache(_slots, _effects);

    if (widget.wavetableToEdit != null) {
      _nameController.addListener(_onNameChanged);
      _nameController.text = widget.wavetableToEdit!.name;
      _descriptionController.text = widget.wavetableToEdit!.description;
      _youtubeUrlController.text = widget.wavetableToEdit!.youtubeUrl;
      _isPublic = widget.wavetableToEdit!.isPublic;
      _loadExistingWavetable();
    }
  }

  Future<void> _loadExistingWavetable() async {
    if (widget.wavetableToEdit == null) {
      return;
    }
    setState(() => _isLoadingExisting = true);
    try {
      final uf2Bytes = await ref
          .read(savedWavetablesProvider.notifier)
          .downloadUf2(widget.wavetableToEdit!.filePath);
      final rawData = uf2ToData(uf2Bytes);
      final samples = extractSamplesFromWavetableData(rawData);
      if (mounted) {
        setState(() {
          for (var i = 0; i < samples.length; i++) {
            _slots[i] = samples[i];
            _cache.invalidate(i, _slots[i], _effects[i]);
          }
          _isLoadingExisting = false;
        });
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingExisting = false;
          _errorMessage = 'Failed to load wavetable: $error';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  bool get _isBusy => _isGenerating || _isUploading || _isLoadingExisting;

  WaveformEffects get _currentEffects => _effects[_selectedSlot];

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _youtubeUrlController.clear();
      _isPublic = true;
      _isGenerating = false;
      _isUploading = false;
      _errorMessage = null;
      _selectedSlot = 0;
      _selectedTool = DrawingTool.pencil;
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = generateSinePreset();
        _effects[i].reset();
        _cache.invalidate(i, _slots[i], _effects[i]);
      }
    });
  }

  void _applyPresetToSlot(List<double> Function() generator) {
    setState(() {
      _slots[_selectedSlot] = generator();
      _cache.invalidate(
        _selectedSlot,
        _slots[_selectedSlot],
        _effects[_selectedSlot],
      );
    });
  }

  void _applyPresetToAll(List<double> Function() generator) {
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = generator();
        _cache.invalidate(i, _slots[i], _effects[i]);
      }
    });
  }

  Future<void> _importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['uf2', 'wt'],
      withData: true,
    );

    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) {
      return;
    }

    try {
      final uf2Bytes = importedFileToWavetableUf2(bytes);
      final samples = extractSamplesFromWavetableData(uf2ToData(uf2Bytes));
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = null;
        for (var i = 0; i < samples.length && i < _slots.length; i++) {
          _slots[i] = samples[i];
          _effects[i].reset();
          _cache.invalidate(i, _slots[i], _effects[i]);
        }
        _selectedSlot = 0;
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = file.name.replaceAll(
            RegExp(r'\.(uf2|wt)$', caseSensitive: false),
            '',
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wavetable imported into slots')),
      );
    } on FormatException catch (error) {
      setState(() => _errorMessage = error.message);
    } on Exception catch (error) {
      debugPrint('Failed to import wavetable: $error');
      setState(() => _errorMessage = error.toString());
    }
  }

  void _copyToAllSlots() {
    final source = List<double>.from(_slots[_selectedSlot]);
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = List<double>.from(source);
        _cache.invalidate(i, _slots[i], _effects[i]);
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
      _cache.invalidate(
        _selectedSlot,
        _slots[_selectedSlot],
        _effects[_selectedSlot],
      );
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

      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'wavetable';

      final shouldOverwrite =
          _isEditing && name == widget.wavetableToEdit!.name;

      final username = ref.read(authenticationProvider).username;

      if (shouldOverwrite) {
        final existing = widget.wavetableToEdit!;
        await ref
            .read(savedWavetablesProvider.notifier)
            .updateWavetableContent(
              existing.copyWith(
                name: name,
                description: _descriptionController.text.trim(),
                isPublic: _isPublic,
                youtubeUrl: _youtubeUrlController.text.trim(),
              ),
              uf2Bytes: uf2Bytes,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wavetable updated')),
          );
          if (username != null) {
            context.go(
              AppRoute.wavetables.itemPage(username, existing.slug),
            );
          }
        }
      } else {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
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
          youtubeUrl: _youtubeUrlController.text.trim(),
        );

        final saved = await ref
            .read(savedWavetablesProvider.notifier)
            .saveWavetable(wavetable, uf2Bytes: uf2Bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wavetable created')),
          );
          if (username != null && saved != null) {
            context.go(
              AppRoute.wavetables.itemPage(username, saved.slug),
            );
          } else {
            _resetForm();
            widget.onCreated?.call();
          }
        }
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
    final nameMatchesOriginal =
        _isEditing &&
        _nameController.text.trim() == widget.wavetableToEdit!.name;
    final String buttonLabel;
    final IconData buttonIcon;
    if (_isEditing && nameMatchesOriginal) {
      buttonLabel = 'Overwrite';
      buttonIcon = Icons.save;
    } else if (_isEditing) {
      buttonLabel = 'Save as new';
      buttonIcon = Icons.save_as;
    } else {
      buttonLabel = 'Create & Upload';
      buttonIcon = Icons.upload;
    }

    final infoSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DrawWavetableDescription(),
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
          minLines: 3,
          maxLines: null,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _youtubeUrlController,
          decoration: const InputDecoration(
            labelText: 'YouTube URL (optional)',
            hintText: 'https://www.youtube.com/watch?v=...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Share with community'),
          value: _isPublic,
          onChanged: _isBusy
              ? null
              : (value) => setState(() => _isPublic = value),
          contentPadding: EdgeInsets.zero,
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
            icon: _isUploading ? Icons.hourglass_empty : buttonIcon,
            label: _isUploading ? 'Uploading...' : buttonLabel,
          ),
        const SizedBox(height: 16),
        WavetablePlayer(cache: _cache),
      ],
    );

    final editorSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SlotThumbnailSelector(
          slots: _slots,
          selectedSlot: _selectedSlot,
          onSlotSelected: (index) {
            setState(() {
              _selectedSlot = index;
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
          postEffectSamples: _cache[_selectedSlot].postEffectSamples,
          tool: _selectedTool,
          onSamplesChanged: (updatedSamples) {
            setState(() {
              _slots[_selectedSlot] = updatedSamples;
              _cache.invalidate(
                _selectedSlot,
                _slots[_selectedSlot],
                _effects[_selectedSlot],
              );
            });
          },
        ),
        const SizedBox(height: 12),
        HarmonicEditor(
          samples: _slots[_selectedSlot],
          postEffectSamples: _cache[_selectedSlot].postEffectSamples,
          onSamplesChanged: (updatedSamples) {
            setState(() {
              _slots[_selectedSlot] = updatedSamples;
              _cache.invalidate(
                _selectedSlot,
                _slots[_selectedSlot],
                _effects[_selectedSlot],
              );
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
          onImport: _importFromFile,
        ),
        const SizedBox(height: 16),
        WaveformEffectsPanel(
          effects: _currentEffects,
          enabled: !_isBusy,
          onEffectsChanged: () {
            _cache.invalidate(
              _selectedSlot,
              _slots[_selectedSlot],
              _effects[_selectedSlot],
            );
            setState(() {});
          },
          onApply: _bakeEffects,
        ),
      ],
    );

    if (_isLoadingExisting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading wavetable...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1000) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 340, child: infoSection),
                    const SizedBox(width: 32),
                    Expanded(child: editorSection),
                  ],
                );
              }
              return Column(
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
                    postEffectSamples: _cache[_selectedSlot].postEffectSamples,
                    tool: _selectedTool,
                    onSamplesChanged: (updatedSamples) {
                      setState(() {
                        _slots[_selectedSlot] = updatedSamples;
                        _cache.invalidate(
                          _selectedSlot,
                          _slots[_selectedSlot],
                          _effects[_selectedSlot],
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  HarmonicEditor(
                    samples: _slots[_selectedSlot],
                    postEffectSamples: _cache[_selectedSlot].postEffectSamples,
                    onSamplesChanged: (updatedSamples) {
                      setState(() {
                        _slots[_selectedSlot] = updatedSamples;
                        _cache.invalidate(
                          _selectedSlot,
                          _slots[_selectedSlot],
                          _effects[_selectedSlot],
                        );
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
                    onImport: _importFromFile,
                  ),
                  const SizedBox(height: 16),
                  WaveformEffectsPanel(
                    effects: _currentEffects,
                    enabled: !_isBusy,
                    onEffectsChanged: () {
                      _cache.invalidate(
                        _selectedSlot,
                        _slots[_selectedSlot],
                        _effects[_selectedSlot],
                      );
                      setState(() {});
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
                    minLines: 3,
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _youtubeUrlController,
                    decoration: const InputDecoration(
                      labelText: 'YouTube URL (optional)',
                      hintText: 'https://www.youtube.com/watch?v=...',
                      border: OutlineInputBorder(),
                    ),
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
              );
            },
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
      'You can also import a .wt or wavetable .uf2 file to load its '
      'shapes into the slots for editing. '
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

  static const _toolData = {
    DrawingTool.pencil: (label: 'Pencil', icon: Icons.edit),
    DrawingTool.brush: (label: 'Brush', icon: Icons.brush),
    DrawingTool.grab: (label: 'Grab', icon: Icons.pan_tool),
    DrawingTool.line: (label: 'Line', icon: Icons.show_chart),
    DrawingTool.eraser: (label: 'Eraser', icon: Icons.auto_fix_normal),
    DrawingTool.smooth: (label: 'Smooth', icon: Icons.waves),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: DrawingTool.values.map((tool) {
        final isSelected = tool == selectedTool;
        final data = _toolData[tool]!;
        return ChoiceChip(
          avatar: Icon(data.icon, size: 18),
          label: Text(data.label),
          selected: isSelected,
          showCheckmark: false,
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
    required this.onImport,
  });

  final bool isBusy;
  final VoidCallback onCopyToAll;
  final VoidCallback onSineAll;
  final VoidCallback onImport;

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
            ActionChip(
              avatar: const Icon(Icons.file_open, size: 18),
              label: const Text('Import .wt / .uf2'),
              onPressed: isBusy ? null : onImport,
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
    return CopyableErrorMessage(
      message: errorMessage,
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
