// lib/presentation/pages/add_inventory_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';

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
  IconData? _selectedIcon;

  static const _units = ['kg','L','pcs'];
  static const _categories = ['Bahan Pokok','Olahan','Bumbu'];

  @override
  void dispose() {
    _nameC.dispose();
    _stockC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockC,
                decoration: const InputDecoration(labelText: 'Jumlah Stok'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Stok wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: _units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (u) => setState(() => _selectedUnit = u),
                validator: (v) => v == null ? 'Pilih unit' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceC,
                decoration: const InputDecoration(labelText: 'Harga per unit'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCategory = c),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final stock = int.parse(_stockC.text);
                    final price = double.parse(_priceC.text);
                    final icon = Icons.inventory_2;
                    context.read<InventoryProvider>().addItem(
                      name: _nameC.text,
                      icon: icon,
                      stock: stock,
                      unit: _selectedUnit!,
                      price: price,
                      category: _selectedCategory!,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
