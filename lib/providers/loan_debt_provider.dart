import 'package:flutter/material.dart';
import '../data/models/loan_debt_model.dart';

class LoanDebtProvider extends ChangeNotifier {
  final List<LoanDebtModel> _items = [];

  List<LoanDebtModel> get data => List.unmodifiable(_items);

  /* ---------- CRUD dasar ---------- */
  void add(LoanDebtModel m) {
    _items.add(m);
    notifyListeners();
  }

  void update(LoanDebtModel m) {
    final idx = _items.indexWhere((e) => e.id == m.id);
    if (idx != -1) {
      _items[idx] = m;
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
