class TransactionCategory {
  final int? id;
  final String name;
  final String type; // Variable, Fixed, Income, Investment, Subscription
  final int orderIndex;

  TransactionCategory(
      {this.id, required this.name, required this.type, this.orderIndex = 0});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'order_index': orderIndex,
    };
  }

  factory TransactionCategory.fromMap(Map<String, dynamic> map) {
    return TransactionCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ type.hashCode ^ orderIndex.hashCode;
}
