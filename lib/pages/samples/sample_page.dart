import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SamplePage extends ConsumerStatefulWidget {
  const SamplePage({
    required this.username,
    required this.sampleName,
    super.key,
  });

  final String username;
  final String sampleName;

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
      final response = await Supabase.instance.client
          .from('samples')
          .select(
            '*, profiles(username), sample_stars(count)',
          )
          .eq('name', widget.sampleName)
          .eq('profiles.username', widget.username)
          .not('profiles', 'is', null)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _sample = SavedSample.fromJson(
            response,
          );
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _sample == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'Sample not found',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShareLinkButton(
                    username: widget.username,
                    itemType: 'sample',
                    itemName: widget.sampleName,
                  ),
                ],
              ),
              SampleCard(
                sample: _sample!,
                isOwned: isOwned,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
