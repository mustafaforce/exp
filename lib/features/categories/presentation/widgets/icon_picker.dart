import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onSelected;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onSelected,
  });

  static const _icons = [
    'restaurant',
    'local_grocery_store',
    'directions_car',
    'shopping_bag',
    'movie',
    'receipt_long',
    'local_hospital',
    'school',
    'flight',
    'subscriptions',
    'home',
    'work',
    'computer',
    'trending_up',
    'card_giftcard',
    'attach_money',
    'category',
    'favorite',
    'pets',
    'checkroom',
    'cleaning_services',
    'electric_bolt',
    'local_laundry_service',
    'lunch_dining',
    'pedal_bike',
    'phone_iphone',
    'savings',
    'self_improvement',
    'sports_esports',
    'water_drop',
    'wifi',
    'account_balance',
  ];

  IconData _getIcon(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_grocery_store':
        return Icons.local_grocery_store;
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
      case 'subscriptions':
        return Icons.subscriptions;
      case 'home':
        return Icons.home;
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
      case 'category':
        return Icons.category;
      case 'favorite':
        return Icons.favorite;
      case 'pets':
        return Icons.pets;
      case 'checkroom':
        return Icons.checkroom;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'savings':
        return Icons.savings;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'water_drop':
        return Icons.water_drop;
      case 'wifi':
        return Icons.wifi;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _icons.length,
      itemBuilder: (context, index) {
        final iconName = _icons[index];
        final isSelected = iconName == selectedIcon;
        return GestureDetector(
          onTap: () => onSelected(iconName),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              _getIcon(iconName),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
