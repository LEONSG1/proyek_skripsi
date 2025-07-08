import 'package:flutter/material.dart';

class InventoryItem {
  final String id;
  final String name;
  final String iconName; // ✅ ubah ke string
  int stock;
  final String unit;
  final double price;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.iconName,
    required this.stock,
    required this.unit,
    required this.price,
    required this.category,
  });

  /// 🔁 JSON ke model
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconName: json['iconName'] ?? 'inventory', // default value
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
    );
  }

  /// 🔁 model ke JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName, // ✅ aman disimpan di Firestore
        'stock': stock,
        'unit': unit,
        'price': price,
        'category': category,
      };

  /// 🔁 untuk dipakai di UI
  IconData get icon => _iconFromName(iconName);

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'food':
        return Icons.fastfood;
      case 'drink':
        return Icons.local_drink;
      case 'alat':
        return Icons.kitchen;
      case 'bumbu':
        return Icons.spa;
      case 'inventory':
      default:
        return Icons.inventory;
    }
  }
}
