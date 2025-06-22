import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import 'add_note_page.dart';
import 'edit_note_page.dart';
import '../../helpers/enum.dart';
import '../../helpers/currency_formatter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedType; // income, expense, null = all
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

  String getCycleLabel(CycleType cycle) {
    return switch (cycle) {
      CycleType.threeDays => "3 Hari Terakhir",
      CycleType.oneWeek => "1 Minggu Terakhir",
      CycleType.thirtyDays => "30 Hari Terakhir",
    };
  }

  List<TransactionModel> getFilteredTransactions(List<TransactionModel> allTx) {
    final cutoff = _cutoffDate(_selectedCycle);
    return allTx.where((tx) {
      final matchSearch = tx.description.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchType = _selectedType == null || tx.type.toLowerCase() == _selectedType!.toLowerCase();
      final matchDate = tx.date.isAfter(cutoff);
      return matchSearch && matchType && matchDate;
    }).toList();
  }

  void _showFilterBottomSheet(BuildContext context) {
    String? tempSelectedType = _selectedType;
    CycleType tempSelectedCycle = _selectedCycle;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tipe", style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  value: tempSelectedType == 'Income',
                  onChanged: (_) => setModalState(() => tempSelectedType = 'Income'),
                  title: const Text('Income'),
                ),
                CheckboxListTile(
                  value: tempSelectedType == 'Expense',
                  onChanged: (_) => setModalState(() => tempSelectedType = 'Expense'),
                  title: const Text('Expense'),
                ),
                CheckboxListTile(
                  value: tempSelectedType == null,
                  onChanged: (_) => setModalState(() => tempSelectedType = null),
                  title: const Text('Semua'),
                ),
                const Divider(),
                const Text("Siklus", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<CycleType>(
                  value: tempSelectedCycle,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: CycleType.values.map((CycleType cycle) {
                    return DropdownMenuItem<CycleType>(
                      value: cycle,
                      child: Text(getCycleLabel(cycle)),
                    );
                  }).toList(),
                  onChanged: (CycleType? value) {
                    if (value != null) {
                      setModalState(() {
                        tempSelectedCycle = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = tempSelectedType;
                        _selectedCycle = tempSelectedCycle;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade50,
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text("Terapkan"),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
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
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () => _showFilterBottomSheet(context),
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
                          DateFormat('dd-MM-yyyy').format(tx.date),
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
