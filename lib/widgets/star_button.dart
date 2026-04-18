import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';

class StarButton extends ConsumerStatefulWidget {
  const StarButton({
    required this.isStarred,
    required this.starCount,
    required this.onToggle,
    super.key,
  });

  final bool isStarred;
  final int starCount;

  /// Called with the pre-toggle value of [isStarred] so the caller can pass
  /// the correct state to the notifier's `toggleStar`.
  final void Function({required bool wasStarred}) onToggle;

  @override
  ConsumerState<StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends ConsumerState<StarButton>
    with SingleTickerProviderStateMixin {
  late bool _isStarred;
  late int _starCount;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _isStarred = widget.isStarred;
    _starCount = widget.starCount;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.4,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 55,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(covariant StarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStarred != _isStarred) {
      setState(() {
        _isStarred = widget.isStarred;
        _starCount = widget.starCount;
      });
    }
    if (widget.isStarred && !oldWidget.isStarred) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggle() {
    final wasStarred = _isStarred;
    setState(() {
      _isStarred = !wasStarred;
      _starCount += wasStarred ? -1 : 1;
    });
    if (!wasStarred) {
      _pulseController.forward(from: 0);
    }
    widget.onToggle(wasStarred: wasStarred);
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = ref.watch(authenticationProvider).user != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: ScaleTransition(
            scale: _pulseScale,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                _isStarred ? Icons.star : Icons.star_border,
                key: ValueKey<bool>(_isStarred),
                size: 20,
                color: _isStarred ? Colors.amber : null,
              ),
            ),
          ),
          tooltip: _isStarred ? 'Remove star' : 'Star',
          onPressed: () => isSignedIn ? _toggle() : showSignInDialog(context),
        ),
        if (_starCount > 0)
          Text(
            '$_starCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
