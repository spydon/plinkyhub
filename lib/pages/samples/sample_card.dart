import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/sample_mode_selector.dart';
import 'package:plinkyhub/pages/samples/slice_points_editor.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/utils/note_names.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';

class SampleCard extends ConsumerStatefulWidget {
  const SampleCard({
    required this.sample,
    required this.isOwned,
    super.key,
  });

  final SavedSample sample;
  final bool isOwned;

  @override
  ConsumerState<SampleCard> createState() => _SampleCardState();
}

class _SampleCardState extends ConsumerState<SampleCard> {
  bool _expanded = false;
  Uint8List? _wavBytes;
  int? _pcmFrameCount;
  bool _loadingWav = false;
  bool _saving = false;
  bool _showSavedMessage = false;
  late List<double> _slicePoints;
  late bool _pitched;
  late List<int> _sliceNotes;

  @override
  void initState() {
    super.initState();
    _slicePoints = List.of(widget.sample.slicePoints);
    _pitched = widget.sample.pitched;
    _sliceNotes = List.of(widget.sample.sliceNotes);
  }

  @override
  void didUpdateWidget(SampleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sample.id != widget.sample.id) {
      _slicePoints = List.of(widget.sample.slicePoints);
      _pitched = widget.sample.pitched;
      _sliceNotes = List.of(widget.sample.sliceNotes);
      _wavBytes = null;
      _expanded = false;
    }
  }

  Future<void> _loadWav() async {
    if (_wavBytes != null || _loadingWav) {
      return;
    }
    setState(() => _loadingWav = true);
    try {
      final bytes = await ref
          .read(savedSamplesProvider.notifier)
          .downloadWav(widget.sample.filePath);
      int? frameCount;
      try {
        final pcm = wavToPlinkyPcm(bytes);
        frameCount = pcm.length ~/ 2;
      } on FormatException catch (e) {
        // Preview still works without the constraint.
        debugPrint('Failed to compute PCM frame count: $e');
      }
      if (mounted) {
        setState(() {
          _wavBytes = bytes;
          _pcmFrameCount = frameCount;
          _loadingWav = false;
        });
      }
    } on Exception catch (e) {
      debugPrint('Failed to load WAV for preview: $e');
      if (mounted) {
        setState(() => _loadingWav = false);
      }
    }
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _loadWav();
    }
  }

  Future<void> _saveSampleSettings() async {
    setState(() => _saving = true);
    await ref
        .read(savedSamplesProvider.notifier)
        .updateSample(
          widget.sample.copyWith(
            slicePoints: _slicePoints,
            pitched: _pitched,
            sliceNotes: _sliceNotes,
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _showSavedMessage = true;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _showSavedMessage = false);
    }
  }

  bool get _hasUnsavedChanges =>
      _slicePoints != widget.sample.slicePoints ||
      _pitched != widget.sample.pitched ||
      _sliceNotes != widget.sample.sliceNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sample = widget.sample;
    final isOwned = widget.isOwned;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sample.name.isEmpty ? '(unnamed)' : sample.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    noteNameFromMidi(
                      sample.baseNote,
                      sample.fineTune,
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (sample.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                sample.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            UsernameDateLine(
              userId: sample.userId,
              username: sample.username,
              updatedAt: sample.updatedAt,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  tooltip: _expanded ? 'Hide slices' : 'Show slices',
                  onPressed: _toggleExpanded,
                ),
                const SizedBox(width: 8),
                StarButton(
                  isStarred: sample.isStarred,
                  starCount: sample.starCount,
                  onToggle: () => ref
                      .read(savedSamplesProvider.notifier)
                      .toggleStar(sample),
                ),
                if (sample.username.isNotEmpty)
                  ShareLinkButton(
                    username: sample.username,
                    itemType: 'sample',
                    itemName: sample.name,
                  ),
                const Spacer(),
                if (isOwned) ...[
                  IconButton(
                    icon: Icon(
                      sample.isPublic ? Icons.public : Icons.public_off,
                      size: 20,
                    ),
                    tooltip: sample.isPublic ? 'Make private' : 'Make public',
                    onPressed: () {
                      ref
                          .read(savedSamplesProvider.notifier)
                          .updateSample(
                            sample.copyWith(
                              isPublic: !sample.isPublic,
                            ),
                          );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                    ),
                    tooltip: 'Delete sample',
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              SampleModeSelector(
                pitched: _pitched,
                enabled: isOwned,
                onChanged: (value) => setState(() => _pitched = value),
              ),
              const SizedBox(height: 8),
              if (_loadingWav)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                SlicePointsEditor(
                  slicePoints: _slicePoints,
                  wavBytes: _wavBytes,
                  pcmFrameCount: _pcmFrameCount,
                  enabled: isOwned,
                  onChanged: (points) {
                    setState(() => _slicePoints = points);
                  },
                  pitched: _pitched,
                  sliceNotes: _sliceNotes,
                  onSliceNotesChanged: (notes) {
                    setState(() => _sliceNotes = notes);
                  },
                ),
              if (isOwned &&
                  (_hasUnsavedChanges || _saving || _showSavedMessage))
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: _showSavedMessage ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Changes saved',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PlinkyButton(
                        onPressed: _saving ? null : _saveSampleSettings,
                        icon: Icons.save,
                        label: 'Save changes',
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete sample?'),
        content: Text(
          'Are you sure you want to delete '
          '"${widget.sample.name.isEmpty ? '(unnamed)' : widget.sample.name}"?',
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
                  .read(savedSamplesProvider.notifier)
                  .deleteSample(widget.sample.id);
            },
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}
