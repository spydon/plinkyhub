import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/pages/samples/upload_sample_tab.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/deep_link_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

class SavedSamplesPage extends ConsumerStatefulWidget {
  const SavedSamplesPage({super.key});

  @override
  ConsumerState<SavedSamplesPage> createState() => _SavedSamplesPageState();
}

class _SavedSamplesPageState extends ConsumerState<SavedSamplesPage>
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
      ref.read(savedSamplesProvider.notifier).fetchPublicSamples();
      _handleDeepLink();
    });
  }

  void _handleDeepLink() {
    final target = ref.read(deepLinkTargetProvider);
    if (target != null && target.type == 'sample') {
      _tabController.animateTo(1);
      ref.read(deepLinkTargetProvider.notifier).clear();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationState = ref.watch(authenticationProvider);
    final savedSamplesState = ref.watch(savedSamplesProvider);
    final isSignedIn = authenticationState.user != null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Samples'),
            Tab(text: 'Community Samples'),
            Tab(text: 'Create Sample'),
          ],
        ),
        if (savedSamplesState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              savedSamplesState.errorMessage!,
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
                  items: savedSamplesState.userSamples,
                  starredItems: savedSamplesState.starredSamples,
                  isLoading: savedSamplesState.isLoading,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedSamplesProvider.notifier)
                      .fetchUserSamples(),
                  itemBuilder: (sample) => SampleCard(
                    sample: sample,
                    isOwned: sample.userId == authenticationState.user?.id,
                  ),
                  itemLabel: 'sample',
                )
              else
                const SignInPrompt(
                  message: 'Sign in to upload and manage your samples',
                ),
              SearchableItemList(
                items: savedSamplesState.publicSamples,
                isLoading: savedSamplesState.isLoading,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedSamplesProvider.notifier)
                    .fetchPublicSamples(),
                itemBuilder: (sample) => SampleCard(
                  sample: sample,
                  isOwned: false,
                ),
                itemLabel: 'sample',
              ),
              if (isSignedIn)
                UploadSampleTab(
                  onUploaded: () => _tabController.animateTo(0),
                )
              else
                const SignInPrompt(
                  message: 'Sign in to create samples',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
