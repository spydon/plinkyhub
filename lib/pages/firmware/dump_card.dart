import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/models/saved_dump.dart';
import 'package:plinkyhub/pages/firmware/providers/dumps_notifier.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class DumpCard extends ConsumerStatefulWidget {
  const DumpCard({required this.dump, super.key});

  final SavedDump dump;

  @override
  ConsumerState<DumpCard> createState() => _DumpCardState();
}

class _DumpCardState extends ConsumerState<DumpCard> {
  bool _isDownloadingInternal = false;
  bool _isDownloadingExternal = false;

  Future<void> _download({required bool external}) async {
    setState(() {
      if (external) {
        _isDownloadingExternal = true;
      } else {
        _isDownloadingInternal = true;
      }
    });

    try {
      final filePath = external
          ? widget.dump.externalFlashPath
          : widget.dump.internalFlashPath;
      if (filePath == null) {
        return;
      }
      final bytes = await ref
          .read(dumpsProvider.notifier)
          .downloadFlash(filePath: filePath);
      final safeTitle = _sanitizeFileName(
        widget.dump.title.isEmpty ? 'plinky_dump' : widget.dump.title,
      );
      final suffix = external ? 'ext' : 'int';
      downloadBytesToUser(bytes, '${safeTitle}_$suffix.bin');
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingInternal = false;
          _isDownloadingExternal = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete dump'),
        content: Text(
          'Delete "${widget.dump.title}"? '
          'This permanently removes the stored flash binaries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(dumpsProvider.notifier).deleteDump(widget.dump);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dump = widget.dump;
    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwner = currentUserId != null && dump.userId == currentUserId;
    final username = dump.username.isEmpty
        ? (isOwner ? 'you' : 'unknown')
        : dump.username;
    final createdAt = _formatDate(dump.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dump.title.isEmpty ? '(untitled)' : dump.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'by $username',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  createdAt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (dump.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                dump.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (dump.internalFlashPath != null)
                  PlinkyButton(
                    onPressed: _isDownloadingInternal
                        ? null
                        : () => _download(external: false),
                    icon: Icons.download,
                    label: _isDownloadingInternal
                        ? 'Downloading...'
                        : 'Internal flash '
                              '(${_formatBytes(dump.internalFlashSize)})',
                  ),
                if (dump.externalFlashPath != null)
                  PlinkyButton(
                    onPressed: _isDownloadingExternal
                        ? null
                        : () => _download(external: true),
                    icon: Icons.download,
                    label: _isDownloadingExternal
                        ? 'Downloading...'
                        : 'External flash '
                              '(${_formatBytes(dump.externalFlashSize)})',
                  ),
                if (isOwner)
                  PlinkyButton(
                    onPressed: _confirmDelete,
                    icon: Icons.delete_outline,
                    label: 'Delete',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _sanitizeFileName(String input) {
  final trimmed = input.trim();
  final replaced = trimmed.replaceAll(RegExp(r'[^A-Za-z0-9_\-]+'), '_');
  return replaced.isEmpty ? 'plinky_dump' : replaced;
}

String _formatBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  if (bytes >= 1024 * 1024) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(mb >= 10 ? 0 : 1)} MB';
  }
  if (bytes >= 1024) {
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(kb >= 10 ? 0 : 1)} KB';
  }
  return '$bytes B';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
