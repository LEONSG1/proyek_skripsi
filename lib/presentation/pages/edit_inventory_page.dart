import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../helpers/currency_formatter.dart';

class EditInventoryPage extends StatefulWidget {
  final InventoryItem item;
  const EditInventoryPage({Key? key, required this.item}) : super(key: key);

  @override
  State<EditInventoryPage> createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _priceCtrl;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameCtrl   = TextEditingController(text: widget.item.name);
    _stockCtrl  = TextEditingController(text: widget.item.stock.toString());
    _unitCtrl   = TextEditingController(text: widget.item.unit);
    _priceCtrl  = TextEditingController(text: widget.item.price.toStringAsFixed(0));
    _category   = widget.item.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Button block ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onUpdate,
                    icon: const Icon(Icons.edit, color: Colors.green),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                      foregroundColor: Colors.green[800],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red[800],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Fields ──
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _unitCtrl,
              decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['Semua', 'Bahan Pokok', 'Olahan', 'Bumbu']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (c) {
                if (c != null) setState(() => _category = c);
              },
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  void _onUpdate() {
    final prov = context.read<InventoryProvider>();
    prov.updateItem(
      id: widget.item.id,
      name: _nameCtrl.text,
      stock: int.tryParse(_stockCtrl.text) ?? widget.item.stock,
      unit: _unitCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
      category: _category,
    );
    Navigator.pop(context);
  }

  void _onDelete() {
    context.read<InventoryProvider>().removeItem(widget.item.id);
    Navigator.pop(context);
  }
}
