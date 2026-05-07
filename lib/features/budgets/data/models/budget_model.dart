class BudgetModel {
  final int? id;
  final int? categoryId;
  final double amount;
  final String period;
  final String startDate;
  final String createdAt;

  const BudgetModel({
    this.id,
    this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.createdAt,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
        id: map['id'] as int?,
        categoryId: map['category_id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        period: map['period'] as String,
        startDate: map['start_date'] as String,
        createdAt: map['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'category_id': categoryId,
        'amount': amount,
        'period': period,
        'start_date': startDate,
        'created_at': createdAt,
      };

  BudgetModel copyWith({
    int? id,
    int? categoryId,
    double? amount,
    String? period,
    String? startDate,
    String? createdAt,
  }) =>
      BudgetModel(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        createdAt: createdAt ?? this.createdAt,
      );
}
