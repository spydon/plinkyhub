import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class SavedPacksPage extends ConsumerStatefulWidget {
  const SavedPacksPage({super.key});

  @override
  ConsumerState<SavedPacksPage> createState() => _SavedPacksPageState();
}

class _SavedPacksPageState extends ConsumerState<SavedPacksPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        ref.read(savedPacksProvider.notifier).fetchPublicPacks();
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
    final savedPacksState = ref.watch(savedPacksProvider);
    final isSignedIn = authenticationState.user != null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Packs'),
            Tab(text: 'Create Pack'),
            Tab(text: 'Community Packs'),
          ],
        ),
        if (savedPacksState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              savedPacksState.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              if (isSignedIn)
                _PackList(
                  packs: savedPacksState.userPacks,
                  isLoading: savedPacksState.isLoading,
                  isOwned: true,
                  onRefresh: () =>
                      ref.read(savedPacksProvider.notifier).fetchUserPacks(),
                )
              else
                const _SignInPrompt(
                  message: 'Sign in to save and manage your packs',
                ),
              if (isSignedIn)
                const _CreatePackTab()
              else
                const _SignInPrompt(
                  message: 'Sign in to create packs',
                ),
              _PackList(
                packs: savedPacksState.publicPacks,
                isLoading: savedPacksState.isLoading,
                isOwned: false,
                onRefresh: () =>
                    ref.read(savedPacksProvider.notifier).fetchPublicPacks(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 64),
          const SizedBox(height: 16),
          Text(message),
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
}

class _PackList extends ConsumerWidget {
  const _PackList({
    required this.packs,
    required this.isLoading,
    required this.isOwned,
    required this.onRefresh,
  });

  final List<SavedPack> packs;
  final bool isLoading;
  final bool isOwned;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && packs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (packs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isOwned ? 'No saved packs yet' : 'No community packs yet',
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
        itemCount: packs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${packs.length} pack${packs.length == 1 ? '' : 's'}',
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

          final pack = packs[index - 1];
          return _PackCard(pack: pack, isOwned: isOwned);
        },
      ),
    );
  }
}

class _PackCard extends ConsumerWidget {
  const _PackCard({
    required this.pack,
    required this.isOwned,
  });

