import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/packs/pack_slot_tile.dart';
import 'package:plinkyhub/pages/packs/samples_section.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class CreatePackTab extends ConsumerStatefulWidget {
  const CreatePackTab({super.key});

  @override
  ConsumerState<CreatePackTab> createState() => _CreatePackTabState();
}

class _CreatePackTabState extends ConsumerState<CreatePackTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;
  final List<({String? patchId, String? sampleId})> _slots =
      List.generate(
    32,
    (_) => (patchId: null, sampleId: null),
  );

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
            onChanged: (value) =>
                setState(() => _isPublic = value),
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
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 32,
            itemBuilder: (context, index) {
              // Column-major order: 1-8 first column, 9-16 second,
              // etc.
              final row = index ~/ 4;
              final column = index % 4;
              final slotIndex = column * 8 + row;
              return PackSlotTile(
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
          SamplesSection(slots: _slots),
          const SizedBox(height: 16),
          Center(
            child: PlinkyButton(
              onPressed:
                  savedPacksState.isLoading ? null : _savePack,
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
    final slots =
        <({int slotNumber, String? patchId, String? sampleId})>[];
    for (var i = 0; i < 32; i++) {
      slots.add((
        slotNumber: i,
        patchId: _slots[i].patchId,
        sampleId: _slots[i].sampleId,
      ));
    }

    ref
        .read(savedPacksProvider.notifier)
        .savePack(
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
