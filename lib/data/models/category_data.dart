import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  const CategoryItem(this.name, this.icon);
}

/* ---------- Pengeluaran ---------- */
const List<CategoryItem> expenseCategories = [
  CategoryItem('Makanan', Icons.restaurant),
  CategoryItem('Transportasi', Icons.directions_car),
  CategoryItem('Dompet Digital', Icons.account_balance_wallet),
  CategoryItem('Kebutuhan Bulanan', Icons.receipt_long),
  CategoryItem('Belanja', Icons.shopping_cart),
  CategoryItem('Sewa/Kontrak', Icons.house_siding),
  CategoryItem('Cicilan', Icons.request_quote),
  CategoryItem('Entertainment', Icons.music_note),
  CategoryItem('Hobi', Icons.photo_camera),
  CategoryItem('Olahraga', Icons.sports_soccer),
  CategoryItem('Kesehatan', Icons.favorite_border),
];

/* ---------- Pemasukan ---------- */
const List<CategoryItem> incomeCategories = [
  CategoryItem('Penjualan Nasi Ayam', Icons.rice_bowl),
  CategoryItem('Penjualan Nasi Rendang', Icons.rice_bowl_outlined),
  CategoryItem('Lainnya', Icons.attach_money),
];
