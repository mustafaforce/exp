class PayeeModel {
  final int? id;
  final String name;
  final int? defaultCategoryId;

  const PayeeModel({
    this.id,
    required this.name,
    this.defaultCategoryId,
  });

  factory PayeeModel.fromMap(Map<String, dynamic> map) => PayeeModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        defaultCategoryId: map['default_category_id'] as int?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'default_category_id': defaultCategoryId,
      };
}
