import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../providers/transaction_provider.dart';
import '../../helpers/currency_formatter.dart'; // ⬅️ Pakai helper konsisten di seluruh app

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;

    double income = 0;
    double expense = 0;

    for (var tx in transactions) {
      if (tx.type.toLowerCase() == 'income') {
        income += tx.amount;
      } else if (tx.type.toLowerCase() == 'expense') {
        expense += tx.amount;
      }
    }

    double total = income;
    double percent = total > 0 ? (expense / total).clamp(0.0, 1.0) : 0.0;
    double selisih = income - expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan"),
        backgroundColor: Colors.orange[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              generateAndOpenReport(context, transactions, income, expense, selisih);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Selisih", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            Text(formatCurrency(selisih), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.green),
                    const SizedBox(height: 4),
                    const Text("Pemasukan", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(formatCurrency(income), style: const TextStyle(color: Colors.green)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.red),
                    const SizedBox(height: 4),
                    const Text("Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("-${formatCurrency(expense)}", style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 16.0,
              percent: percent,
              animation: true,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(percent * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text("Pengeluaran"),
                ],
              ),
              progressColor: Colors.blue,
              backgroundColor: Colors.grey[200]!,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Rangkuman", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 20),
                const SizedBox(width: 8),
                const Text("Uang Masuk:"),
                const Spacer(),
                Text(formatCurrency(income)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.money_off, size: 20),
                const SizedBox(width: 8),
                const Text("Uang Keluar:"),
                const Spacer(),
                Text(formatCurrency(expense)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> generateAndOpenReport(
    BuildContext context,
    List transactions,
    double income,
    double expense,
    double selisih,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Laporan Keuangan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Pemasukan: ${formatCurrency(income)}'),
            pw.Text('Pengeluaran: ${formatCurrency(expense)}'),
            pw.Text('Selisih: ${formatCurrency(selisih)}'),
            pw.SizedBox(height: 20),
            pw.Text('Detail Transaksi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...transactions.map((tx) => pw.Bullet(
                  text: "${tx.date} - ${tx.description} (${tx.type}) ${formatCurrency(tx.amount)}",
                )),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/Laporan_Keuangan.pdf";
    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