  final SavedPack pack;
  final bool isOwned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filledSlots = pack.slots.length;

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
                    pack.name.isEmpty ? '(unnamed)' : pack.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    '$filledSlots/32 patches',
                    style: theme.textTheme.bodySmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (pack.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                pack.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(pack.updatedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isOwned) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      pack.isPublic ? Icons.public : Icons.public_off,
                      size: 20,
                    ),
                    tooltip: pack.isPublic ? 'Make private' : 'Make public',
                    onPressed: () {
                      ref.read(savedPacksProvider.notifier).updatePack(
                            pack.id,
                            isPublic: !pack.isPublic,
                          );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete pack',
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete pack?'),
        content: Text(
          'Are you sure you want to delete '
          '"${pack.name.isEmpty ? '(unnamed)' : pack.name}"?',
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
              ref.read(savedPacksProvider.notifier).deletePack(pack.id);
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

class _CreatePackTab extends ConsumerStatefulWidget {
  const _CreatePackTab();

  @override
  ConsumerState<_CreatePackTab> createState() => _CreatePackTabState();
}

class _CreatePackTabState extends ConsumerState<_CreatePackTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;
  final List<({String? patchId, String? sampleId})> _slots =
      List.generate(32, (_) => (patchId: null, sampleId: null));

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedPacksState = ref.watch(savedPacksProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Pack name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Share publicly'),
            value: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value),
          ),
          const SizedBox(height: 16),
          Text(
            'Patch Slots',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 32,
            itemBuilder: (context, index) {
              // Column-major order: 1-8 first column, 9-16 second, etc.
              final row = index ~/ 4;
              final column = index % 4;
              final slotIndex = column * 8 + row;
              return _PackSlotTile(
                slotNumber: slotIndex,
                patchId: _slots[slotIndex].patchId,
                sampleId: _slots[slotIndex].sampleId,
                onPatchChanged: (patchId) {
                  setState(() {
                    _slots[slotIndex] = (
                      patchId: patchId,
                      sampleId: _slots[slotIndex].sampleId,
                    );
                  });
                },
                onSampleChanged: (sampleId) {
                  setState(() {
                    _slots[slotIndex] = (
                      patchId: _slots[slotIndex].patchId,
                      sampleId: sampleId,
                    );
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          _SamplesSection(slots: _slots),
          const SizedBox(height: 16),
          Center(
            child: PlinkyButton(
              onPressed: savedPacksState.isLoading ? null : _savePack,
              icon: Icons.save,
              label: 'Save Pack',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _savePack() {
    final slots = <({int slotNumber, String? patchId, String? sampleId})>[];
    for (var i = 0; i < 32; i++) {
      slots.add((
        slotNumber: i,
        patchId: _slots[i].patchId,
        sampleId: _slots[i].sampleId,
      ));
    }

    ref.read(savedPacksProvider.notifier).savePack(
          _nameController.text,
          description: _descriptionController.text,
          isPublic: _isPublic,
          slots: slots,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pack saved')),
    );

    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _isPublic = false;
      for (var i = 0; i < 32; i++) {
        _slots[i] = (patchId: null, sampleId: null);
      }
    });
  }
}

class _SamplesSection extends ConsumerWidget {
  const _SamplesSection({required this.slots});

  final List<({String? patchId, String? sampleId})> slots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final samples = ref.watch(
      savedSamplesProvider.select((state) => state.userSamples),
    );

    final uniqueSampleIds =
        slots.map((slot) => slot.sampleId).whereType<String>().toSet().toList();
    final hasOverflow = uniqueSampleIds.length > 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Samples',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (hasOverflow)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'A pack can use at most 8 samples. '
              'Currently using ${uniqueSampleIds.length}.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        Row(
          children: List.generate(8, (index) {
            final sampleId =
                index < uniqueSampleIds.length ? uniqueSampleIds[index] : null;
            final sample = sampleId != null
                ? samples
                    .where((sample) => sample.id == sampleId)
                    .firstOrNull
                : null;
            return Expanded(
              child: Card(
                color: sampleId != null
                    ? theme.colorScheme.primaryContainer
                    : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        '${index + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sample?.name ?? '-',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PackSlotTile extends ConsumerWidget {
  const _PackSlotTile({
    required this.slotNumber,
    required this.patchId,
    required this.sampleId,
    required this.onPatchChanged,
    required this.onSampleChanged,
  });

  final int slotNumber;
  final String? patchId;
  final String? sampleId;
  final ValueChanged<String?> onPatchChanged;
  final ValueChanged<String?> onSampleChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final patches = ref.watch(
      savedPatchesProvider.select((state) => state.userPatches),
    );
    final samples = ref.watch(
      savedSamplesProvider.select((state) => state.userSamples),
    );

    final patchName = patchId != null
        ? patches
                .where((patch) => patch.id == patchId)
                .firstOrNull
                ?.name ??
            '(unknown)'
        : 'Empty';
    final sampleName = sampleId != null
        ? samples
                .where((sample) => sample.id == sampleId)
                .firstOrNull
                ?.name ??
            '(unknown)'
        : 'None';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPatchPicker(context, patches),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${slotNumber + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patchName,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sampleName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'patch',
                    child: Text('Pick patch'),
                  ),
                  const PopupMenuItem(
                    value: 'sample',
                    child: Text('Pick sample'),
                  ),
                  if (patchId != null || sampleId != null)
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear slot'),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'patch':
                      _showPatchPicker(context, patches);
                    case 'sample':
                      _showSamplePicker(context, samples);
                    case 'clear':
                      onPatchChanged(null);
                      onSampleChanged(null);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatchPicker(BuildContext context, List<SavedPatch> patches) {
    showDialog<String>(
      context: context,
      builder: (context) => _PatchPickerDialog(patches: patches),
    ).then((selectedId) {
      if (selectedId != null) {
        onPatchChanged(selectedId);
      }
    });
  }

  void _showSamplePicker(BuildContext context, List<SavedSample> samples) {
    showDialog<String>(
      context: context,
      builder: (context) => _SamplePickerDialog(samples: samples),
    ).then((selectedId) {
      if (selectedId != null) {
        onSampleChanged(selectedId);
      }
    });
  }
}

class _PatchPickerDialog extends StatelessWidget {
  const _PatchPickerDialog({required this.patches});

  final List<SavedPatch> patches;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a patch'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: patches.isEmpty
            ? const Center(child: Text('No saved patches'))
            : ListView.builder(
                itemCount: patches.length,
                itemBuilder: (context, index) {
                  final patch = patches[index];
                  return ListTile(
                    title: Text(
                      patch.name.isEmpty ? '(unnamed)' : patch.name,
                    ),
                    subtitle: patch.category.isNotEmpty
                        ? Text(patch.category)
                        : null,
                    onTap: () => Navigator.of(context).pop(patch.id),
                  );
                },
              ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.close,
          label: 'Cancel',
        ),
      ],
    );
  }
}

class _SamplePickerDialog extends StatelessWidget {
  const _SamplePickerDialog({required this.samples});

  final List<SavedSample> samples;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a sample'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: samples.isEmpty
            ? const Center(child: Text('No saved samples'))
            : ListView.builder(
                itemCount: samples.length,
                itemBuilder: (context, index) {
                  final sample = samples[index];
                  return ListTile(
                    title: Text(
                      sample.name.isEmpty ? '(unnamed)' : sample.name,
                    ),
                    subtitle: sample.description.isNotEmpty
                        ? Text(sample.description)
                        : null,
                    onTap: () => Navigator.of(context).pop(sample.id),
                  );
                },
              ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.close,
          label: 'Cancel',
        ),
      ],
    );
  }
}
