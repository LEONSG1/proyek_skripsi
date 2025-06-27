// lib/presentation/pages/chart_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../providers/transaction_provider.dart';
import '../../helpers/currency_formatter.dart';
import '../../helpers/enum.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
    /* ---------- ❶ VARIABEL GLOBAL SEDERHANA ---------- */
  static CycleType _lastCycle = CycleType.all;

  /* ---------- STATE HALAMAN ---------- */
  late CycleType _selectedCycle;               // diisi di initState

  /* ---------- ❷ INIT STATE ---------- */
  @override
  void initState() {
    super.initState();
    _selectedCycle = _lastCycle;               // ambil nilai terakhir
  }

  DateTime _cutoffDate(CycleType cycle) {
  final now = DateTime.now();
  switch (cycle) {
    case CycleType.oneWeek:
      return now.subtract(const Duration(days: 7));
    case CycleType.thirtyDays:
      return now.subtract(const Duration(days: 30));
    case CycleType.all:                       // tampilkan semua data
      return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

String _cycleLabel(CycleType c) {
  switch (c) {
    case CycleType.oneWeek:
      return '7 Hari';
    case CycleType.thirtyDays:
      return '30 Hari';
    case CycleType.all:
      return 'Semua';
  }
}


  @override
  Widget build(BuildContext context) {
    final allTx = context.watch<TransactionProvider>().transactions;
    final cutoff = _cutoffDate(_selectedCycle);

    // hanya ambil transaksi setelah cutoff
    final txs = allTx.where((tx) => tx.date.isAfter(cutoff)).toList();

    double income = 0, expense = 0;
    for (var t in txs) {
      if (t.type.toLowerCase() == 'income') income += t.amount;
      else expense += t.amount;
    }

    final selisih = income - expense;
    // persentase pengeluaran = expense / income
    final percent = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: Colors.orange[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context, txs, income, expense, selisih),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Periode ──
            Row(
              children: CycleType.values.map((c) {
                final sel = c == _selectedCycle;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: sel ? Colors.orange[700] : Colors.white,
                        foregroundColor: sel ? Colors.white : Colors.orange[700],
                        side: BorderSide(color: Colors.orange[700]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => setState(() => _selectedCycle = c),
                      child: Text(_cycleLabel(c)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Selisih & Ringkasan ──
            Text('Selisih', style: TextStyle(color: Colors.grey[700])),
            Text(formatCurrency(selisih),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.green),
                    const SizedBox(height: 4),
                    const Text('Pemasukan', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(formatCurrency(income), style: const TextStyle(color: Colors.green)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.red),
                    const SizedBox(height: 4),
                    const Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("-${formatCurrency(expense)}", style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Pie Chart ──
            CircularPercentIndicator(
              radius: 100,
              lineWidth: 16,
              percent: percent,
              animation: true,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${(percent * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Pengeluaran'),
                ],
              ),
              progressColor: Colors.redAccent,
              backgroundColor: Colors.grey[200]!,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Rangkuman', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 20),
                const SizedBox(width: 8),
                const Text('Uang Masuk:'),
                const Spacer(),
                Text(formatCurrency(income)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.money_off, size: 20),
                const SizedBox(width: 8),
                const Text('Uang Keluar:'),
                const Spacer(),
                Text(formatCurrency(expense)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, List txs, double inc, double exp, double sel) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (_) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Laporan Keuangan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('Pemasukan: ${formatCurrency(inc)}'),
          pw.Text('Pengeluaran: ${formatCurrency(exp)}'),
          pw.Text('Selisih: ${formatCurrency(sel)}'),
          pw.SizedBox(height: 20),
          pw.Text('Detail Transaksi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...txs.map((t) => pw.Bullet(text:
              '${DateFormat('dd-MM-yyyy').format(t.date)} • ${t.category} • ${formatCurrency(t.amount)} (${t.type})')),
        ],
      );
    }));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/laporan.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
