import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class AnimatedBalance extends StatelessWidget {
  final double balance;
  final TextStyle? style;
  final bool showSign;
  final Duration duration;

  const AnimatedBalance({
    super.key,
    required this.balance,
    this.style,
    this.showSign = false,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: balance),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Text(
          CurrencyFormatter.formatAmount(value, showSign: showSign),
          style: style,
        );
      },
    );
  }
}
