import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      await _saveUserToFirestore(credential.user!); // ⬅️ Tambahkan ini

      Navigator.pushReplacementNamed(context, '/main');
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
      Navigator.pushReplacementNamed(context, '/main');
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

  /* ────────────── SIGN-OUT ───────────── */
  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
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
