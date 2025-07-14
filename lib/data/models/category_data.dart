import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  const CategoryItem(this.name, this.icon);
}

/* ---------- Pengeluaran ---------- */
const List<CategoryItem> expenseCategories = [
  CategoryItem('Bahan Baku', Icons.shopping_basket),
  CategoryItem('Transportasi', Icons.directions_car),
  CategoryItem('Gaji Karyawan', Icons.account_balance_wallet),
  CategoryItem('Retribusi Ormas', Icons.account_balance_wallet),
  CategoryItem('Sewa/Kontrak', Icons.house_siding),
  CategoryItem('Cicilan', Icons.request_quote),
  CategoryItem('Operasional', Icons.shopping_cart),
  CategoryItem('Kebutuhan Produksi', Icons.shopping_cart),
  
 CategoryItem('Pajak', Icons.taxi_alert),
 CategoryItem('Lain lain', Icons.account_balance_wallet),
 
];

/* ---------- Pemasukan ---------- */
const List<CategoryItem> incomeCategories = [
  CategoryItem('Penjualan Makanan', Icons.rice_bowl),
  CategoryItem('Penjualan Minuman', Icons.rice_bowl_outlined),
  CategoryItem('Pesanan Online', Icons.delivery_dining),
  CategoryItem('Catering', Icons.assignment),
  CategoryItem('Lainnya', Icons.attach_money),
];
