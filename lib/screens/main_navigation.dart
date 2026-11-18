import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Index tab yang sedang aktif (0 = Beranda, 1 = Favorit, 2 = Profil)
  int _currentIndex = 0;

  // Daftar halaman yang dihubungkan dengan BottomNavigationBar
  final List<Widget> _pages = [
    const HomeScreen(),      // Index 0
    const FavoriteScreen(),  // Index 1
    const ProfileScreen(),   // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan halaman sesuai tab yang dipilih
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,             // Latar belakang hitam pekat
        selectedItemColor: const Color(0xFFE50914), // Warna tab aktif (Merah)
        unselectedItemColor: Colors.grey,           // Warna tab tidak aktif (Abu-abu)
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (index) {
          // Mengubah index aktif saat user menekan salah satu tab
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
