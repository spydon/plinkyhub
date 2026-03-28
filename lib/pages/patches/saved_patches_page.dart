import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/patches/patch_list.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

class SavedPatchesPage extends ConsumerStatefulWidget {
  const SavedPatchesPage({super.key});

  @override
  ConsumerState<SavedPatchesPage> createState() =>
      _SavedPatchesPageState();
}

class _SavedPatchesPageState extends ConsumerState<SavedPatchesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedPatchesProvider.notifier).fetchPublicPatches();
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
    final isSignedIn = authenticationState.user != null;

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
              if (isSignedIn)
                PatchList(
                  patches: savedPatchesState.userPatches,
                  isLoading: savedPatchesState.isLoading,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedPatchesProvider.notifier)
                      .fetchUserPatches(),
                )
              else
                const SignInPrompt(
                  message:
                      'Sign in to save and manage your patches',
                ),
              PatchList(
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
