import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/packs/create_pack_tab.dart';
import 'package:plinkyhub/pages/packs/pack_list.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

class SavedPacksPage extends ConsumerStatefulWidget {
  const SavedPacksPage({super.key});

  @override
  ConsumerState<SavedPacksPage> createState() =>
      _SavedPacksPageState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedPacksProvider.notifier).fetchPublicPacks();
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
                PackList(
                  packs: savedPacksState.userPacks,
                  isLoading: savedPacksState.isLoading,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedPacksProvider.notifier)
                      .fetchUserPacks(),
                )
              else
                const SignInPrompt(
                  message:
                      'Sign in to save and manage your packs',
                ),
              if (isSignedIn)
                const CreatePackTab()
              else
                const SignInPrompt(
                  message: 'Sign in to create packs',
                ),
              PackList(
                packs: savedPacksState.publicPacks,
                isLoading: savedPacksState.isLoading,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedPacksProvider.notifier)
                    .fetchPublicPacks(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
