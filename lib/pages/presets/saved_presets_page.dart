import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/presets/preset_list.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_presets_notifier.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

class SavedPresetsPage extends ConsumerStatefulWidget {
  const SavedPresetsPage({super.key});

  @override
  ConsumerState<SavedPresetsPage> createState() =>
      _SavedPresetsPageState();
}

class _SavedPresetsPageState extends ConsumerState<SavedPresetsPage>
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
      ref.read(savedPresetsProvider.notifier).fetchPublicPresets();
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
    final savedPresetsState = ref.watch(savedPresetsProvider);
    final isSignedIn = authenticationState.user != null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Presets'),
            Tab(text: 'Community Presets'),
          ],
        ),
        if (savedPresetsState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              savedPresetsState.errorMessage!,
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
                PresetList(
                  presets: savedPresetsState.userPresets,
                  isLoading: savedPresetsState.isLoading,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedPresetsProvider.notifier)
                      .fetchUserPresets(),
                )
              else
                const SignInPrompt(
                  message:
                      'Sign in to save and manage your presets',
                ),
              PresetList(
                presets: savedPresetsState.publicPresets,
                isLoading: savedPresetsState.isLoading,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedPresetsProvider.notifier)
                    .fetchPublicPresets(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
