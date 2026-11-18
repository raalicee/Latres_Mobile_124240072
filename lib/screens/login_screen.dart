import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk membaca inputan teks username dan password
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  /// [FITUR: PROSES VALIDASI LOGIN]
  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (password == '123' && username == '124240072') {
      // Menyimpan sesi login ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);

      if (!mounted) return;
      // Berpindah ke halaman utama (MainNavigation) dan menghapus riwayat stack login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      // Menampilkan notifikasi SnackBar jika kredensial salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Gagal! Periksa kembali Username dan Password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Membersihkan controller agar tidak terjadi memory leak
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Ikon Film Merah (Film Strip)
                const Icon(
                  Icons.local_movies_rounded,
                  size: 64,
                  color: Color(0xFFE50914),
                ),
                const SizedBox(height: 12),

                // Teks Judul Aplikasi
                const Text(
                  'NontonSkuy!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 36),

                // Input Field Username dengan Border Melengkung
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.person, color: Colors.grey, size: 20),
                    hintText: 'Username (NIM)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: false,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFFE50914), width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Field Password dengan Border Melengkung & obscureText
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Menyembunyikan karakter password (titik-titik)
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.grey, size: 20),
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: false,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFFE50914), width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Login Merah Lonjong
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _login,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
