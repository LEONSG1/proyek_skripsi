import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../providers/loan_debt_provider.dart';
import '../../data/models/loan_debt_model.dart';

/* warna ungu sama */
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
  final _fKey = GlobalKey<FormState>();
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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _selectedDate = d;
        _dateC.text = DateFormat('MM/dd/yyyy').format(d);
      });
    }
  }

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
          key: _fKey,
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
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                  // ── kolom Amount ───────────────────────────────
                  Flexible(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountC,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDec(
                          prefix: const Text('Rp')), // ← bebas ‘Rp’ / ‘$’
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // ← hanya angka
                        // jika mau izinkan desimal 2 digit, pakai baris di bawah
                        // FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Toggle Loan / Debt ──────────────────────────
                  Flexible(
                      flex: 3,
                      child: ToggleButtons(
                        isSelected: [
                          _type == LdType.debt,
                          _type == LdType.loan
                        ],
                        onPressed: (i) {
                          print("User clicked toggle index: $i");
                          setState(
                              () => _type = i == 0 ? LdType.debt : LdType.loan);
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text('Debt'), // ← kiri
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text('Loan'), // ← kanan
                          ),
                        ],
                      )),
                ],
              ),
              const SizedBox(height: 18),
              const _Label('Status'),
              ToggleButtons(
                isSelected: [
                  _status == LdStatus.paid,
                  _status == LdStatus.unpaid
                ],
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: kPurple,
                onPressed: (i) => setState(
                    () => _status = i == 0 ? LdStatus.paid : LdStatus.unpaid),
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
              /* Save */
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

  /* ---------- helpers ---------- */
  InputDecoration _fieldDec({Widget? prefix, Widget? suffix}) =>
      InputDecoration(
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

  void _save() {
    if (!_fKey.currentState!.validate()) return;

    if (_type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tipe terlebih dahulu')),
      );
      return;
    }

    final m = LoanDebtModel(
      id: UniqueKey().toString(),
      date: _selectedDate,
      counterparty: _nameC.text,
      description: _descC.text,
      amount: double.parse(_amountC.text),
      type: _type!,
      status: _status,
    );

    Provider.of<LoanDebtProvider>(context, listen: false).add(m);
    Navigator.pop(context);
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
