// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/pages/patterns/models/pattern_data.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/pages/patterns/pattern_card.dart';
import 'package:plinkyhub/pages/patterns/pattern_playback_panel.dart';
import 'package:plinkyhub/pages/patterns/providers/saved_patterns_notifier.dart';
import 'package:plinkyhub/pages/patterns/utils/pattern_decoder.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatternPage extends ConsumerStatefulWidget {
  const PatternPage({
    required this.username,
    required this.patternSlug,
    super.key,
  });

  final String username;
  final String patternSlug;

  @override
  ConsumerState<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends ConsumerState<PatternPage> {
  SavedPattern? _pattern;
  PatternData? _patternData;
  String? _patternDataError;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPattern();
  }

  Future<void> _fetchPattern() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _patternDataError = null;
    });

    try {
      final row = await Supabase.instance.client
          .table(Patterns.table)
          .selectOnly(SavedPattern.selection)
          .where(
            Patterns.slug.eq(widget.patternSlug) &
                patternsTable.ownedByUsername(widget.username),
          )
          .order(Patterns.updatedAt.desc())
          .limit(1)
          .maybeSingle();

      if (row == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Pattern not found';
        });
        return;
      }

      final isStarred = await patternStarsTable.isStarred(
        Supabase.instance.client,
        id: row.read(Patterns.id),
        userId: ref.read(authenticationProvider).user?.id,
      );
      final pattern = SavedPattern(row, isStarred: isStarred);
      if (!mounted) {
        return;
      }
      setState(() {
        _pattern = pattern;
        _isLoading = false;
      });

      await _loadPatternData(pattern);
    } on Object catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _loadPatternData(SavedPattern pattern) async {
    try {
      final bytes = await ref
          .read(savedPatternsProvider.notifier)
          .downloadFile(pattern.filePath);
      final data = decodePatternFile(bytes);
      if (!mounted) {
        return;
      }
      setState(() {
        _patternData = data;
        _patternDataError = data == null
            ? 'Unsupported pattern file format'
            : null;
      });
    } on Object catch (error) {
      debugPrint('Failed to load pattern data: $error');
      if (!mounted) {
        return;
      }
      setState(() => _patternDataError = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: PlinkyLoadingAnimation());
    }

    if (_errorMessage != null || _pattern == null) {
      return Center(
        child: CopyableErrorMessage(
          message: _errorMessage ?? 'Pattern not found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwned = _pattern!.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox.expand(
        child: PatternPlaybackPanel(
          pattern: _pattern!,
          patternData: _patternData,
          loadError: _patternDataError,
          header: PatternHeader(
            pattern: _pattern!,
            isOwned: isOwned,
            onDeleted: () => context.go(AppRoute.patterns.path),
          ),
        ),
      ),
    );
  }
}
