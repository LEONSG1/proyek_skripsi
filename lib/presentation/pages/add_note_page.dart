import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:proyek_baru/main.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  String _monthName(int month) {
    const months = [
      '', 'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
      'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        backgroundColor: Colors.orange[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
  controller: _dateController,
  decoration: const InputDecoration(
    labelText: 'Date',
    border: OutlineInputBorder(),
    suffixIcon: Icon(Icons.calendar_today),
  ),
  readOnly: true,
  onTap: () async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Format tanggalnya jadi 20 JUNI 2025
      final formatted = "${picked.day} ${_monthName(picked.month)} ${picked.year}";
      _dateController.text = formatted;
    }
  },
  validator: (value) =>
      value!.isEmpty ? 'Tanggal tidak boleh kosong' : null,
),

              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
  controller: _amountController,
  decoration: const InputDecoration(
    labelText: 'Amount',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly, // ❗ hanya angka
  ],
  validator: (value) =>
      value!.isEmpty ? 'Nominal tidak boleh kosong' : null,
),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
  value: _typeController.text.isEmpty ? null : _typeController.text,
  decoration: const InputDecoration(
    labelText: 'Type',
    border: OutlineInputBorder(),
  ),
  items: ['Income', 'Expense']
      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
      .toList(),
  onChanged: (value) {
    _typeController.text = value!;
  },
  validator: (value) => value == null ? 'Tipe tidak boleh kosong' : null,
),

              const SizedBox(height: 20),
              ElevatedButton(
               onPressed: () {
  if (_formKey.currentState!.validate()) {
    final tx = TransactionModel(
      id: UniqueKey().toString(), // or use another unique id generator as needed
      date: _dateController.text,
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      type: _typeController.text,
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(tx);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
    );
  }
},

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                ),
                child: const Text("Kirim"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
