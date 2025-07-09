import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/loan_debt_model.dart';
import '../../providers/loan_debt_provider.dart';

class EditLoanDebtPage extends StatefulWidget {
  final LoanDebtModel model;
  const EditLoanDebtPage({super.key, required this.model});

  @override
  State<EditLoanDebtPage> createState() => _EditLoanDebtPageState();
}

class _EditLoanDebtPageState extends State<EditLoanDebtPage> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late TextEditingController _nameC;
  late TextEditingController _descC;
  late TextEditingController _amountC;
  late LdType _type;
  late LdStatus _status;

  @override
  void initState() {
    super.initState();
    final m = widget.model;
    _date = m.date;
    _nameC = TextEditingController(text: m.counterparty);
    _descC = TextEditingController(text: m.description);
    _amountC = TextEditingController(text: m.amount.toStringAsFixed(0));
    _type = m.type;
    _status = m.status;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _amountC.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      );

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.model.copyWith(
      date: _date,
      counterparty: _nameC.text.trim(),
      description: _descC.text.trim(),
      amount: double.parse(_amountC.text),
      type: _type,
      status: _status,
    );

    await context.read<LoanDebtProvider>().updateItem(updated);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<LoanDebtProvider>().deleteItem(widget.model.id);
      Navigator.pop(context); // Close page
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(_date);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Record')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Update'),
                      onPressed: _update,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: _delete,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Date
              Text('Date', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _dec(''),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _nameC,
                decoration: _dec('Counterparty'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _descC,
                decoration: _dec('Description'),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 18),

              // Amount
              Text('Amount', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountC,
                      keyboardType: TextInputType.number,
                      decoration: _dec(''),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 40,
                    child: ToggleButtons(
                      isSelected: [_type == LdType.loan, _type == LdType.debt],
                      onPressed: (i) => setState(
                          () => _type = i == 0 ? LdType.loan : LdType.debt),
                      borderRadius: BorderRadius.circular(6),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text('Loan'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text('Debt'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 18),

              // Status
              Text('Status', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              SizedBox(
                height: 40,
                child: ToggleButtons(
                  isSelected: [
                    _status == LdStatus.paid,
                    _status == LdStatus.unpaid,
                  ],
                  onPressed: (i) => setState(() =>
                      _status = i == 0 ? LdStatus.paid : LdStatus.unpaid),
                  borderRadius: BorderRadius.circular(6),
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text('Paid')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text('Unpaid')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
