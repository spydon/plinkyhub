import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/packs/pack_card.dart';
import 'package:plinkyhub/pages/presets/preset_card.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/user_profile_notifier.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwnProfile = profileState.userId == currentUserId;

    if (profileState.userId.isEmpty) {
      return const Center(
        child: Text('Select a user to view their profile'),
      );
    }

    void refreshProfile() {
      ref
          .read(userProfileProvider.notifier)
          .loadUserProfile(
            profileState.userId,
            profileState.username,
          );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.person, size: 24),
              const SizedBox(width: 8),
              Text(
                profileState.username,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (isOwnProfile) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    'You',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Presets (${profileState.presets.length})',
            ),
            Tab(text: 'Packs (${profileState.packs.length})'),
            Tab(
              text: 'Samples (${profileState.samples.length})',
            ),
          ],
        ),
        if (profileState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              profileState.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SearchableItemList(
                items: profileState.presets,
                isLoading: profileState.isLoading,
                isOwned: isOwnProfile,
                onRefresh: refreshProfile,
                itemBuilder: (preset) => PresetCard(
                  preset: preset,
                  isOwned: isOwnProfile,
                ),
                itemLabel: 'preset',
              ),
              SearchableItemList(
                items: profileState.packs,
                isLoading: profileState.isLoading,
                isOwned: false,
                onRefresh: refreshProfile,
                itemBuilder: (pack) => PackCard(
                  pack: pack,
                  isOwned: false,
                ),
                itemLabel: 'pack',
              ),
              SearchableItemList(
                items: profileState.samples,
                isLoading: profileState.isLoading,
                isOwned: false,
                onRefresh: refreshProfile,
                itemBuilder: (sample) => SampleCard(
                  sample: sample,
                  isOwned: false,
                ),
                itemLabel: 'sample',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
