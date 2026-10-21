// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SamplePage extends ConsumerStatefulWidget {
  const SamplePage({
    required this.username,
    required this.sampleSlug,
    super.key,
  });

  final String username;
  final String sampleSlug;

  @override
  ConsumerState<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends ConsumerState<SamplePage> {
  SavedSample? _sample;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSample();
  }

  Future<void> _fetchSample() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final row = await Supabase.instance.client
          .table(Samples.table)
          .selectOnly(SavedSample.selection)
          .where(
            Samples.slug.eq(widget.sampleSlug) &
                samplesTable.ownedByUsername(widget.username),
          )
          .order(Samples.updatedAt.desc())
          .limit(1)
          .maybeSingle();

      if (row != null) {
        final isStarred = await sampleStarsTable.isStarred(
          Supabase.instance.client,
          id: row.read(Samples.id),
          userId: ref.read(authenticationProvider).user?.id,
        );
        setState(() {
          _sample = SavedSample.fromRow(row, isStarred: isStarred);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sample not found';
        });
      }
    } on Exception catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: PlinkyLoadingAnimation());
    }

    if (_errorMessage != null || _sample == null) {
      return Center(
        child: CopyableErrorMessage(
          message: _errorMessage ?? 'Sample not found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwned = _sample!.userId == currentUserId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SampleCard(
                sample: _sample!,
                isOwned: isOwned,
                initiallyExpanded: true,
                onDeleted: () => context.go(AppRoute.samples.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
