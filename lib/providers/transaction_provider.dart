import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  StreamSubscription? _subscription;

  List<TransactionModel> get transactions => _transactions;

  Future<void> saveTransaction(TransactionModel tx) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(); // auto-ID

    final newTx = tx.copyWith(id: docRef.id);
    await docRef.set(newTx.toJson());
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

  Future<void> fetchFromFirebase(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    final data = snapshot.docs.map((doc) {
      try {
        final map = doc.data();
        map['id'] = doc.id;
        return TransactionModel.fromJson(map);
      } catch (e) {
        debugPrint('❌ Gagal parsing transaksi: $e');
        rethrow;
      }
    }).toList();

    _transactions
      ..clear()
      ..addAll(data);

    notifyListeners();
  }

  void listenToTransactions(String uid) {
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        try {
          final map = doc.data();
          map['id'] = doc.id;
          return TransactionModel.fromJson(map);
        } catch (e) {
          debugPrint('❌ Gagal parsing transaksi (listener): $e');
          rethrow;
        }
      }).toList();

      _transactions
        ..clear()
        ..addAll(data);

      notifyListeners();
    });
  }

  void cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  void clear() {
    _transactions.clear();
    notifyListeners();
  }
}
