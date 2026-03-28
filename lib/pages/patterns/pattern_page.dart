import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pattern.dart';
import 'package:plinkyhub/pages/patterns/pattern_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatternPage extends ConsumerStatefulWidget {
  const PatternPage({
    required this.username,
    required this.patternName,
    super.key,
  });

  final String username;
  final String patternName;

  @override
  ConsumerState<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends ConsumerState<PatternPage> {
  SavedPattern? _pattern;
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
    });

    try {
      final response = await Supabase.instance.client
          .from('patterns')
          .select(
            '*, profiles(username), pattern_stars(count)',
          )
          .eq('name', widget.patternName)
          .eq('profiles.username', widget.username)
          .not('profiles', 'is', null)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _pattern = SavedPattern.fromJson(
            response,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Pattern not found';
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _pattern == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'Pattern not found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwned = _pattern!.userId == currentUserId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShareLinkButton(
                    username: widget.username,
                    itemType: 'pattern',
                    itemName: widget.patternName,
                  ),
                ],
              ),
              PatternCard(
                pattern: _pattern!,
                isOwned: isOwned,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
