class InventoryItem {
  final String id;
  final String name;
  final int stock;
  final String unit;
  final double price;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
    required this.price,
    required this.category,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stock': stock,
        'unit': unit,
        'price': price,
        'category': category,
      };

  InventoryItem copyWith({
    String? id,
    String? name,
    int? stock,
    String? unit,
    double? price,
    String? category,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }
}
