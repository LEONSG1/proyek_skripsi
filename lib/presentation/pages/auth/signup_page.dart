import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'package:proyek_baru/services/auth_service.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signin(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Register Account',
                  style: GoogleFonts.raleway(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              _emailField(),
              const SizedBox(height: 20),
              _passwordField(),
              const SizedBox(height: 50),
              _signupBtn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Address',
            style: GoogleFonts.raleway(fontSize: 16, color: Colors.black)),
        const SizedBox(height: 12),
        TextField(
          controller: _emailC,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'masukkan email anda',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xff6A6A6A)),
            filled: true,
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password',
            style: GoogleFonts.raleway(fontSize: 16, color: Colors.black)),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordC,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signupBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final email = _emailC.text.trim();
        final password = _passwordC.text;

        if (email.isEmpty || password.isEmpty) {
          Fluttertoast.showToast(msg: 'Email dan password wajib diisi.');
          return;
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
          Fluttertoast.showToast(msg: 'Format email tidak valid.');
          return;
        }
        if (password.length < 6) {
          Fluttertoast.showToast(msg: 'Password minimal 6 karakter.');
          return;
        }

        try {
          await AuthService().signup(email: email, password: password, context: context);
          // Tidak perlu navigasi manual karena AuthWrapper akan pindah otomatis
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            Fluttertoast.showToast(msg: 'Email sudah terdaftar');
          } else {
            Fluttertoast.showToast(msg: 'Gagal mendaftar: ${e.message}');
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D6EFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      child: const Text("Sign Up"),
    );
  }

  Widget _signin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Already Have Account? ",
              style: TextStyle(color: Color(0xff6A6A6A), fontSize: 16),
            ),
            TextSpan(
              text: "Log In",
              style: const TextStyle(color: Color(0xff1A1D1E), fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
