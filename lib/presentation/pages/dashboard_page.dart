import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import 'add_note_page.dart';
import 'edit_note_page.dart';
import 'package:proyek_baru/helpers/currency_formatter.dart';
import 'package:intl/intl.dart';
import '../../helpers/enum.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedType; // untuk filter Income/Expense
  CycleType _selectedCycle = CycleType.thirtyDays;

  DateTime _cutoffDate(CycleType filter) {
    final now = DateTime.now();
    switch (filter) {
      case CycleType.threeDays:
        return now.subtract(const Duration(days: 3));
      case CycleType.oneWeek:
        return now.subtract(const Duration(days: 7));
      case CycleType.thirtyDays:
        return now.subtract(const Duration(days: 30));
    }
  }

  List<TransactionModel> getFilteredTransactions(List<TransactionModel> allTx) {
    final cutoff = _cutoffDate(_selectedCycle);
    return allTx.where((tx) {
      final matchSearch = tx.description.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchType = _selectedType == null || tx.type.toLowerCase() == _selectedType!.toLowerCase();
      final txDate = tx.date is DateTime ? tx.date as DateTime : DateTime.parse(tx.date);
      final matchDate = txDate.isAfter(cutoff);
      return matchSearch && matchType && matchDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTx = context.watch<TransactionProvider>().transactions;
    final transactions = getFilteredTransactions(allTx);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Groceries"),
        backgroundColor: Colors.orange[700],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNotePage()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari transaksi...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "All", child: Text("Semua")),
                    const PopupMenuItem(value: "Income", child: Text("Income")),
                    const PopupMenuItem(value: "Expense", child: Text("Expense")),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      enabled: false,
                      child: DropdownButton<CycleType>(
                        value: _selectedCycle,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: CycleType.values.map((CycleType cycle) {
                          return DropdownMenuItem<CycleType>(
                            value: cycle,
                            child: Text(
                              switch (cycle) {
                                CycleType.threeDays => "3 Hari Terakhir",
                                CycleType.oneWeek => "1 Minggu Terakhir",
                                CycleType.thirtyDays => "30 Hari Terakhir",
                              },
                            ),
                          );
                        }).toList(),
                        onChanged: (CycleType? value) {
                          if (value != null) {
                            setState(() {
                              _selectedCycle = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _selectedType = value == "All" ? null : value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("Belum ada transaksi"))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditNotePage(transaction: tx),
                            ),
                          );
                        },
                        leading: Text(
                          tx.date,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Text(tx.description),
                        subtitle: Text(tx.type),
                        trailing: Text(
                          formatCurrency(tx.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
