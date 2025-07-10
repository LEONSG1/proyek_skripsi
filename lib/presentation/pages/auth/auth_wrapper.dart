import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main_navigation.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Sambil menunggu status auth (saat app baru dibuka)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Jika user sudah login → masuk ke MainNavigation
        // ❌ Jika belum login → tampilkan LoginPage
        if (snapshot.hasData) {
          return const MainNavigation();
        } else {
          return const Login();
        }
      },
    );
  }
}
