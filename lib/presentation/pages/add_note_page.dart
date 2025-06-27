import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../main.dart'; // adjust if your MyApp import path differs

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

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  static const List<String> _expenseCategories = [
    'Beras',
    'Gaji Karyawan',
    'Beban Listrik',
  ];
  static const List<String> _incomeCategories = [
    'Nasi Ayam',
    'Nasi Rendang',
    'Lainnya',
  ];

  List<String> get _currentCats =>
      _entryType == EntryType.expense ? _expenseCategories : _incomeCategories;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? now,
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
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
        backgroundColor: Colors.orange[700],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(height: 16),

            // Pill toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pengeluaran'),
                    selected: _entryType == EntryType.expense,
                    onSelected: (_) => setState(() {
                      _entryType = EntryType.expense;
                      _category = null;
                    }),
                    selectedColor: Colors.orange[700],
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                        color: _entryType == EntryType.expense
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pemasukan'),
                    selected: _entryType == EntryType.income,
                    onSelected: (_) => setState(() {
                      _entryType = EntryType.income;
                      _category = null;
                    }),
                    selectedColor: Colors.orange[700],
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                        color: _entryType == EntryType.income
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // Jumlah
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.orange[700]),
              title: TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  hintText: 'Rp',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Masukkan jumlah' : null,
              ),
            ),
            const Divider(),

            // Kategori
            ListTile(
              leading: Icon(Icons.category, color: Colors.orange[700]),
              title: Text(
                _category ?? 'Pilih Kategori',
                style: TextStyle(
                  color: _category == null ? Colors.black38 : Colors.black87,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                builder: (_) => SafeArea(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _currentCats.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (c, i) {
                      final cat = _currentCats[i];
                      return ListTile(
                        title: Text(cat),
                        onTap: () {
                          setState(() => _category = cat);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const Divider(),

            // Tanggal
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.orange[700]),
              title: Text(
                _dateCtrl.text.isEmpty ? 'Pilih Tanggal' : _dateCtrl.text,
                style: TextStyle(
                  color:
                      _dateCtrl.text.isEmpty ? Colors.black38 : Colors.black87,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const Divider(),

            // Deskripsi
            ListTile(
              leading: Icon(Icons.notes, color: Colors.orange[700]),
              title: TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi (opsional)',
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
            ),
            const Divider(),

            const SizedBox(height: 24),

            // Kirim button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700]),
                  child: const Text('Kirim'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_pickedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih tanggal')));
                        return;
                      }
                      if (_category == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih kategori')));
                        return;
                      }

                      final tx = TransactionModel(
                        id: UniqueKey().toString(),
                        date: _pickedDate!,
                        category: _category!,
                        description: _descCtrl.text,
                        amount: double.parse(_amountCtrl.text),
                        type: _entryType == EntryType.expense
                            ? 'Expense'
                            : 'Income',
                      );
                      Provider.of<TransactionProvider>(context, listen: false)
                          .addTransaction(tx);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MyApp()),
                      );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
