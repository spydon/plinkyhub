import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/packs/pack_card.dart';
import 'package:plinkyhub/pages/presets/preset_card.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/user_profile_notifier.dart';
import 'package:plinkyhub/state/user_profile_state.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({this.username, super.key});

  final String? username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = this.username;
    if (username != null) {
      final asyncProfile = ref.watch(
        userProfileByUsernameProvider(username),
      );
      return asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (profileState) => UserProfileContent(
          profileState: profileState,
          onRefresh: () => ref.refresh(
            userProfileByUsernameProvider(username).future,
          ),
        ),
      );
    }

    final profileState = ref.watch(userProfileProvider);
    if (profileState.userId.isEmpty) {
      return const Center(
        child: Text('Select a user to view their profile'),
      );
    }

    return UserProfileContent(
      profileState: profileState,
      onRefresh: () => ref
          .read(userProfileProvider.notifier)
          .loadUserProfile(
            profileState.userId,
            profileState.username,
          ),
    );
  }
}

class UserProfileContent extends ConsumerStatefulWidget {
  const UserProfileContent({
    required this.profileState,
    required this.onRefresh,
    super.key,
  });

  final UserProfileState profileState;
  final Future<void> Function() onRefresh;

  @override
  ConsumerState<UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends ConsumerState<UserProfileContent>
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
    final profileState = widget.profileState;
    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwnProfile = profileState.userId == currentUserId;

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
            Tab(
              text: 'Packs (${profileState.packs.length})',
            ),
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
                onRefresh: widget.onRefresh,
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
                onRefresh: widget.onRefresh,
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
                onRefresh: widget.onRefresh,
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
