// lib/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:proyek_baru/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  /* ────────── 1. VAR GLOBAL SEDERHANA ────────── */
  static String? _lastType;
  static CycleType _lastCycle = CycleType.all;

  final _searchController = TextEditingController();
  late String? _selectedType;
  late CycleType _selectedCycle;

TransactionProvider? _txProvider;


  @override
void initState() {
  super.initState();

  _selectedType  = _lastType;
  _selectedCycle = _lastCycle;
  _searchController.addListener(() => setState(() {}));

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    _txProvider = Provider.of<TransactionProvider>(context, listen: false);
    _txProvider!.listenToTransactions(uid);
  }
}

@override
void dispose() {
  _txProvider?.cancelSubscription(); // ✅ Aman
  _searchController.dispose();
  super.dispose();
}



  DateTime _cutoffDate(CycleType f) {
    final now = DateTime.now();
    switch (f) {
      case CycleType.oneWeek:
        return now.subtract(const Duration(days: 7));
      case CycleType.thirtyDays:
        return now.subtract(const Duration(days: 30));
      case CycleType.all:
        return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  String getCycleLabel(CycleType c) => switch (c) {
        CycleType.oneWeek => '7 Hari Terakhir',
        CycleType.thirtyDays => '30 Hari Terakhir',
        CycleType.all => 'Semua',
      };

  List<TransactionModel> getFilteredTransactions(List<TransactionModel> allTx) {
    final cutoff = _cutoffDate(_selectedCycle);
    return allTx.where((tx) {
      final matchSearch = tx.description
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchType = _selectedType == null ||
          tx.type.toLowerCase() == _selectedType!.toLowerCase();
      final matchDate = tx.date.isAfter(cutoff);
      return matchSearch && matchType && matchDate;
    }).toList();
  }

  /* ────────── BOTTOM-SHEET FILTER ────────── */
  void _showFilterBottomSheet(BuildContext context) {
    String? tempSelectedType = _selectedType;
    CycleType tempSelectedCycle = _selectedCycle;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          // —— util buat chip siklus biru/abu ——
          Widget buildCycleChip(CycleType cycle) {
            const selColor = Color(0xFF0B65D9);
            const unsColor = Color(0xFFE1E3E6);
            final bool isSel = tempSelectedCycle == cycle;
            return ChoiceChip(
              label: Text(
                getCycleLabel(cycle),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSel ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSel,
              onSelected: (_) => setModalState(() => tempSelectedCycle = cycle),
              selectedColor: selColor,
              backgroundColor: unsColor,
              shape: const StadiumBorder(),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            );
          }
          // ————————————————————————————————

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipe',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                    value: tempSelectedType == 'Income',
                    onChanged: (_) =>
                        setModalState(() => tempSelectedType = 'Income'),
                    title: const Text('Income')),
                CheckboxListTile(
                    value: tempSelectedType == 'Expense',
                    onChanged: (_) =>
                        setModalState(() => tempSelectedType = 'Expense'),
                    title: const Text('Expense')),
                CheckboxListTile(
                    value: tempSelectedType == null,
                    onChanged: (_) =>
                        setModalState(() => tempSelectedType = null),
                    title: const Text('Semua')),
                const Divider(),
                const Text('Siklus',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // —— baris chip siklus ——
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: CycleType.values
                          .where((c) => c != CycleType.all)
                          .map((c) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: buildCycleChip(c)))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    buildCycleChip(CycleType.all),
                  ],
                ),
                const SizedBox(height: 20),

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
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Terapkan'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  /* ───────────────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    final allTx = context.watch<TransactionProvider>().transactions;
    final transactions = getFilteredTransactions(allTx);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          color: const Color(0xFFDC6A26),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 24, left: 16, right: 16, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ────── potongan di dalam Column ──────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'logout') {
                            AuthService().signout(context: context);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'logout',
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                      const Text(
                        'Groceries',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // spacer agar teks tetap di tengah
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30)),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Cari',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                            color: Colors.white24, shape: BoxShape.circle),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon:
                              const Icon(Icons.filter_alt, color: Colors.white),
                          onPressed: () => _showFilterBottomSheet(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('Belum ada transaksi'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (ctx, i) {
                final tx = transactions[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                          builder: (_) => EditNotePage(transaction: tx))),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('dd-MM-yyyy').format(tx.date),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 4),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(tx.category,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(tx.type,
                                            style: TextStyle(
                                                color: tx.type == 'Income'
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                                fontWeight: FontWeight.bold)),
                                      ]),
                                  Text(formatCurrency(tx.amount),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ]),
                          ]),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddNotePage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC6A26),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buat Catatan Baru',
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