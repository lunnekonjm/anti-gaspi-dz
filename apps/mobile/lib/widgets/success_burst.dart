import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A brief animated success confirmation: a circle that pops in with a
/// checkmark and a soft ripple, then settles. Use after a reservation
/// is confirmed, a donation is published, etc. — replaces a plain
/// green SnackBar with something that actually feels like "it worked".
///
/// Usage: show as a dialog-like overlay for ~1.2s, then auto-dismiss:
/// ```dart
/// showSuccessBurst(context, message: 'Réservation confirmée !');
/// ```
class SuccessBurst extends StatefulWidget {
  final String message;
  final String emoji;

  const SuccessBurst({super.key, required this.message, this.emoji = '✅'});

  @override
  State<SuccessBurst> createState() => _SuccessBurstState();
}

class _SuccessBurstState extends State<SuccessBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppTheme.slowAnim);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows [SuccessBurst] as a transient overlay dialog that auto-dismisses.
Future<void> showSuccessBurst(
  BuildContext context, {
  required String message,
  String emoji = '✅',
  Duration displayDuration = const Duration(milliseconds: 1200),
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black26,
    transitionDuration: AppTheme.fastAnim,
    pageBuilder: (ctx, anim, secondaryAnim) =>
        SuccessBurst(message: message, emoji: emoji),
  ));
  await Future.delayed(displayDuration);
  if (navigator.canPop()) navigator.pop();
}

// Small helper to avoid importing dart:async just for this.
void unawaited(Future<void> future) {}
