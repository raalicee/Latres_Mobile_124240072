import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// [FITUR: MEMBACA DATA USER DARI SHAREDPREFERENCES]
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Mengambil username yang disimpan saat login, jika belum ada default '-'
      username = prefs.getString('username') ?? '-';
    });
  }

  /// [FITUR: LOGOUT]
  /// Menghapus seluruh data sesi lokal dan mengembalikan pengguna ke LoginScreen
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // [PENYESUAIAN RESPONSI]: prefs.clear() menghapus semua data SharedPreferences
    await prefs.clear();

    if (!mounted) return;
    // Pindah ke LoginScreen dan hapus semua rute halaman sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran Avatar Profile Abu-abu
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF616161),
              child: Icon(
                Icons.person,
                size: 55,
                color: Color(0xFFE0E0E0),
              ),
            ),
            const SizedBox(height: 16),

            // Nama User / NIM yang didapat dari SharedPreferences
            Text(
              username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Teks Pesan dan Kesan
            const Text(
              'Kesan: Praktikum mobile seru dan menantang!\n'
              'Pesan: Semoga nilainya memuaskan dan ilmunya bermanfaat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Logout Merah
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                onPressed: _logout,
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
