enum LdType   { loan, debt }              // loan = meminjamkan, debt = meminjam
enum LdStatus { unpaid, paid }

class LoanDebtModel {
  final String id;
  final DateTime date;
  final String counterparty;              // Pihak yang terkait
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

  /// 🔁 From Firestore (string ISO date)
  factory LoanDebtModel.fromJson(Map<String, dynamic> json) {
    return LoanDebtModel(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      counterparty: json['counterparty'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: LdType.values.byName(json['type']),
      status: LdStatus.values.byName(json['status']),
    );
  }

  /// 🔁 To Firestore (string ISO date)
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),        // ⬅️ simpan sebagai ISO string
        'counterparty': counterparty,
        'description': description,
        'amount': amount,
        'type': type.name,
        'status': status.name,
      };
}
