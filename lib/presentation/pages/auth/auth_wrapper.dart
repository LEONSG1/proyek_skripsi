import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:proyek_baru/providers/inventory_provider.dart';
import 'package:proyek_baru/providers/loan_debt_provider.dart';
import 'package:proyek_baru/providers/transaction_provider.dart';

import '../main_navigation.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // ✅ Listener dijalankan setelah widget tree siap
        if (user != null) {
          Future.microtask(() {
            context.read<InventoryProvider>().listenToInventory(user.uid);
            context.read<TransactionProvider>().listenToTransactions(user.uid);
            context.read<LoanDebtProvider>().listenToLoanDebts(user.uid);
          });

          return const MainNavigation();
        } else {
          return const Login();
        }
      },
    );
  }
}
