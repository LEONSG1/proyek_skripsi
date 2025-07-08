import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../helpers/currency_formatter.dart';
import 'add_inventory_page.dart';
import 'edit_inventory_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _search = '';
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();

    print('[InventoryPage] Total items loaded: ${inv.items.length}');

    // kumpulkan daftar kategori unik
    final categories = <String>{
      'Semua',
      ...inv.items.map((it) => it.category),
    }.toList();

    // saring berdasarkan search & kategori
    final filtered = inv.items.where((it) {
      if (_selectedCategory != 'Semua' && it.category != _selectedCategory) {
        return false;
      }
      if (_search.isNotEmpty &&
          !it.name.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    print('[InventoryPage] Filtered items: ${filtered.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'STOK BARANG',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFDC6A26),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ───── Top Card ─────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E6D4),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummary('${inv.totalCount}', 'item'),
                    _buildSummary('${inv.lowStockCount}', 'stok menipis'),
                    _buildSummary(formatCurrency(inv.totalValue), 'total nilai'),
                  ],
                ),
              ),
            ),
          ),

          // ───── Search Bar ─────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (s) => setState(() => _search = s),
            ),
          ),

          const SizedBox(height: 8),

          // ───── Category Chips ─────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                return ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ───── List of Items ─────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final it = filtered[i];
                print('[InventoryPage] Render item: ${it.name}');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(it.icon, color: Colors.green[700]),
                    title: Text(it.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Stok: ${it.stock} ${it.unit}'),
                    trailing: Text(
                      formatCurrency(it.price * it.stock),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditInventoryPage(item: it),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddInventoryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC6A26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Tambah Stok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
