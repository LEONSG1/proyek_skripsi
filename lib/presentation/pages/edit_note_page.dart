import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

import 'category_picker_page.dart';
import 'add_note_page.dart';      // untuk enum EntryType

class EditNotePage extends StatefulWidget {
  final TransactionModel transaction;
  const EditNotePage({super.key, required this.transaction});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late EntryType _entryType;
  late String?   _category;
  late DateTime  _pickedDate;

  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _dateCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _entryType  = widget.transaction.type == 'Expense'
        ? EntryType.expense
        : EntryType.income;
    _category   = widget.transaction.category;
    _pickedDate = widget.transaction.date;

    _amountCtrl.text = widget.transaction.amount.toStringAsFixed(0);
    _descCtrl.text   = widget.transaction.description;
    _dateCtrl.text   = DateFormat('dd-MM-yyyy').format(_pickedDate);
  }

  /* ─────────────────────── BUILD ─────────────────────── */
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            /* ===== BUTTON UPDATE / DELETE ===== */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _onUpdate,
                      icon: const Icon(Icons.edit),
                      label: const Text('Update'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _onDelete,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /* ===== KARTU PUTIH FORM ===== */
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(.06))
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  /* —— JUMLAH —— */
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
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),

                  /* —— KATEGORI —— */
                  _NavTile(
                    icon: Icons.grid_view_rounded,
                    title: _category ?? 'Pilih Kategori',
                    isPlaceholder: _category == null,
                    onTap: () async {
                      final picked = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryPickerPage(isExpense: _entryType == EntryType.expense),
                        ),
                      );
                      if (picked != null) setState(() => _category = picked);
                    },
                  ),

                  /* —— TANGGAL —— */
                  _NavTile(
                    icon: Icons.calendar_month,
                    title: _dateCtrl.text,
                    isPlaceholder: false,
                    onTap: _pickDate,
                  ),

                  /* —— DESKRIPSI —— */
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
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /* ───────────────────── ACTIONS ───────────────────── */
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

  void _onUpdate() {
    final updated = TransactionModel(
      id: widget.transaction.id,
      date: _pickedDate,
      category: _category ?? widget.transaction.category,
      description: _descCtrl.text,
      amount: double.tryParse(_amountCtrl.text) ?? widget.transaction.amount,
      type: _entryType == EntryType.expense ? 'Expense' : 'Income',
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .updateTransaction(updated);                   // method yang ada
    Navigator.pop(context);
  }

  void _onDelete() {
    Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(widget.transaction.id);     // ganti nama sesuai provider
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }
}

/* ─────────── TILE UTILITIES (sama dgn AddNote) ─────────── */

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* >>> lebar & posisi sama dengan ListTile <<< */
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: leading is Icon
                  ? Icon((leading as Icon).icon, color: primary)
                  : leading,
            ),
          ),
          const SizedBox(width: 16), // sama dgn horizontalTitleGap
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
