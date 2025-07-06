<<<<<<< HEAD
// lib/main.dart

=======
>>>>>>> 4437616 (update data)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';             // ← tambahan
import 'firebase_options.dart';                                // ← tambahan
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/transaction_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/loan_debt_provider.dart';

import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/signup_page.dart';
import 'presentation/pages/main_navigation.dart';
import 'presentation/pages/auth/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
    FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // ─── INISIALISASI FIREBASE ───────────────────────────────────────
  
  // ─────────────────────────────────────────────────────────────────

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => LoanDebtProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

<<<<<<< HEAD
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Inisialisasi format lokal Indonesia
//   await initializeDateFormatting('id_ID', null);

//   // Inisialisasi Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // ✅ Aktifkan penyimpanan offline Firestore
//   FirebaseFirestore.instance.settings = const Settings(
//     persistenceEnabled: true,
//   );

//   // Jalankan aplikasi dengan MultiProvider
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => TransactionProvider()),
//         ChangeNotifierProvider(create: (_) => InventoryProvider()),
//         ChangeNotifierProvider(create: (_) => LoanDebtProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
=======
>>>>>>> 4437616 (update data)

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keuangan UMKM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),

      // 1) daftar semua route yang dipakai AuthService
      routes: {
        '/login': (_) =>  Login(),
        '/signup': (_) =>  Signup(),
        '/main': (_) => const MainNavigation(),
      },

      // 2) entry point: pakai wrapper yang cek status auth
      home: const AuthWrapper(),
    );
  }
}
