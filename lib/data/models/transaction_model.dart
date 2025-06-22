class TransactionModel {
  final String id;
  final String date;
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
}
