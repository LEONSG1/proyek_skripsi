// lib/presentation/pages/edit_inventory_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/inventory_item.dart';
import '../../providers/inventory_provider.dart';

class EditInventoryPage extends StatefulWidget {
  final InventoryItem item;
  const EditInventoryPage({Key? key, required this.item}) : super(key: key);

  @override
  State<EditInventoryPage> createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  final _formKey   = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _priceCtrl;

  // ── state ──
  late String _selectedUnit;
  late String _selectedCategory;

  // ── const ui ──
  static const _primary    = Color(0xFF6C4AB0);
  static const _bg         = Color(0xFFF2F4F8);
  static const _units      = ['kg', 'L', 'pcs'];
  static const _categories = ['Bahan Pokok', 'Olahan', 'Bumbu'];

  @override
  void initState() {
    super.initState();
    _nameCtrl   = TextEditingController(text: widget.item.name);
    _stockCtrl  = TextEditingController(text: widget.item.stock.toString());
    _priceCtrl  = TextEditingController(text: widget.item.price.toStringAsFixed(0));

    _selectedUnit      = widget.item.unit;
    _selectedCategory  = widget.item.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  // bottom-sheet kategori
  Future<void> _pickCategory() async {
  final result = await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    // ↓↓↓ builder baru ↓↓↓
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize
            .min,                // <-- kunci agar sheet setinggi konten
        children: _categories.map((c) => ListTile(
          leading: const Icon(Icons.category_outlined, color: _primary),
          title: Text(c),
          trailing: c == _selectedCategory
              ? const Icon(Icons.check, color: _primary)
              : null,
          onTap: () => Navigator.pop(context, c),
        )).toList(),
      ),
    ),
  );
  if (result != null) setState(() => _selectedCategory = result);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── tombol EDIT & DELETE ──
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _onUpdate,
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text('Update', style: TextStyle(color: Colors.amber), ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _onDelete,
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Name ──
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _decoration('Nama Barang', Icons.inventory_2_outlined),
                    validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // ── Stock ──
                  TextFormField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Jumlah Stok', Icons.layers_outlined),
                    validator: (v) => v!.trim().isEmpty ? 'Stok wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // ── Unit (ChoiceChip) ──
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: _units.map((u) => ChoiceChip(
                        label: Text(u),
                        selected: _selectedUnit == u,
                        onSelected: (_) => setState(() => _selectedUnit = u),
                        selectedColor: _primary.withOpacity(.15),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Price ──
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Harga per unit', Icons.price_change_outlined),
                    validator: (v) => v!.trim().isEmpty ? 'Harga wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // ── Category (modal) ──
                  GestureDetector(
                    onTap: _pickCategory,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: _decoration('Kategori', Icons.category_outlined)
                            .copyWith(hintText: _selectedCategory),
                        validator: (_) => _selectedCategory.isEmpty ? 'Pilih kategori' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── actions ──
  void _onUpdate() {
    if (!_formKey.currentState!.validate()) return;

    context.read<InventoryProvider>().updateItem(
      id: widget.item.id,
      name: _nameCtrl.text.trim(),
      stock: int.tryParse(_stockCtrl.text) ?? widget.item.stock,
      unit: _selectedUnit,
      price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
      category: _selectedCategory,
    );
    Navigator.pop(context);
  }

  void _onDelete() {
    context.read<InventoryProvider>().removeItem(widget.item.id);
    Navigator.pop(context);
  }
}
