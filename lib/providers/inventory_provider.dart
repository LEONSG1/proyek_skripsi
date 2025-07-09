import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/inventory_item.dart';

class InventoryProvider extends ChangeNotifier {
  final List<InventoryItem> _items = [];
  StreamSubscription? _subscription;
  static const _lowStockThreshold = 3;

  List<InventoryItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.length;
  int get lowStockCount =>
      _items.where((it) => it.stock <= _lowStockThreshold).length;
  double get totalValue =>
      _items.fold(0.0, (sum, it) => sum + it.price * it.stock);

  /// 🔄 Real-time sync from Firestore
  void listenToInventory(String uid) {
    debugPrint('[InventoryProvider] Listening to UID: $uid');

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .orderBy('name') // untuk konsistensi
        .snapshots()
        .listen((snapshot) {
      debugPrint('[InventoryProvider] Snapshot docs: ${snapshot.docs.length}');
      final data = snapshot.docs.map((doc) {
        final d = doc.data();
        return InventoryItem.fromJson(d);
      }).toList();

      _items
        ..clear()
        ..addAll(data);

      notifyListeners();
    });
  }

  /// ➕ Tambah item baru
  Future<void> addItem({
    required String name,
    required int stock,
    required String unit,
    required double price,
    required String category,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .doc();

    final item = InventoryItem(
      id: docRef.id,
      name: name,
      stock: stock,
      unit: unit,
      price: price,
      category: category,
    );

    await docRef.set(item.toJson());
  }

  /// ✏️ Edit item
  Future<void> updateItem(InventoryItem updated) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .doc(updated.id)
        .update(updated.toJson());
  }

  /// ❌ Hapus item
  Future<void> deleteItem(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .doc(id)
        .delete();
  }

  /// 🧹 Bersihkan listener
  void cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// 🧽 Bersihkan data lokal
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
