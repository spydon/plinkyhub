import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class SavedPatchesPage extends ConsumerStatefulWidget {
  const SavedPatchesPage({super.key});

  @override
  ConsumerState<SavedPatchesPage> createState() => _SavedPatchesPageState();
}

class _SavedPatchesPageState extends ConsumerState<SavedPatchesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        ref.read(savedPatchesProvider.notifier).fetchPublicPatches();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationState = ref.watch(authenticationProvider);
    final savedPatchesState = ref.watch(savedPatchesProvider);

    if (authenticationState.user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64),
            const SizedBox(height: 16),
            const Text('Sign in to save and manage your patches'),
            const SizedBox(height: 16),
            PlinkyButton(
              onPressed: () => showSignInDialog(context),
              icon: Icons.login,
              label: 'Sign in',
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Patches'),
            Tab(text: 'Community Patches'),
          ],
        ),
        if (savedPatchesState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              savedPatchesState.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _PatchList(
                patches: savedPatchesState.userPatches,
                isLoading: savedPatchesState.isLoading,
                isOwned: true,
                onRefresh: () => ref
                    .read(savedPatchesProvider.notifier)
                    .fetchUserPatches(),
              ),
              _PatchList(
                patches: savedPatchesState.publicPatches,
                isLoading: savedPatchesState.isLoading,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedPatchesProvider.notifier)
                    .fetchPublicPatches(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatchList extends ConsumerWidget {
  const _PatchList({
    required this.patches,
    required this.isLoading,
    required this.isOwned,
    required this.onRefresh,
  });

  final List<SavedPatch> patches;
  final bool isLoading;
  final bool isOwned;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && patches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (patches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isOwned
                  ? 'No saved patches yet'
                  : 'No community patches yet',
            ),
            const SizedBox(height: 8),
            PlinkyButton(
              onPressed: onRefresh,
              icon: Icons.refresh,
              label: 'Refresh',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patches.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${patches.length} patch${patches.length == 1 ? '' : 'es'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: onRefresh,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            );
          }

          final patch = patches[index - 1];
          return _PatchCard(
            patch: patch,
            isOwned: isOwned,
          );
        },
      ),
    );
  }
}

class _PatchCard extends ConsumerWidget {
  const _PatchCard({
    required this.patch,
    required this.isOwned,
  });

  final SavedPatch patch;
  final bool isOwned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                    patch.name.isEmpty ? '(unnamed)' : patch.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (patch.category.isNotEmpty)
                  Chip(
                    label: Text(
                      patch.category,
                      style: theme.textTheme.bodySmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (patch.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                patch.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(patch.updatedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                PlinkyButton(
                  onPressed: () {
                    ref
                        .read(savedPatchesProvider.notifier)
                        .loadPatchIntoEditor(patch);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Patch loaded into editor'),
                      ),
                    );
                  },
                  icon: Icons.download,
                  label: 'Load into editor',
                ),
                const Spacer(),
                if (isOwned) ...[
                  IconButton(
                    icon: Icon(
                      patch.isPublic
                          ? Icons.public
                          : Icons.public_off,
                      size: 20,
                    ),
                    tooltip: patch.isPublic
                        ? 'Make private'
                        : 'Make public',
                    onPressed: () {
                      ref
                          .read(savedPatchesProvider.notifier)
                          .updatePatch(
                            patch.id,
                            isPublic: !patch.isPublic,
                          );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete patch',
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete patch?'),
        content: Text(
          'Are you sure you want to delete '
          '"${patch.name.isEmpty ? '(unnamed)' : patch.name}"?',
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
                  .read(savedPatchesProvider.notifier)
                  .deletePatch(patch.id);
            },
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
