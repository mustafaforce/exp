class ExpenseModel {
  final int? id;
  final double amount;
  final String type;
  final int? categoryId;
  final int accountId;
  final int? toAccountId;
  final int? payeeId;
  final String? note;
  final String date;
  final int? recurringId;
  final String createdAt;
  final String updatedAt;

  const ExpenseModel({
    this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.accountId,
    this.toAccountId,
    this.payeeId,
    this.note,
    required this.date,
    this.recurringId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        categoryId: map['category_id'] as int?,
        accountId: map['account_id'] as int,
        toAccountId: map['to_account_id'] as int?,
        payeeId: map['payee_id'] as int?,
        note: map['note'] as String?,
        date: map['date'] as String,
        recurringId: map['recurring_id'] as int?,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'account_id': accountId,
        'to_account_id': toAccountId,
        'payee_id': payeeId,
        'note': note,
        'date': date,
        'recurring_id': recurringId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  ExpenseModel copyWith({
    int? id,
    double? amount,
    String? type,
    int? categoryId,
    int? accountId,
    int? toAccountId,
    int? payeeId,
    String? note,
    String? date,
    int? recurringId,
    String? createdAt,
    String? updatedAt,
  }) =>
      ExpenseModel(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        accountId: accountId ?? this.accountId,
        toAccountId: toAccountId ?? this.toAccountId,
        payeeId: payeeId ?? this.payeeId,
        note: note ?? this.note,
        date: date ?? this.date,
        recurringId: recurringId ?? this.recurringId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
  bool get isTransfer => type == 'transfer';
}
