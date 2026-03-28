import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepLinkTarget {
  const DeepLinkTarget({
    required this.username,
    required this.type,
    required this.name,
  });

  final String username;
  final String type;
  final String name;
}

final deepLinkTargetProvider =
    NotifierProvider<DeepLinkNotifier, DeepLinkTarget?>(
      DeepLinkNotifier.new,
    );

class DeepLinkNotifier extends Notifier<DeepLinkTarget?> {
  @override
  DeepLinkTarget? build() => null;

  set target(DeepLinkTarget? value) => state = value;

  void clear() => state = null;
}
