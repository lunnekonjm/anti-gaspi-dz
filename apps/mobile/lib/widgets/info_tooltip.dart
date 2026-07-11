import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small ⓘ icon that, when tapped, shows a bottom sheet with a plain-language
/// explanation. Use next to form labels or badges that need context
/// (e.g. "DLC vs DDM", "Why is my phone number hidden?").
///
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Text('Type de péremption'),
///     InfoTooltip(
///       title: 'DLC vs DDM',
///       body: 'La DLC (Date Limite de Consommation) concerne les produits '
///             'périssables — à ne pas consommer après. La DDM (Date de '
///             'Durabilité Minimale) est indicative, le produit reste bon '
///             'au-delà avec un léger changement de qualité.',
///     ),
///   ],
/// )
/// ```
class InfoTooltip extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const InfoTooltip({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _show(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: AppTheme.infoFg(context)),
      ),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(icon, color: AppTheme.infoFg(ctx)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: Theme.of(ctx)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(body, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

/// A dismissible inline banner for onboarding-style explanations
/// ("Comment ça marche ?"). Lighter-weight than a full bottom sheet,
/// meant to sit at the top of a page and disappear once understood.
class ExplainerBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final VoidCallback? onDismiss;

  const ExplainerBanner({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.infoBg(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.infoBorder(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppTheme.infoFg(context))),
                const SizedBox(height: 4),
                Text(body,
                    style: TextStyle(fontSize: 13, color: AppTheme.infoFg(context))),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: AppTheme.infoFg(context)),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
