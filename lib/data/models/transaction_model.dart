class TransactionModel {
  final String id; // ✅ Tambahkan id
  final DateTime date;
  final String description;
  final double amount;
  final String type;

  TransactionModel({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'type': type,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      amount: json['amount'],
      type: json['type'],
    );
  }
}
