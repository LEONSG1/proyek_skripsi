// lib/data/models/inventory_item.dart
import 'package:flutter/material.dart';

class InventoryItem {
  final String id;
  final String name;
  final IconData icon;
  int stock;
  final String unit;
  final double price;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.stock,
    required this.unit,
    required this.price,
    required this.category,
  });
}
