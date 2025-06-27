import 'package:flutter/material.dart';
import '../../data/models/category_data.dart'; 
  // ⬅️ path diperbaiki

class CategoryPickerPage extends StatelessWidget {
  /// true = expense, false = income
  final bool isExpense;
  const CategoryPickerPage({super.key, required this.isExpense});

  @override
  Widget build(BuildContext context) {
    final items = isExpense ? expenseCategories : incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isExpense ? 'Kategori Pengeluaran' : 'Kategori Pemasukan',
        ),
      ),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (ctx, i) => ListTile(
          leading: Icon(items[i].icon,
              color: Theme.of(context).colorScheme.primary),
          title: Text(items[i].name),
          onTap: () => Navigator.pop(context, items[i].name),
        ),
      ),
    );
  }
}
