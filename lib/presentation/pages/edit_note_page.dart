import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'package:proyek_baru/helpers/currency_formatter.dart';


class EditNotePage extends StatefulWidget {
  final TransactionModel transaction;

  const EditNotePage({super.key, required this.transaction});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _typeController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.transaction.date);
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _typeController = TextEditingController(text: widget.transaction.type);
  }

  Widget buildRowField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Text(": "),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(right: 8),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget buildDropdownRowField(String label, TextEditingController controller) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Text(": "),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: controller.text.isEmpty ? null : controller.text,
                items: ['Income', 'Expense']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(type),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  controller.text = value!;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(right: 8),
                ),
                alignment: Alignment.centerRight,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: Colors.orange[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
  "${formatCurrency(widget.transaction.amount)} • ${widget.transaction.date}",
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),

            const SizedBox(height: 16),

            // Tombol Edit & Delete (1 baris besar)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  // Tombol Edit
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final updated = TransactionModel(
                          id: widget.transaction.id,
                          date: _dateController.text,
                          description: _descriptionController.text,
                          amount: double.tryParse(_amountController.text) ?? 0.0,
                          type: _typeController.text,
                        );
                        Provider.of<TransactionProvider>(context, listen: false)
                            .updateTransaction(updated);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD8B1),
                        foregroundColor: Colors.orange[900],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tombol Delete
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<TransactionProvider>(context, listen: false)
                            .deleteTransaction(widget.transaction.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD8B1),
                        foregroundColor: Colors.orange[900],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Field daftar transaksi
            buildRowField("Date", _dateController),
            buildRowField("Description", _descriptionController),
            buildRowField("Amount", _amountController, keyboardType: TextInputType.number),
            buildDropdownRowField("Type", _typeController),
          ],
        ),
      ),
    );
  }
}
