import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive dan membuka box 'favorites'
  await Hive.initFlutter();
  await Hive.openBox('favorites');

  // 2. Cek Status Login dari SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Jalankan aplikasi dengan status login awal
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NontonSkuy!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
      ),
      // Jika sudah pernah login -> langsung ke MainNavigation
      // Jika belum -> diarahkan ke LoginScreen
      home: isLoggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}
