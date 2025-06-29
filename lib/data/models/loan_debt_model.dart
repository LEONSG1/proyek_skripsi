// ================================================
//  Model data catatan Hutang / Piutang
// ================================================

enum LdType   { loan, debt }              // Loan = uang dipinjamkan, Debt = uang dipinjam
enum LdStatus { unpaid, paid }

class LoanDebtModel {
  final String   id;
  final DateTime date;
  final String   counterparty;            // Nama pihak (pemilik / peminjam)
  final String   description;
  final double   amount;
  final LdType   type;
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

  /* ───────────── copyWith (baru) ───────────── */
  LoanDebtModel copyWith({
    String?   id,
    DateTime? date,
    String?   counterparty,
    String?   description,
    double?   amount,
    LdType?   type,
    LdStatus? status,
  }) {
    return LoanDebtModel(
      id          : id          ?? this.id,
      date        : date        ?? this.date,
      counterparty: counterparty?? this.counterparty,
      description : description ?? this.description,
      amount      : amount      ?? this.amount,
      type        : type        ?? this.type,
      status      : status      ?? this.status,
    );
  }
  /* ──────────────────────────────────────────── */

  /* ---------- helper map<->obj (jika kelak simpan ke Firestore) ---------- */
  Map<String, dynamic> toJson() => {
        'id'          : id,
        'date'        : date.millisecondsSinceEpoch,
        'counterparty': counterparty,
        'description' : description,
        'amount'      : amount,
        'type'        : type.name,
        'status'      : status.name,
      };

  factory LoanDebtModel.fromJson(Map<String, dynamic> j) => LoanDebtModel(
        id          : j['id'],
        date        : DateTime.fromMillisecondsSinceEpoch(j['date']),
        counterparty: j['counterparty'],
        description : j['description'],
        amount      : (j['amount'] as num).toDouble(),
        type        : LdType.values.byName(j['type']),
        status      : LdStatus.values.byName(j['status']),
      );
}
