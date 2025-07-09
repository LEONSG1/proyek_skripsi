import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../providers/loan_debt_provider.dart';
import '../../data/models/loan_debt_model.dart';

/* — WARNA TETAP — */
const kPurple = Color(0xFF7C5CFF);
const kPurpleGrad = LinearGradient(
  colors: [Color(0xFF9F7BFF), Color(0xFF7C5CFF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

class AddLoanDebtPage extends StatefulWidget {
  const AddLoanDebtPage({super.key});

  @override
  State<AddLoanDebtPage> createState() => _AddLoanDebtPageState();
}

class _AddLoanDebtPageState extends State<AddLoanDebtPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateC = TextEditingController();
  final _nameC = TextEditingController();
  final _descC = TextEditingController();
  final _amountC = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  LdType? _type;
  LdStatus _status = LdStatus.unpaid;

  @override
  void initState() {
    super.initState();
    _dateC.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _dateC.dispose();
    _nameC.dispose();
    _descC.dispose();
    _amountC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateC.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tipe Debt atau Loan')),
      );
      return;
    }

    final newItem = LoanDebtModel(
      id: '', // akan diisi oleh Firestore
      date: _selectedDate,
      counterparty: _nameC.text.trim(),
      description: _descC.text.trim(),
      amount: double.parse(_amountC.text),
      type: _type!,
      status: _status,
    );

    await context.read<LoanDebtProvider>().addItem(newItem);
    Navigator.pop(context);
  }

  InputDecoration _fieldDec({Widget? prefix, Widget? suffix}) => InputDecoration(
        prefix: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF969696)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kPurple, width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Utang / Piutang'),
        backgroundColor: Colors.orange[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const _Label('Date'),
              TextFormField(
                controller: _dateC,
                readOnly: true,
                onTap: _pickDate,
                decoration: _fieldDec(
                  suffix: const Icon(Icons.calendar_today, color: kPurple),
                ),
              ),
              const SizedBox(height: 12),
              const _Label('Counterparty'),
              TextFormField(
                controller: _nameC,
                decoration: _fieldDec(),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              const _Label('Description'),
              TextFormField(
                controller: _descC,
                maxLines: 3,
                decoration: _fieldDec(),
              ),
              const SizedBox(height: 18),
              const _Label('Amount'),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountC,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDec(prefix: const Text('Rp')),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    flex: 3,
                    child: ToggleButtons(
                      isSelected: [
                        _type == LdType.debt,
                        _type == LdType.loan,
                      ],
                      onPressed: (i) =>
                          setState(() => _type = i == 0 ? LdType.debt : LdType.loan),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text('Debt'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text('Loan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _Label('Status'),
              ToggleButtons(
                isSelected: [
                  _status == LdStatus.paid,
                  _status == LdStatus.unpaid,
                ],
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: kPurple,
                onPressed: (i) => setState(() =>
                    _status = i == 0 ? LdStatus.paid : LdStatus.unpaid),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 38),
                    child: Text('Paid'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text('Unpaid'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: kPurpleGrad,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text('Save',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
      );
}
