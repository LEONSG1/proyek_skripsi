import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../providers/loan_debt_provider.dart';
import '../providers/inventory_provider.dart';

class AuthService {
  /* ────────────── SIGN-UP ────────────── */
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveUserToFirestore(credential.user!);
      await initializeUserData(context); // ✅ Jalankan listener setelah signup

      // ❌ Jangan pakai Navigator — biarkan AuthWrapper redirect otomatis
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'weak-password') {
        msg = 'Password terlalu lemah. Minimal 6 karakter.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'Email sudah terdaftar.';
      } else if (e.code == 'invalid-email') {
        msg = 'Format email tidak valid.';
      } else {
        msg = 'Gagal mendaftar: ${e.message}';
      }
      _showToast(msg);
    } catch (e) {
      _showToast('Terjadi kesalahan. Coba lagi.');
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

      await initializeUserData(context); // ✅ Jalankan listener setelah login

      // ❌ Jangan pakai Navigator — biarkan AuthWrapper redirect otomatis
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        msg = 'Email tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        msg = 'Password salah.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Terlalu banyak percobaan. Coba lagi nanti.';
      } else {
        msg = 'Gagal login: ${e.message}';
      }
      _showToast(msg);
    } catch (e) {
      _showToast('Terjadi kesalahan. Coba lagi.');
    }
  }

  /* ────────────── SIGN-OUT (tanpa Navigator) ───────────── */
  Future<void> signout({required BuildContext context}) async {
    debugPrint('[AuthService] Mulai logout');

    try {
      // 1. Cancel listener
      context.read<TransactionProvider>().cancelSubscription();
      context.read<LoanDebtProvider>().cancelSubscription();
      context.read<InventoryProvider>().cancelSubscription();
      debugPrint('[AuthService] Listener dibatalkan');

      // 2. Bersihkan data lokal
      context.read<TransactionProvider>().clear();
      context.read<LoanDebtProvider>().clear();
      context.read<InventoryProvider>().clear();
      debugPrint('[AuthService] Data lokal dibersihkan');

      // 3. Tunggu sedikit (opsional)
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. Sign out dari Firebase
      await FirebaseAuth.instance.signOut();
      debugPrint('[AuthService] Firebase sign out sukses');

      // ❌ Tidak pakai navigator, AuthWrapper akan redirect otomatis
    } catch (e) {
      debugPrint('❌ Error saat logout: $e');
    }
  }

  /* ─────── Listener Data per User ─────── */
  Future<void> initializeUserData(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      context.read<InventoryProvider>().listenToInventory(uid);
      context.read<TransactionProvider>().listenToTransactions(uid);
      context.read<LoanDebtProvider>().listenToLoanDebts(uid);
    } catch (e, st) {
      debugPrint('[AuthService] Listener init failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /* ─────────── SAVE USER TO FIRESTORE ─────────── */
  Future<void> _saveUserToFirestore(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'email': user.email,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
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
