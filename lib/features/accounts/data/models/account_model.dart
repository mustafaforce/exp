class AccountModel {
  final int? id;
  final String name;
  final String type;
  final double balance;
  final String? icon;
  final String? color;
  final String? currency;
  final bool isActive;
  final String createdAt;

  const AccountModel({
    this.id,
    required this.name,
    required this.type,
    this.balance = 0,
    this.icon,
    this.color,
    this.currency,
    this.isActive = true,
    required this.createdAt,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: map['type'] as String,
        balance: (map['balance'] as num?)?.toDouble() ?? 0,
        icon: map['icon'] as String?,
        color: map['color'] as String?,
        currency: map['currency'] as String?,
        isActive: (map['is_active'] as int?) == 1,
        createdAt: map['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'balance': balance,
        'icon': icon,
        'color': color,
        'currency': currency,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt,
      };

  AccountModel copyWith({
    int? id,
    String? name,
    String? type,
    double? balance,
    String? icon,
    String? color,
    String? currency,
    bool? isActive,
    String? createdAt,
  }) =>
      AccountModel(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        balance: balance ?? this.balance,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        currency: currency ?? this.currency,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
}
