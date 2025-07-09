import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/loan_debt_model.dart';
import '../../helpers/currency_formatter.dart';
import '../../helpers/enum.dart';
import '../../providers/loan_debt_provider.dart';
import 'add_loan_debt_page.dart';
import 'edit_loan_debt_page.dart';

const kBorderGrey = Color(0xFF969696);
const kBadgeGrey = Color(0xFFD1D1D1);

class LoansDebtsPage extends StatefulWidget {
  const LoansDebtsPage({super.key});

  @override
  State<LoansDebtsPage> createState() => _LoansDebtsPageState();
}

class _LoansDebtsPageState extends State<LoansDebtsPage> {
  CycleType _cycle = CycleType.all;
  LdStatus? _statusFilter;

  DateTime _cutoff(CycleType c) {
    final now = DateTime.now();
    return switch (c) {
      CycleType.oneWeek => now.subtract(const Duration(days: 7)),
      CycleType.thirtyDays => now.subtract(const Duration(days: 30)),
      CycleType.all => DateTime.fromMillisecondsSinceEpoch(0),
    };
  }

  String _cycleLabel(CycleType c) => switch (c) {
        CycleType.oneWeek => '7 Hari',
        CycleType.thirtyDays => '30 Hari',
        CycleType.all => 'Semua',
      };

  String _statusLabel(LdStatus? s) => s == null
      ? 'Status'
      : s == LdStatus.paid
          ? 'Paid'
          : 'Unpaid';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanDebtProvider>();
    final cutoff = _cutoff(_cycle);

    final list = provider.items.where((e) {
      final okDate = e.date.isAfter(cutoff);
      final okStatus = _statusFilter == null || e.status == _statusFilter;
      return okDate && okStatus;
    }).toList();

    final totalDebt = provider.items
        .where((e) => e.type == LdType.debt && e.status == LdStatus.unpaid)
        .fold<double>(0, (p, e) => p + e.amount);

    final totalLoan = provider.items
        .where((e) => e.type == LdType.loan && e.status == LdStatus.unpaid)
        .fold<double>(0, (p, e) => p + e.amount);

    final balance = totalLoan - totalDebt;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Loans & Debts'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F7F7),
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _SummaryCard(title: 'Total Loans', value: totalLoan),
                _SummaryCard(title: 'Total Debts', value: totalDebt),
                _SummaryCard(title: 'Balance', value: balance),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorderGrey),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final sel = await showMenu<int>(
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                        items: const [
                          PopupMenuItem(value: 0, child: Text('All')),
                          PopupMenuItem(value: 1, child: Text('Paid')),
                          PopupMenuItem(value: 2, child: Text('Unpaid')),
                        ],
                      );
                      if (sel != null) {
                        setState(() {
                          _statusFilter = sel == 0
                              ? null
                              : sel == 1
                                  ? LdStatus.paid
                                  : LdStatus.unpaid;
                        });
                      }
                    },
                    child: Text(_statusLabel(_statusFilter)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorderGrey),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final sel = await showMenu<CycleType>(
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                        items: CycleType.values
                            .map((c) => PopupMenuItem(
                                  value: c,
                                  child: Text(_cycleLabel(c)),
                                ))
                            .toList(),
                      );
                      if (sel != null) setState(() => _cycle = sel);
                    },
                    child: Text(_cycleLabel(_cycle)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Divider(height: 0),

          // List View
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Kosong'))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, i) {
                      final m = list[i];
                      final day = DateFormat('dd', 'id_ID').format(m.date);
                      final month = DateFormat('MMM', 'id_ID').format(m.date);
                      final year = DateFormat('yyyy', 'id_ID').format(m.date);
                      final rawDesc = m.description.trim();
                      final desc = rawDesc.isEmpty
                          ? ''
                          : rawDesc.length <= 18
                              ? rawDesc
                              : '${rawDesc.substring(0, 18)}…';

                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditLoanDebtPage(model: m),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Tanggal
                              SizedBox(
                                width: 48,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(day,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text(month,
                                        style:
                                            const TextStyle(fontSize: 13)),
                                    Text(year,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black45)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Detail
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.counterparty.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatCurrency(m.amount),
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    if (desc.isNotEmpty)
                                      Text(
                                        desc,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    _Badge(m),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 30,
                                child: Center(
                                  child: Icon(Icons.chevron_right,
                                      size: 28, color: Colors.black38),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Button Tambah
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC6A26),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddLoanDebtPage()),
              ),
              child: const Text('Tambah Utang',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: kBorderGrey, width: 1.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(formatCurrency(value),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      );
}

class _Badge extends StatelessWidget {
  final LoanDebtModel m;
  const _Badge(this.m);

  @override
  Widget build(BuildContext ctx) {
    final txt = m.status == LdStatus.paid
        ? 'Paid'
        : 'Unpaid (${m.type == LdType.loan ? 'Loan' : 'Debt'})';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: kBadgeGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(txt, style: const TextStyle(fontSize: 11)),
    );
  }
}
