import 'package:flutter/material.dart';

class CategoryDefaults {
  CategoryDefaults._();

  static const List<Map<String, dynamic>> expenseCategories = [
    {
      'name': 'Food & Dining',
      'icon': 'restaurant',
      'color': '#FF6B6B',
      'type': 'expense',
      'sort_order': 1,
    },
    {
      'name': 'Transport',
      'icon': 'directions_car',
      'color': '#4ECDC4',
      'type': 'expense',
      'sort_order': 2,
    },
    {
      'name': 'Shopping',
      'icon': 'shopping_bag',
      'color': '#A78BFA',
      'type': 'expense',
      'sort_order': 3,
    },
    {
      'name': 'Entertainment',
      'icon': 'movie',
      'color': '#FBBF24',
      'type': 'expense',
      'sort_order': 4,
    },
    {
      'name': 'Bills & Utilities',
      'icon': 'receipt_long',
      'color': '#60A5FA',
      'type': 'expense',
      'sort_order': 5,
    },
    {
      'name': 'Health',
      'icon': 'local_hospital',
      'color': '#34D399',
      'type': 'expense',
      'sort_order': 6,
    },
    {
      'name': 'Education',
      'icon': 'school',
      'color': '#F97316',
      'type': 'expense',
      'sort_order': 7,
    },
    {
      'name': 'Travel',
      'icon': 'flight',
      'color': '#EC4899',
      'type': 'expense',
      'sort_order': 8,
    },
    {
      'name': 'Groceries',
      'icon': 'local_grocery_store',
      'color': '#84CC16',
      'type': 'expense',
      'sort_order': 9,
    },
    {
      'name': 'Subscriptions',
      'icon': 'subscriptions',
      'color': '#8B5CF6',
      'type': 'expense',
      'sort_order': 10,
    },
    {
      'name': 'Rent / Housing',
      'icon': 'home',
      'color': '#06B6D4',
      'type': 'expense',
      'sort_order': 11,
    },
    {
      'name': 'Other',
      'icon': 'category',
      'color': '#94A3B8',
      'type': 'expense',
      'sort_order': 12,
    },
  ];

  static const List<Map<String, dynamic>> incomeCategories = [
    {
      'name': 'Salary',
      'icon': 'work',
      'color': '#10B981',
      'type': 'income',
      'sort_order': 1,
    },
    {
      'name': 'Freelance',
      'icon': 'computer',
      'color': '#3B82F6',
      'type': 'income',
      'sort_order': 2,
    },
    {
      'name': 'Investment',
      'icon': 'trending_up',
      'color': '#8B5CF6',
      'type': 'income',
      'sort_order': 3,
    },
    {
      'name': 'Gift',
      'icon': 'card_giftcard',
      'color': '#EC4899',
      'type': 'income',
      'sort_order': 4,
    },
    {
      'name': 'Other Income',
      'icon': 'attach_money',
      'color': '#94A3B8',
      'type': 'income',
      'sort_order': 5,
    },
  ];

  static Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
