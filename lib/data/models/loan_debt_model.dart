import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum LdType { loan, debt }              // loan = meminjamkan, debt = meminjam
enum LdStatus { unpaid, paid }

class LoanDebtModel {
  final String id;
  final DateTime date;
  final String counterparty;
  final String description;
  final double amount;
  final LdType type;
  final LdStatus status;

  LoanDebtModel({
    required this.id,
    required this.date,
    required this.counterparty,
    required this.description,
    required this.amount,
    required this.type,
    required this.status,
  });

  LoanDebtModel copyWith({
    String? id,
    DateTime? date,
    String? counterparty,
    String? description,
    double? amount,
    LdType? type,
    LdStatus? status,
  }) {
    return LoanDebtModel(
      id: id ?? this.id,
      date: date ?? this.date,
      counterparty: counterparty ?? this.counterparty,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  /// 🔁 From Firestore (String or Timestamp)
  factory LoanDebtModel.fromJson(Map<String, dynamic> json) {
    try {
      final rawDate = json['date'];
      final parsedDate = rawDate is Timestamp
          ? rawDate.toDate()
          : DateTime.tryParse(rawDate.toString()) ?? DateTime.now();

      return LoanDebtModel(
        id: json['id'] ?? '',
        date: parsedDate,
        counterparty: json['counterparty'] ?? '',
        description: json['description'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        type: LdType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => LdType.debt,
        ),
        status: LdStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => LdStatus.unpaid,
        ),
      );
    } catch (e) {
      debugPrint('❌ Gagal parsing LoanDebtModel: $e');
      rethrow;
    }
  }

  /// 🔁 To Firestore
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'counterparty': counterparty,
        'description': description,
        'amount': amount,
        'type': type.name,
        'status': status.name,
      };
}
