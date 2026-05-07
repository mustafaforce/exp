class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final int? parentId;
  final String type;
  final int sortOrder;
  final String createdAt;

  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.parentId,
    required this.type,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        icon: map['icon'] as String,
        color: map['color'] as String,
        parentId: map['parent_id'] as int?,
        type: map['type'] as String,
        sortOrder: (map['sort_order'] as int?) ?? 0,
        createdAt: map['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'parent_id': parentId,
        'type': type,
        'sort_order': sortOrder,
        'created_at': createdAt,
      };

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    int? parentId,
    String? type,
    int? sortOrder,
    String? createdAt,
  }) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        parentId: parentId ?? this.parentId,
        type: type ?? this.type,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
}
