import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/inventory_item.dart';

class StockCard extends StatelessWidget {
  final InventoryItem item;
  const StockCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Misal kapasitas maksimum 20 untuk progress bar demo
    final percent = (item.stock / 20).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(item.icon, size: 36, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(percent > 0.3 ? Colors.green : Colors.red),
                  ),
                  const SizedBox(height: 4),
                  Text('Stok: ${item.stock} ${item.unit}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              NumberFormat.currency(locale: 'id', symbol: 'Rp').format(item.price),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
