extension StringX on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    return split(' ').map((w) => w.capitalize).join(' ');
  }
}

extension DoubleX on double {
  String get twoDecimals => toStringAsFixed(2);
}
