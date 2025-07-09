import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/loan_debt_model.dart';

class LoanDebtProvider extends ChangeNotifier {
  final List<LoanDebtModel> _items = [];
  StreamSubscription? _subscription;

  List<LoanDebtModel> get items => List.unmodifiable(_items);

  void listenToLoanDebts(String uid) {
    debugPrint('[LoanDebtProvider] Listening to UID: $uid');

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('loan_debts')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      debugPrint('[LoanDebtProvider] Docs: ${snapshot.docs.length}');

      final data = snapshot.docs.map((doc) {
        try {
          final map = doc.data();
          map['id'] = doc.id; // inject id ke dalam map
          return LoanDebtModel.fromJson(map);
        } catch (e) {
          debugPrint('❌ Gagal parsing LoanDebt: $e');
          rethrow;
        }
      }).toList();

      _items
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
    _items.clear();
    notifyListeners();
  }

  Future<void> addItem(LoanDebtModel item) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('loan_debts')
        .doc();

    final newItem = item.copyWith(id: docRef.id);
    await docRef.set(newItem.toJson());
  }

  Future<void> updateItem(LoanDebtModel item) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('loan_debts')
        .doc(item.id)
        .update(item.toJson());
  }

  Future<void> deleteItem(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('loan_debts')
        .doc(id)
        .delete();
  }
}
