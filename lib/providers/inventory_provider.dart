// lib/providers/inventory_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/inventory_item.dart';

class InventoryProvider extends ChangeNotifier {
  final _items = <InventoryItem>[];
  static const _lowStockThreshold = 3;

  List<InventoryItem> get items => List.unmodifiable(_items);

  /// total item types
  int get totalCount => _items.length;

  /// jumlah yang stock ≤ threshold
  int get lowStockCount =>
      _items.where((it) => it.stock <= _lowStockThreshold).length;

  /// total harga semua stok
  double get totalValue =>
      _items.fold(0.0, (sum, it) => sum + it.price * it.stock);

  /// Tambah item baru
  void addItem({
    required String name,
    required IconData icon,
    required int stock,
    required String unit,
    required double price,
    required String category,
  }) {
    final newItem = InventoryItem(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      stock: stock,
      unit: unit,
      price: price,
      category: category,
    );
    _items.add(newItem);
    notifyListeners();
  }

  /// Update item yang sudah ada berdasarkan `id`
  void updateItem({
    required String id,
    String? name,
    IconData? icon,
    int? stock,
    String? unit,
    double? price,
    String? category,
  }) {
    final index = _items.indexWhere((it) => it.id == id);
    if (index == -1) return;
    final old = _items[index];
    _items[index] = InventoryItem(
      id: old.id,
      name: name ?? old.name,
      icon: icon ?? old.icon,
      stock: stock ?? old.stock,
      unit: unit ?? old.unit,
      price: price ?? old.price,
      category: category ?? old.category,
    );
    notifyListeners();
  }

  /// Hapus item berdasarkan `id`
  void removeItem(String id) {
    _items.removeWhere((it) => it.id == id);
    notifyListeners();
  }
}
