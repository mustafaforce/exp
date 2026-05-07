class SplitModel {
  final int? id;
  final int expenseId;
  final int categoryId;
  final double amount;
  final String? note;

  const SplitModel({
    this.id,
    required this.expenseId,
    required this.categoryId,
    required this.amount,
    this.note,
  });

  factory SplitModel.fromMap(Map<String, dynamic> map) => SplitModel(
        id: map['id'] as int?,
        expenseId: map['expense_id'] as int,
        categoryId: map['category_id'] as int,
        amount: (map['amount'] as num).toDouble(),
        note: map['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'expense_id': expenseId,
        'category_id': categoryId,
        'amount': amount,
        'note': note,
      };
}
