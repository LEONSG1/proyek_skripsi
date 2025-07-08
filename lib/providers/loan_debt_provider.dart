import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyek_baru/data/models/loan_debt_model.dart';

class LoanDebtProvider extends ChangeNotifier {
  final List<LoanDebtModel> _items = [];
  List<LoanDebtModel> get data => List.unmodifiable(_items);

  StreamSubscription? _subscription;

  void listenToLoanDebts(String uid) {
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('loan_debts')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      final debts = snapshot.docs.map((doc) {
        final d = doc.data();
        return LoanDebtModel(
          id: doc.id,
          date: (d['date'] as Timestamp).toDate(),
          counterparty: d['counterparty'] ?? '',
          description: d['description'] ?? '',
          amount: (d['amount'] as num).toDouble(),
          type: d['type'] ?? 'debt',
          status: d['status'] ?? 'unpaid',
        );
      }).toList();

      _items
        ..clear()
        ..addAll(debts);

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

  /* Hapus fungsi add(), update(), remove() jika sudah pakai real-time listener */
}
