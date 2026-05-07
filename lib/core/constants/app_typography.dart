import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displayMedium = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displaySmall = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleLarge = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle labelLarge = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelSmall = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static TextStyle currencyAmount(bool isNegative) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      );
}
