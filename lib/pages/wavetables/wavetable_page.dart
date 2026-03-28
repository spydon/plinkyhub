import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WavetablePage extends ConsumerStatefulWidget {
  const WavetablePage({
    required this.username,
    required this.wavetableName,
    super.key,
  });

  final String username;
  final String wavetableName;

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
      final response = await Supabase.instance.client
          .from('wavetables')
          .select(
            '*, profiles(username), wavetable_stars(count)',
          )
          .eq('name', widget.wavetableName)
          .eq('profiles.username', widget.username)
          .not('profiles', 'is', null)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _wavetable = SavedWavetable.fromJson(
            response,
          );
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _wavetable == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'Wavetable not found',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShareLinkButton(
                    username: widget.username,
                    itemType: 'wavetable',
                    itemName: widget.wavetableName,
                  ),
                ],
              ),
              WavetableCard(
                wavetable: _wavetable!,
                isOwned: isOwned,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
