class TransactionModel {
  final String id;
  final DateTime date;
  final String category;
  final String description;
  final double amount;
  final String type;

  TransactionModel({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.type,
  }) : assert(category.isNotEmpty, 'Kategori wajib diisi');

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Validasi keberadaan dan isi dari 'category'
    final rawCategory = json['category'];
    if (rawCategory == null || rawCategory is! String || rawCategory.isEmpty) {
      throw FormatException('Field "category" tidak boleh kosong');
    }

    return TransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      category: rawCategory,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'category': category,
        'description': description,
        'amount': amount,
        'type': type,
      };
}
