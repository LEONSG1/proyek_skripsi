import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../presentation/pages/auth/login_page.dart';   // dipakai sign-out
// MainNavigation TIDAK di-import langsung karena kita pakai route '/main'

class AuthService {
  /* ────────────── SIGN-UP ────────────── */
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // selesai daftar ⇒ pindah ke dashboard utama (route '/main')
      Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      _showToast(
        e.code == 'weak-password'
            ? 'Password terlalu lemah.'
            : 'Email sudah terdaftar.',
      );
    }
  }

  /* ────────────── SIGN-IN ────────────── */
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      _showToast(
        e.code == 'invalid-email'
            ? 'Email tidak ditemukan.'
            : 'Password salah.',
      );
    }
  }

  /* ────────────── SIGN-OUT ───────────── */
  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  /* ────────────── HELPER ─────────────── */
  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
