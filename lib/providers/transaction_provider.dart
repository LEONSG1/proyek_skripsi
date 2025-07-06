import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  StreamSubscription? _subscription; // 👈 Tambahan: untuk real-time listener

  List<TransactionModel> get transactions => _transactions;

  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(String uid, TransactionModel updated) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(updated.id)
        .update(updated.toJson());

    final index = _transactions.indexWhere((tx) => tx.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String uid, String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(docId)
        .delete();

    _transactions.removeWhere((tx) => tx.id == docId);
    notifyListeners();
  }

  /// 🟡 Tidak wajib lagi dipakai jika sudah pakai listenToTransactions()
  Future<void> fetchFromFirebase(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    final data = snapshot.docs.map((doc) {
      final d = doc.data();
      return TransactionModel(
        id: doc.id,
        amount: (d['amount'] as num).toDouble(),
        type: d['type'] as String,
        description: d['description'] ?? '',
        category: d['category'] ?? '',
        date: d['date'] is Timestamp
            ? (d['date'] as Timestamp).toDate()
            : DateTime.parse(d['date']),
      );
    }).toList();

    _transactions
      ..clear()
      ..addAll(data);

    notifyListeners();
  }

  /// ✅ Listener real-time untuk sinkronisasi otomatis (online/offline)
  void listenToTransactions(String uid) {
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        final d = doc.data();
        return TransactionModel(
          id: doc.id,
          amount: (d['amount'] as num).toDouble(),
          type: d['type'] as String,
          description: d['description'] ?? '',
          category: d['category'] ?? '',
          date: d['date'] is Timestamp
              ? (d['date'] as Timestamp).toDate()
              : DateTime.parse(d['date']),
        );
      }).toList();

      _transactions
        ..clear()
        ..addAll(data);

      notifyListeners();
    });
  }

  /// ✅ Hentikan subscription saat logout atau dispose
  void cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// ✅ Bersihkan data lokal (misalnya saat logout)
  void clear() {
    _transactions.clear();
    notifyListeners();
  }
}

