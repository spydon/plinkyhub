// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_card.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WavetablePage extends ConsumerStatefulWidget {
  const WavetablePage({
    required this.username,
    required this.wavetableSlug,
    super.key,
  });

  final String username;
  final String wavetableSlug;

  @override
  ConsumerState<WavetablePage> createState() => _WavetablePageState();
}

class _WavetablePageState extends ConsumerState<WavetablePage> {
  SavedWavetable? _wavetable;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWavetable();
  }

  Future<void> _fetchWavetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final row = await Supabase.instance.client
          .table(Wavetables.table)
          .selectOnly(SavedWavetable.selection)
          .where(
            Wavetables.slug.eq(widget.wavetableSlug) &
                wavetablesTable.ownedByUsername(widget.username),
          )
          .order(Wavetables.updatedAt.desc())
          .limit(1)
          .maybeSingle();

      if (row != null) {
        final isStarred = await wavetableStarsTable.isStarred(
          Supabase.instance.client,
          id: row.read(Wavetables.id),
          userId: ref.read(authenticationProvider).user?.id,
        );
        setState(() {
          _wavetable = SavedWavetable.fromRow(row, isStarred: isStarred);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Wavetable not found';
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

    if (_errorMessage != null || _wavetable == null) {
      return Center(
        child: CopyableErrorMessage(
          message: _errorMessage ?? 'Wavetable not found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwned = _wavetable!.userId == currentUserId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              WavetableCard(
                wavetable: _wavetable!,
                isOwned: isOwned,
                showExportButton: true,
                onDeleted: () => context.go(AppRoute.wavetables.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
