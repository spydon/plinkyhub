import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/pages/presets/preset_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresetPage extends ConsumerStatefulWidget {
  const PresetPage({
    required this.username,
    required this.presetName,
    super.key,
  });

  final String username;
  final String presetName;

  @override
  ConsumerState<PresetPage> createState() => _PresetPageState();
}

class _PresetPageState extends ConsumerState<PresetPage> {
  SavedPreset? _preset;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPreset();
  }

  Future<void> _fetchPreset() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('presets')
          .select(
            '*, profiles(username), preset_stars(count)',
          )
          .eq('name', widget.presetName)
          .eq('profiles.username', widget.username)
          .not('profiles', 'is', null)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _preset = SavedPreset.fromJson(
            response,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Preset not found';
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

    if (_errorMessage != null || _preset == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'Preset not found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isOwned = _preset!.userId == currentUserId;

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
                    itemType: 'preset',
                    itemName: widget.presetName,
                  ),
                ],
              ),
              PresetCard(
                preset: _preset!,
                isOwned: isOwned,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
