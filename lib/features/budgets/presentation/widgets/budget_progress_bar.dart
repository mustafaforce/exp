import 'package:flutter/material.dart';

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(percentage);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: percentage.clamp(0, 100) / 100),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        );
      },
    );
  }

  Color _getColor(double pct) {
    if (pct >= 90) return const Color(0xFFEF4444);
    if (pct >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }
}
