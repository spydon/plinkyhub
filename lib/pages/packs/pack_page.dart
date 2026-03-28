import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/pack_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackPage extends ConsumerStatefulWidget {
  const PackPage({
    required this.username,
    required this.packName,
    super.key,
  });

  final String username;
  final String packName;

  @override
  ConsumerState<PackPage> createState() => _PackPageState();
}

class _PackPageState extends ConsumerState<PackPage> {
  SavedPack? _pack;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPack();
  }

  Future<void> _fetchPack() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('packs')
          .select(
            '*, pack_slots(*), profiles(username), '
            'pack_stars(count)',
          )
          .eq('name', widget.packName)
          .eq('profiles.username', widget.username)
          .not('profiles', 'is', null)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _pack = SavedPack.fromJson(
            response,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Pack not found';
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

    if (_errorMessage != null || _pack == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'Pack not found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwned = _pack!.userId == currentUserId;

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
                    itemType: 'pack',
                    itemName: widget.packName,
                  ),
                ],
              ),
              PackCard(
                pack: _pack!,
                isOwned: isOwned,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
