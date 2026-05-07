import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String iconName;
  final Color color;
  final double size;

  const CategoryIcon({
    super.key,
    required this.iconName,
    required this.color,
    this.size = 32,
  });

  IconData _getIcon() {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'subscriptions':
        return Icons.subscriptions;
      case 'home':
        return Icons.home;
      case 'category':
        return Icons.category;
      case 'work':
        return Icons.work;
      case 'computer':
        return Icons.computer;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'cash':
        return Icons.money;
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(_getIcon(), color: color, size: size * 0.5),
    );
  }
}
