// lib/presentation/pages/add_inventory_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _stockC = TextEditingController();
  final _priceC = TextEditingController();

  String? _selectedUnit;
  String? _selectedCategory;

  static const _primary = Color(0xFF6C4AB0); // ungu utama
  static const _bg = Color(0xFFF2F4F8); // abu-abu muda
  static const _units = ['kg', 'L', 'pcs'];
  static const _categories = ['Bahan Pokok', 'Olahan', 'Bumbu'];

  @override
  void dispose() {
    _nameC.dispose();
    _stockC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  // ---------- modal bottom sheet kategori ----------
  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      // ↓↓↓ builder baru ↓↓↓
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // <-- kunci agar sheet setinggi konten
          children: _categories
              .map((c) => ListTile(
                    leading:
                        const Icon(Icons.category_outlined, color: _primary),
                    title: Text(c),
                    trailing: c == _selectedCategory
                        ? const Icon(Icons.check, color: _primary)
                        : null,
                    onTap: () => Navigator.pop(context, c),
                  ))
              .toList(),
        ),
      ),
    );
    if (result != null) setState(() => _selectedCategory = result);
  }

  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Tambah Barang'),
        backgroundColor: const Color(0xFFDC6A26),
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
                  // Nama Barang
                  TextFormField(
                    controller: _nameC,
                    decoration:
                        _decoration('Nama Barang', Icons.inventory_2_outlined),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // Jumlah Stok
                  TextFormField(
                    controller: _stockC,
                    decoration:
                        _decoration('Jumlah Stok', Icons.layers_outlined),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Stok wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // Unit (ChoiceChip)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: _units
                          .map((u) => ChoiceChip(
                                label: Text(u),
                                selected: _selectedUnit == u,
                                onSelected: (_) =>
                                    setState(() => _selectedUnit = u),
                                selectedColor: _primary.withOpacity(.15),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Harga per unit
                  TextFormField(
                    controller: _priceC,
                    decoration: _decoration(
                        'Harga per unit', Icons.price_change_outlined),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Harga wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // Kategori (read-only field membuka bottom sheet)
                  GestureDetector(
                    onTap: _pickCategory,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration:
                            _decoration('Kategori', Icons.category_outlined)
                                .copyWith(
                          hintText: _selectedCategory,
                        ),
                        validator: (_) =>
                            _selectedCategory == null ? 'Pilih kategori' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Simpan
                  SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC6A26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 1,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedUnit != null &&
                              _selectedCategory != null) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('User belum login')),
                              );
                              return;
                            }

                            final uid = user.uid;
                            final docRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('inventory')
                                .doc();

                            final newItem = {
                              'id': docRef.id,
                              'name': _nameC.text.trim(),
                              'iconName': 'inventory',
                              'stock': int.parse(_stockC.text),
                              'unit': _selectedUnit!,
                              'price': double.parse(_priceC.text),
                              'category': _selectedCategory!,
                            };

                            await docRef.set(newItem);

                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(244, 255, 255, 255),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
