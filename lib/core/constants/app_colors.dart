import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light mode
  static const primary = Color(0xFF0F3D66);
  static const primaryLight = Color(0xFF1A5C99);
  static const primaryDark = Color(0xFF092A47);
  static const secondary = Color(0xFFF8B319);
  static const secondaryLight = Color(0xFFFCD46A);
  static const accent = Color(0xFFFF6B35);
  static const background = Color(0xFFF5F0EB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0ECE6);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textDisabled = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);

  // Dark mode
  static const darkBackground = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceVariant = Color(0xFF252525);
  static const darkSurfaceElevated = Color(0xFF2C2C2C);
  static const darkPrimary = Color(0xFF60A5FA);
  static const darkPrimaryContainer = Color(0xFF1E3A5F);
  static const darkSecondary = Color(0xFFFBBF24);
  static const darkSuccess = Color(0xFF34D399);
  static const darkError = Color(0xFFF87171);
  static const darkTextPrimary = Color(0xFFE5E5E5);
  static const darkTextSecondary = Color(0xFFA3A3A3);
  static const darkDivider = Color(0xFF2A2A2A);

  // Category colors (same for both modes)
  static const categoryFood = Color(0xFFFF6B6B);
  static const categoryTransport = Color(0xFF4ECDC4);
  static const categoryShopping = Color(0xFFA78BFA);
  static const categoryEntertainment = Color(0xFFFBBF24);
  static const categoryBills = Color(0xFF60A5FA);
  static const categoryHealth = Color(0xFF34D399);
  static const categoryEducation = Color(0xFFF97316);
  static const categoryTravel = Color(0xFFEC4899);
  static const categoryGroceries = Color(0xFF84CC16);
  static const categorySubscriptions = Color(0xFF8B5CF6);
  static const categoryRent = Color(0xFF06B6D4);
  static const categoryOther = Color(0xFF94A3B8);

  static const Map<String, Color> categoryColors = {
    'Food & Dining': categoryFood,
    'Transport': categoryTransport,
    'Shopping': categoryShopping,
    'Entertainment': categoryEntertainment,
    'Bills & Utilities': categoryBills,
    'Health': categoryHealth,
    'Education': categoryEducation,
    'Travel': categoryTravel,
    'Groceries': categoryGroceries,
    'Subscriptions': categorySubscriptions,
    'Rent / Housing': categoryRent,
    'Other': categoryOther,
  };
}
