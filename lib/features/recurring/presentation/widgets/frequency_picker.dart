import 'package:flutter/material.dart';

class FrequencyPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const FrequencyPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _frequencies = [
    'daily',
    'weekly',
    'biweekly',
    'monthly',
    'yearly',
  ];

  static String display(String freq) {
    switch (freq) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'biweekly':
        return 'Bi-weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return freq;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _frequencies.map((freq) {
        final isSelected = freq == selected;
        return ChoiceChip(
          label: Text(display(freq)),
          selected: isSelected,
          onSelected: (_) => onSelected(freq),
        );
      }).toList(),
    );
  }
}
