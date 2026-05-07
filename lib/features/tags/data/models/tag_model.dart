class TagModel {
  final int? id;
  final String name;
  final String? color;

  const TagModel({
    this.id,
    required this.name,
    this.color,
  });

  factory TagModel.fromMap(Map<String, dynamic> map) => TagModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        color: map['color'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color': color,
      };
}
