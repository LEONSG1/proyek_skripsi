import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/inventory_item.dart';

class InventoryProvider extends ChangeNotifier {
  final List<InventoryItem> _items = [];
  static const _lowStockThreshold = 3;

  List<InventoryItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.length;

  int get lowStockCount =>
      _items.where((it) => it.stock <= _lowStockThreshold).length;

  double get totalValue =>
      _items.fold(0.0, (sum, it) => sum + it.price * it.stock);

  /// 🔁 Load from Firebase
  Future<void> loadItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .get();

    _items.clear();
    _items.addAll(snapshot.docs
        .map((doc) => InventoryItem.fromJson(doc.data()))
        .toList());

    notifyListeners();
  }

  /// ➕ Add item to Firebase
  Future<void> addItem({
    required String name,
    required String iconName, // ✅ pakai string
    required int stock,
    required String unit,
    required double price,
    required String category,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(); // auto ID

    final newItem = InventoryItem(
      id: docRef.id,
      name: name,
      iconName: iconName, // ✅ string yang akan dikonversi ke icon di UI
      stock: stock,
      unit: unit,
      price: price,
      category: category,
    );

    await docRef.set(newItem.toJson());

    _items.add(newItem);
    notifyListeners();
  }

  /// 🔄 Update item in Firebase
  Future<void> updateItem({
    required String id,
    String? name,
    int? stock,
    String? unit,
    double? price,
    String? category,
  }) async {
    final index = _items.indexWhere((it) => it.id == id);
    if (index == -1) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final old = _items[index];
    final updated = InventoryItem(
      id: old.id,
      name: name ?? old.name,
      iconName: old.iconName,
      stock: stock ?? old.stock,
      unit: unit ?? old.unit,
      price: price ?? old.price,
      category: category ?? old.category,
    );

    _items[index] = updated;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(id)
        .set(updated.toJson());

    notifyListeners();
  }

  /// ❌ Hapus item
  Future<void> removeItem(String id) async {
    _items.removeWhere((it) => it.id == id);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(id)
        .delete();
  }

  /// 🔃 Reset saat logout
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
