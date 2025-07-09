import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type;
  final String description;
  final String category;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.category,
    required this.date,
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? description,
    String? category,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'description': description,
        'category': category,
        'date': date.toIso8601String(), // Simpan sebagai string ISO
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      final rawDate = json['date'];
      final parsedDate = rawDate is Timestamp
          ? rawDate.toDate()
          : DateTime.tryParse(rawDate.toString()) ?? DateTime.now();

      return TransactionModel(
        id: json['id'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] ?? '',
        description: json['description'] ?? '',
        category: json['category'] ?? '',
        date: parsedDate,
      );
    } catch (e) {
      print('❌ Gagal parsing TransactionModel: $e');
      rethrow;
    }
  }
}
