import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final String? lottieAsset;

  const EmptyState({
    super.key,
    required this.icon,
    required this.headline,
    required this.description,
    this.ctaLabel,
    this.onCta,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: 150,
                height: 150,
                repeat: true,
              )
            else
              Icon(icon, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              headline,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onCta,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  textStyle: theme.textTheme.labelLarge,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(ctaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
