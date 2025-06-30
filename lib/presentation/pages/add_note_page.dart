import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/category_picker_page.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

enum EntryType { expense, income }

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  EntryType _entryType = EntryType.expense;
  String? _category;
  DateTime? _pickedDate;

  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  static const _expenseCategories = ['Beras', 'Gaji Karyawan', 'Beban Listrik'];
  static const _incomeCategories = ['Nasi Ayam', 'Nasi Rendang', 'Lainnya'];

  List<String> get _cats =>
      _entryType == EntryType.expense ? _expenseCategories : _incomeCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _pickedDate = picked;
        _dateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SegmentedButton<EntryType>(
                segments: const [
                  ButtonSegment(
                      value: EntryType.expense, label: Text('Pengeluaran')),
                  ButtonSegment(
                      value: EntryType.income, label: Text('Pemasukan')),
                ],
                selected: {_entryType},
                onSelectionChanged: (s) => setState(() {
                  _entryType = s.first;
                  _category = null;
                }),
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.white,
                  selectedBackgroundColor: cs.primary,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: cs.primary,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black.withOpacity(.06),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _FieldTile(
                      leading: const Icon(Icons.payments_outlined, size: 22),
                      child: TextFormField(
                        controller: _amountCtrl,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Masukkan jumlah' : null,
                      ),
                    ),
                    _NavTile(
                      icon: Icons.grid_view_rounded,
                      title: _category ?? 'Pilih Kategori',
                      isPlaceholder: _category == null,
                      onTap: () async {
                        final picked = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryPickerPage(
                              isExpense: _entryType == EntryType.expense,
                            ),
                          ),
                        );
                        if (picked != null) setState(() => _category = picked);
                      },
                    ),
                    _NavTile(
                      icon: Icons.calendar_month,
                      title: _dateCtrl.text.isEmpty
                          ? 'Pilih Tanggal'
                          : _dateCtrl.text,
                      isPlaceholder: _dateCtrl.text.isEmpty,
                      onTap: _pickDate,
                    ),
                    _FieldTile(
                      leading: const Icon(Icons.notes),
                      child: TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Deskripsi (opsional)',
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _onSubmit,
                        child: const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedDate == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pilih tanggal')));
        return;
      }
      if (_category == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pilih kategori')));
        return;
      }

      final tx = TransactionModel(
        id: UniqueKey().toString(),
        date: _pickedDate!,
        category: _category!,
        description: _descCtrl.text,
        amount: double.parse(_amountCtrl.text),
        type: _entryType == EntryType.expense ? 'Expense' : 'Income',
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add({
        'amount': tx.amount,
        'type': tx.type,
        'description': tx.description,
        'category': tx.category,
        'date': tx.date,
      });

      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(tx);

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }
}

class _FieldTile extends StatelessWidget {
  final Widget leading;
  final Widget child;
  const _FieldTile({required this.leading, required this.child});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: .8),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: leading is Icon
                  ? Icon((leading as Icon).icon, color: primary)
                  : leading,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        minLeadingWidth: 40,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isPlaceholder ? Colors.black38 : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: .8),
        ),
      );
}
