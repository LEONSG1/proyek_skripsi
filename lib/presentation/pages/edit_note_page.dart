import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

enum EntryType { expense, income }

class EditNotePage extends StatefulWidget {
  final TransactionModel transaction;

  const EditNotePage({Key? key, required this.transaction}) : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late EntryType _entryType;
  late String _category;
  late DateTime _pickedDate;

  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  static const _expenseCategories = [
    'Beras',
    'Gaji Karyawan',
    'Beban Listrik',
  ];
  static const _incomeCategories = [
    'Nasi Ayam',
    'Nasi Rendang',
    'Lainnya',
  ];

  List<String> get _currentCats =>
      _entryType == EntryType.expense ? _expenseCategories : _incomeCategories;

  @override
  void initState() {
    super.initState();
    // initialize from the passed-in transaction
    _entryType = widget.transaction.type == 'Income'
        ? EntryType.income
        : EntryType.expense;
    _category = widget.transaction.category;
    _pickedDate = widget.transaction.date;
    _descCtrl.text = widget.transaction.description;
    _amountCtrl.text = widget.transaction.amount.toStringAsFixed(0);
    _dateCtrl.text = DateFormat('dd-MM-yyyy').format(_pickedDate);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate,
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

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1) AppBar with a bottom toggle:
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: Colors.orange[700],
        bottom: PreferredSize(
  preferredSize: const Size.fromHeight(48),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Pengeluaran'),
            selected: _entryType == EntryType.expense,
            onSelected: (_) => setState(() => _entryType = EntryType.expense),
            backgroundColor: Colors.white,
            selectedColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(
                color: _entryType == EntryType.expense
                    ? Colors.orange.shade700
                    : Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            labelStyle: TextStyle(
              color: _entryType == EntryType.expense
                  ? Colors.orange.shade700
                  : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text('Pemasukan'),
            selected: _entryType == EntryType.income,
            onSelected: (_) => setState(() => _entryType = EntryType.income),
            backgroundColor: Colors.white,
            selectedColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(
                color: _entryType == EntryType.income
                    ? Colors.orange.shade700
                    : Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            labelStyle: TextStyle(
              color: _entryType == EntryType.income
                  ? Colors.orange.shade700
                  : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  ),
),

      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 2) Update & Delete buttons in the body
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700]),
                    onPressed: () {
                      // simple field validation
                      if (_amountCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Isi jumlah dulu')));
                        return;
                      }
                      if (_category.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih kategori')));
                        return;
                      }
                      final updated = TransactionModel(
                        id: widget.transaction.id,
                        date: _pickedDate,
                        category: _category,
                        description: _descCtrl.text,
                        amount: double.parse(_amountCtrl.text),
                        type: _entryType == EntryType.expense
                            ? 'Expense'
                            : 'Income',
                      );
                      Provider.of<TransactionProvider>(context, listen: false)
                          .updateTransaction(updated);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400]),
                    onPressed: () {
                      Provider.of<TransactionProvider>(context, listen: false)
                          .deleteTransaction(widget.transaction.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3) Jumlah row
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.orange[700]),
              title: TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Jumlah',
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(),

            // 4) Kategori row
            ListTile(
              leading: Icon(Icons.category, color: Colors.orange[700]),
              title: Text(
                _category,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showCategorySheet,
            ),
            const Divider(),

            // 5) Tanggal row
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.orange[700]),
              title: Text(_dateCtrl.text),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const Divider(),

            // 6) Deskripsi row
            ListTile(
              leading: Icon(Icons.notes, color: Colors.orange[700]),
              title: TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi (opsional)',
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
