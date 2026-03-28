import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/wavetables/upload_wavetable_tab.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

class SavedWavetablesPage extends ConsumerStatefulWidget {
  const SavedWavetablesPage({super.key});

  @override
  ConsumerState<SavedWavetablesPage> createState() =>
      _SavedWavetablesPageState();
}

class _SavedWavetablesPageState extends ConsumerState<SavedWavetablesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedWavetablesProvider.notifier).fetchPublicWavetables();
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
    final savedWavetablesState = ref.watch(savedWavetablesProvider);
    final isSignedIn = authenticationState.user != null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Wavetables'),
            Tab(text: 'Community Wavetables'),
            Tab(text: 'Create Wavetable'),
          ],
        ),
        if (savedWavetablesState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              savedWavetablesState.errorMessage!,
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
                SearchableItemList(
                  items: savedWavetablesState.userWavetables,
                  starredItems: savedWavetablesState.starredWavetables,
                  isLoading: savedWavetablesState.isLoading,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedWavetablesProvider.notifier)
                      .fetchUserWavetables(),
                  itemBuilder: (wavetable) => WavetableCard(
                    wavetable: wavetable,
                    isOwned: wavetable.userId == authenticationState.user?.id,
                  ),
                  itemLabel: 'wavetable',
                )
              else
                const SignInPrompt(
                  message: 'Sign in to upload and manage your wavetables',
                ),
              SearchableItemList(
                items: savedWavetablesState.publicWavetables,
                isLoading: savedWavetablesState.isLoading,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedWavetablesProvider.notifier)
                    .fetchPublicWavetables(),
                itemBuilder: (wavetable) => WavetableCard(
                  wavetable: wavetable,
                  isOwned: false,
                ),
                itemLabel: 'wavetable',
              ),
              if (isSignedIn)
                UploadWavetableTab(
                  onUploaded: () => _tabController.animateTo(0),
                )
              else
                const SignInPrompt(
                  message: 'Sign in to create wavetables',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
