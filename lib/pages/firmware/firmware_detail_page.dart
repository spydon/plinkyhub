import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/firmware/firmware_card.dart';
import 'package:plinkyhub/pages/firmware/models/saved_firmware.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirmwareDetailPage extends ConsumerStatefulWidget {
  const FirmwareDetailPage({
    required this.firmwareName,
    super.key,
  });

  final String firmwareName;

  @override
  ConsumerState<FirmwareDetailPage> createState() => _FirmwareDetailPageState();
}

class _FirmwareDetailPageState extends ConsumerState<FirmwareDetailPage> {
  SavedFirmware? _firmware;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFirmware();
  }

  Future<void> _fetchFirmware() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('firmwares')
          .select('*, profiles(username)')
          .eq('name', widget.firmwareName)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _firmware = SavedFirmware.fromJson(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Firmware not found';
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

    if (_errorMessage != null || _firmware == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'Firmware not found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isAdmin = _firmware!.userId == currentUserId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              FirmwareCard(
                firmware: _firmware!,
                isAdmin: isAdmin,
                onDeleted: () => context.go(AppRoute.firmware.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
