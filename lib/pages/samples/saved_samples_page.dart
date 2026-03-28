import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/samples/sample_list.dart';
import 'package:plinkyhub/pages/samples/upload_sample_tab.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class SavedSamplesPage extends ConsumerStatefulWidget {
  const SavedSamplesPage({super.key});

  @override
  ConsumerState<SavedSamplesPage> createState() =>
      _SavedSamplesPageState();
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
    final savedSamplesState = ref.watch(savedSamplesProvider);
    final isSignedIn = authenticationState.user != null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Samples'),
            Tab(text: 'Community Samples'),
            Tab(text: 'Upload'),
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
                SampleList(
                  samples: savedSamplesState.userSamples,
                  isLoading: savedSamplesState.isLoading,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedSamplesProvider.notifier)
                      .fetchUserSamples(),
                )
              else
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Sign in to upload and manage your '
                        'samples',
                      ),
                      const SizedBox(height: 16),
                      PlinkyButton(
                        onPressed: () =>
                            showSignInDialog(context),
                        icon: Icons.login,
                        label: 'Sign in',
                      ),
                    ],
                  ),
                ),
              SampleList(
                samples: savedSamplesState.publicSamples,
                isLoading: savedSamplesState.isLoading,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedSamplesProvider.notifier)
                    .fetchPublicSamples(),
              ),
              if (isSignedIn)
                UploadSampleTab(
                  onUploaded: () =>
                      _tabController.animateTo(0),
                )
              else
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Sign in to upload samples',
                      ),
                      const SizedBox(height: 16),
                      PlinkyButton(
                        onPressed: () =>
                            showSignInDialog(context),
                        icon: Icons.login,
                        label: 'Sign in',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
