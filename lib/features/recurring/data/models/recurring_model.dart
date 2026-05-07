class RecurringModel {
  final int? id;
  final double amount;
  final String type;
  final int? categoryId;
  final int accountId;
  final int? payeeId;
  final String? note;
  final String frequency;
  final String nextDate;
  final String? endDate;
  final bool isActive;
  final String createdAt;

  const RecurringModel({
    this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.accountId,
    this.payeeId,
    this.note,
    required this.frequency,
    required this.nextDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory RecurringModel.fromMap(Map<String, dynamic> map) => RecurringModel(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        categoryId: map['category_id'] as int?,
        accountId: map['account_id'] as int,
        payeeId: map['payee_id'] as int?,
        note: map['note'] as String?,
        frequency: map['frequency'] as String,
        nextDate: map['next_date'] as String,
        endDate: map['end_date'] as String?,
        isActive: (map['is_active'] as int?) == 1,
        createdAt: map['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'account_id': accountId,
        'payee_id': payeeId,
        'note': note,
        'frequency': frequency,
        'next_date': nextDate,
        'end_date': endDate,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt,
      };
}
